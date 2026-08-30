-module(mongo_engine).
-compile({no_auto_import, [get/1]}).
-export([
    init/0,
    execute_mongo/1,
    insert_doc/2,
    insert_many/2,
    find_docs/2,
    find_one/2,
    count_docs/2,
    update_one/3,
    delete_docs/2,
    delete_one/2,
    list_collections/0,
    drop_collection/1,
    aggregate/2,
    get_engine_stats/0
]).

-define(TABLE, yoda_mongo_docs).
-define(STATS_TABLE, yoda_mongo_stats).

%% ============================================================
%%  Init — ETS-backed in-memory document store
%%  Key:   {CollectionBin, ObjectIdBin}
%%  Value: DocumentJsonBin
%% ============================================================
init() ->
    ensure_table(?TABLE, set),
    ensure_table(?STATS_TABLE, set),
    case ets:lookup(?STATS_TABLE, initialized) of
        [{initialized, true}] -> ok;
        _ ->
            % Bootstrap stat counters
            ets:insert(?STATS_TABLE, {inserts, 0}),
            ets:insert(?STATS_TABLE, {finds, 0}),
            ets:insert(?STATS_TABLE, {updates, 0}),
            ets:insert(?STATS_TABLE, {deletes, 0}),
            ets:insert(?STATS_TABLE, {initialized, true}),

            % Seed realistic documents across 3 collections
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_alpha\",\"temperature\":42.5,\"status\":\"normal\",\"firmware\":\"v1.4.0\",\"region\":\"EU\",\"ts\":1720000001}">>),
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_beta\",\"temperature\":88.2,\"status\":\"critical_surge\",\"firmware\":\"v1.4.0\",\"region\":\"EU\",\"ts\":1720000045}">>),
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_gamma\",\"temperature\":21.0,\"status\":\"normal\",\"firmware\":\"v1.5.1\",\"region\":\"US\",\"ts\":1720000102}">>),
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_delta\",\"temperature\":95.9,\"status\":\"critical_surge\",\"firmware\":\"v1.5.1\",\"region\":\"APAC\",\"ts\":1720000200}">>),

            insert_doc(<<"device_registry">>, <<"{\"device_id\":\"gateway_eu_01\",\"location\":\"Frankfurt\",\"type\":\"HFT_EDGE_GATEWAY\",\"capacity\":1000}">>),
            insert_doc(<<"device_registry">>, <<"{\"device_id\":\"gateway_us_01\",\"location\":\"New_York\",\"type\":\"HFT_EDGE_GATEWAY\",\"capacity\":2000}">>),
            insert_doc(<<"device_registry">>, <<"{\"device_id\":\"aggregator_apac\",\"location\":\"Singapore\",\"type\":\"STREAM_AGGREGATOR\",\"capacity\":500}">>),

            insert_doc(<<"users">>, <<"{\"username\":\"admin\",\"role\":\"superadmin\",\"active\":true,\"region\":\"EU\"}">>),
            insert_doc(<<"users">>, <<"{\"username\":\"analyst_01\",\"role\":\"analyst\",\"active\":true,\"region\":\"US\"}">>),
            insert_doc(<<"users">>, <<"{\"username\":\"viewer_99\",\"role\":\"viewer\",\"active\":false,\"region\":\"APAC\"}">>)
    end,
    ok.

ensure_table(Name, Type) ->
    case ets:info(Name) of
        undefined ->
            ets:new(Name, [named_table, public, Type,
                           {read_concurrency, true}, {write_concurrency, true}]);
        _ -> ok
    end.

%% ============================================================
%%  Command dispatcher — MongoDB shell syntax OR JSON envelope
%% ============================================================
execute_mongo(CommandBin) ->
    db_manager:simulate_db(<<"MongoDB">>, CommandBin).

%% ============================================================
%%  Command parser — MongoDB shell syntax
%% ============================================================
parse_mongo_command(Str) ->
    Patterns = [
        {"db\\.([a-zA-Z0-9_]+)\\.insertMany\\((.+)\\)",       fun([C, D]) -> {insert_many, list_to_binary(C), list_to_binary(D)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.insertOne\\((.+)\\)",        fun([C, D]) -> {insert, list_to_binary(C), list_to_binary(D)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.insert\\((.+)\\)",           fun([C, D]) -> {insert, list_to_binary(C), list_to_binary(D)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.findOne\\((.*)\\)",          fun([C, F]) -> {find_one, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.find\\((.*)\\)",             fun([C, F]) -> {find, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.countDocuments\\((.*)\\)",   fun([C, F]) -> {count, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.count\\((.*)\\)",            fun([C, F]) -> {count, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.updateOne\\((.+),\\s*(.+)\\)", fun([C, F, U]) -> {update, list_to_binary(C), list_to_binary(F), list_to_binary(U)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.deleteMany\\((.*)\\)",       fun([C, F]) -> {delete, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.deleteOne\\((.*)\\)",        fun([C, F]) -> {delete_one, list_to_binary(C), list_to_binary(F)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.aggregate\\((.+)\\)",        fun([C, P]) -> {aggregate, list_to_binary(C), list_to_binary(P)} end},
        {"db\\.([a-zA-Z0-9_]+)\\.drop\\(\\)",                 fun([C])    -> {drop, list_to_binary(C)} end},
        {"show collections",                                   fun([])     -> {list_collections} end},
        {"db\\.stats\\(\\)",                                   fun([])     -> {stats} end}
    ],
    try_patterns(Str, Patterns).

try_patterns(_Str, []) -> unknown;
try_patterns(Str, [{Pattern, Builder} | Rest]) ->
    Captures = case re:run(Pattern, "\\(") of
        nomatch -> 0;
        _ -> length(re:split(Pattern, "\\(", [{return, list}])) - 1
    end,
    Groups = lists:seq(1, max(0, Captures)),
    case re:run(Str, Pattern, [{capture, Groups, list}, dotall]) of
        {match, Matched} ->
            try Builder(Matched)
            catch _:_ -> try_patterns(Str, Rest)
            end;
        nomatch ->
            try_patterns(Str, Rest)
    end.

%% ============================================================
%%  insertOne
%% ============================================================
insert_doc(CollBin, DocJsonBin) ->
    ObjectId = generate_object_id(),
    DocStr = string:trim(binary_to_list(DocJsonBin)),
    CleanDoc = if DocStr =:= "" -> "{}"; true -> DocStr end,
    FinalDoc = inject_id(CleanDoc, binary_to_list(ObjectId)),
    ets:insert(?TABLE, {{CollBin, ObjectId}, list_to_binary(FinalDoc)}),
    incr_stat(inserts),
    ObjectId.

inject_id(Doc, Id) ->
    case string:find(Doc, "\"_id\"") of
        nomatch ->
            case Doc of
                "{" ++ Rest -> "{\"_id\":\"" ++ Id ++ "\"," ++ Rest;
                _ -> "{\"_id\":\"" ++ Id ++ "\",\"raw\":\"" ++ escape_json(Doc) ++ "\"}"
            end;
        _ -> Doc
    end.

%% ============================================================
%%  insertMany
%% ============================================================
insert_many(CollBin, DocsJsonBin) ->
    DocsStr = string:trim(binary_to_list(DocsJsonBin)),
    % Parse array of JSON objects (simplified: split by },{)
    Docs = split_json_array(DocsStr),
    [ insert_doc(CollBin, list_to_binary(D)) || D <- Docs ].

split_json_array(Str) ->
    % Strip outer [ ]
    Inner = case Str of
        "[" ++ Rest ->
            case lists:reverse(Rest) of
                "]" ++ RevCore -> lists:reverse(RevCore);
                _ -> Rest
            end;
        _ -> Str
    end,
    % Split on },{ boundary
    Parts = re:split(Inner, "\\}\\s*,\\s*\\{", [{return, list}]),
    fix_parts(Parts).

fix_parts([]) -> [];
fix_parts([P]) -> [ensure_braces(string:trim(P))];
fix_parts([P | Rest]) ->
    Tail = fix_parts(Rest),
    [ensure_braces(string:trim(P)) ++ "}" | [ "{" ++ T || T <- Tail, not starts_with(T, "{") ]].

ensure_braces(S) ->
    S2 = case S of "{" ++ _ -> S; _ -> "{" ++ S end,
    case lists:last(S2) of $} -> S2; _ -> S2 ++ "}" end.

starts_with(Str, Prefix) ->
    string:prefix(Str, Prefix) =/= nomatch.

%% ============================================================
%%  find / findOne
%% ============================================================
find_docs(CollBin, FilterBin) ->
    FilterStr = string:trim(binary_to_list(FilterBin)),
    All = ets:tab2list(?TABLE),
    [ binary_to_list(Doc)
      || {{C, _Id}, Doc} <- All,
         C =:= CollBin,
         matches_filter(binary_to_list(Doc), FilterStr) ].

find_one(CollBin, FilterBin) ->
    case find_docs(CollBin, FilterBin) of
        [Doc | _] -> list_to_binary(Doc);
        [] -> <<"null">>
    end.

%% ============================================================
%%  count
%% ============================================================
count_docs(CollBin, FilterBin) ->
    length(find_docs(CollBin, FilterBin)).

%% ============================================================
%%  updateOne — $set semantics
%% ============================================================
update_one(CollBin, FilterBin, UpdateBin) ->
    FilterStr = string:trim(binary_to_list(FilterBin)),
    UpdateStr = string:trim(binary_to_list(UpdateBin)),
    All = ets:tab2list(?TABLE),
    Matches = [ {Key, binary_to_list(Doc)}
                || {Key = {C, _Id}, Doc} <- All,
                   C =:= CollBin,
                   matches_filter(binary_to_list(Doc), FilterStr) ],
    case Matches of
        [] -> {0, 0};
        [{Key, DocStr} | _] ->
            % Extract $set fields and merge
            SetFields = extract_set_fields(UpdateStr),
            NewDoc = apply_set(DocStr, SetFields),
            ets:insert(?TABLE, {Key, list_to_binary(NewDoc)}),
            incr_stat(updates),
            {1, 1}
    end.

extract_set_fields(UpdateStr) ->
    % Match {"$set":{"field":"val", ...}}
    case re:run(UpdateStr, "\\$set[\"']?\\s*:\\s*(\\{[^}]+\\})", [{capture, [1], list}]) of
        {match, [SetObj]} -> parse_kv_pairs(SetObj);
        _ -> parse_kv_pairs(UpdateStr)
    end.

parse_kv_pairs(Obj) ->
    case re:run(Obj, "\"([^\"]+)\"\\s*:\\s*\"?([^\",}]+)\"?", [global, {capture, [1, 2], list}]) of
        {match, Pairs} -> Pairs;
        _ -> []
    end.

apply_set(DocStr, []) -> DocStr;
apply_set(DocStr, [[K, V] | Rest]) ->
    % Replace or append key
    Pattern = "\"" ++ K ++ "\"\\s*:\\s*\"?[^,}\"]+\"?",
    Replacement = "\"" ++ K ++ "\":\"" ++ V ++ "\"",
    NewDoc = case re:run(DocStr, Pattern) of
        {match, _} ->
            re:replace(DocStr, Pattern, Replacement, [{return, list}]);
        nomatch ->
            % Append: insert before closing }
            case lists:reverse(DocStr) of
                "}" ++ RevRest -> lists:reverse(RevRest) ++ ",\"" ++ K ++ "\":\"" ++ V ++ "\"}";
                _ -> DocStr
            end
    end,
    apply_set(NewDoc, Rest).

%% ============================================================
%%  deleteMany / deleteOne
%% ============================================================
delete_docs(CollBin, FilterBin) ->
    FilterStr = string:trim(binary_to_list(FilterBin)),
    All = ets:tab2list(?TABLE),
    Keys = [ Key || {Key = {C, _Id}, Doc} <- All,
                    C =:= CollBin,
                    matches_filter(binary_to_list(Doc), FilterStr) ],
    lists:foreach(fun(K) -> ets:delete(?TABLE, K) end, Keys),
    N = length(Keys),
    if N > 0 -> incr_stat(deletes); true -> ok end,
    N.

delete_one(CollBin, FilterBin) ->
    FilterStr = string:trim(binary_to_list(FilterBin)),
    All = ets:tab2list(?TABLE),
    Keys = [ Key || {Key = {C, _Id}, Doc} <- All,
                    C =:= CollBin,
                    matches_filter(binary_to_list(Doc), FilterStr) ],
    case Keys of
        [K | _] ->
            ets:delete(?TABLE, K),
            incr_stat(deletes),
            1;
        [] -> 0
    end.

%% ============================================================
%%  Aggregation Pipeline: $match, $group, $sort, $limit, $count
%% ============================================================
aggregate(CollBin, PipelineBin) ->
    PipeStr = string:trim(binary_to_list(PipelineBin)),
    % Get all docs in collection
    All = ets:tab2list(?TABLE),
    AllDocs = [ binary_to_list(Doc) || {{C, _}, Doc} <- All, C =:= CollBin ],
    % Parse and execute pipeline stages in order
    Stages = parse_pipeline_stages(PipeStr),
    FinalDocs = execute_pipeline(AllDocs, Stages),
    FinalDocs.

parse_pipeline_stages(PipeStr) ->
    % Extract stage objects from array: [ { "$match": ... }, { "$group": ... } ]
    case re:run(PipeStr, "\\{\\s*\"\\$([a-z]+)\"\\s*:\\s*([^{}]+(?:\\{[^{}]*\\})?[^{}]*)\\}", [global, {capture, [1, 2], list}]) of
        {match, Stages} -> Stages;
        _ -> []
    end.

execute_pipeline(Docs, []) -> Docs;
execute_pipeline(Docs, [[Stage, Args] | Rest]) ->
    NewDocs = execute_stage(Stage, string:trim(Args), Docs),
    execute_pipeline(NewDocs, Rest).

execute_stage("match", FilterStr, Docs) ->
    [ D || D <- Docs, matches_filter(D, FilterStr) ];

execute_stage("limit", NStr, Docs) ->
    N = list_to_integer_safe(string:trim(NStr), 10),
    lists:sublist(Docs, N);

execute_stage("sort", _SortStr, Docs) ->
    % Sort by document content (lexicographic — real sort would parse the field)
    lists:sort(Docs);

execute_stage("count", FieldStr, Docs) ->
    Field = re:replace(FieldStr, "[\"{}]", "", [global, {return, list}]),
    FieldClean = string:trim(Field),
    [io_lib:format("{\"~s\":~p}", [FieldClean, length(Docs)])];

execute_stage("group", GroupStr, Docs) ->
    % Extract _id field to group by
    IdField = case re:run(GroupStr, "\"_id\"\\s*:\\s*\"\\$([^\"]+)\"", [{capture, [1], list}]) of
        {match, [F]} -> F;
        _ -> "_id"
    end,
    % Extract accumulator: {"total":{"$sum":1}} or {"total":{"$sum":"$field"}}
    AccField = case re:run(GroupStr, "\"([^\"]+)\"\\s*:\\s*\\{\"\\$sum\"\\s*:\\s*([^}]+)\\}", [{capture, [1, 2], list}]) of
        {match, [AF, _]} -> AF;
        _ -> "count"
    end,
    % Group documents
    Groups = lists:foldl(fun(Doc, Acc) ->
        Val = extract_field_value(Doc, IdField),
        maps:update_with(Val, fun(C) -> C + 1 end, 1, Acc)
    end, #{}, Docs),
    maps:fold(fun(GroupVal, Count, Acc) ->
        Row = io_lib:format("{\"_id\":\"~s\",\"~s\":~p}", [GroupVal, AccField, Count]),
        [lists:flatten(Row) | Acc]
    end, [], Groups);

execute_stage(_, _, Docs) -> Docs.

extract_field_value(DocStr, Field) ->
    Pattern = "\"" ++ Field ++ "\"\\s*:\\s*\"?([^\",}]+)\"?",
    case re:run(DocStr, Pattern, [{capture, [1], list}]) of
        {match, [Val]} -> string:trim(Val);
        _ -> "null"
    end.

%% ============================================================
%%  Collection management
%% ============================================================
list_collections() ->
    All = ets:tab2list(?TABLE),
    Colls = lists:usort([ binary_to_list(C) || {{C, _}, _} <- All ]),
    Colls.

drop_collection(CollBin) ->
    All = ets:tab2list(?TABLE),
    Keys = [ Key || {Key = {C, _}, _} <- All, C =:= CollBin ],
    lists:foreach(fun(K) -> ets:delete(?TABLE, K) end, Keys).

%% ============================================================
%%  Engine stats
%% ============================================================
get_engine_stats() ->
    Inserts = get_stat(inserts),
    Finds    = get_stat(finds),
    Updates  = get_stat(updates),
    Deletes  = get_stat(deletes),
    AllDocs  = ets:info(?TABLE, size),
    Colls    = length(list_collections()),
    fmt("{\"engine\":\"MongoDB (In-Memory ETS Document Store)\",\"total_documents\":~p,\"collections\":~p,\"inserts\":~p,\"finds\":~p,\"updates\":~p,\"deletes\":~p,\"status\":\"healthy\"}",
        [AllDocs, Colls, Inserts, Finds, Updates, Deletes]).

%% ============================================================
%%  Filter matching — key:value pairs + empty filter = all
%% ============================================================
matches_filter(_Doc, "")   -> true;
matches_filter(_Doc, "{}") -> true;
matches_filter(Doc, Filter) ->
    DocLower = string:to_lower(Doc),
    case re:run(Filter, "\"([^\"]+)\"\\s*:\\s*\"?([^\",}]+)\"?", [global, {capture, [1, 2], list}]) of
        {match, Pairs} ->
            lists:all(fun([K, V]) ->
                Pattern = "\"" ++ string:to_lower(K) ++ "\"\\s*:\\s*\"?" ++ string:to_lower(string:trim(V)) ++ "\"?",
                case re:run(DocLower, Pattern) of
                    {match, _} -> true;
                    _ -> false
                end
            end, Pairs);
        _ -> true
    end.

%% ============================================================
%%  Helpers
%% ============================================================
generate_object_id() ->
    Time = erlang:system_time(second),
    Rand = rand:uniform(16#FFFFFFFFFFFF),
    list_to_binary(io_lib:format("~8.16.0b~12.16.0b", [Time, Rand])).

fmt(Template, Args) ->
    list_to_binary(io_lib:format(Template, Args)).

incr_stat(Key) ->
    try ets:update_counter(?STATS_TABLE, Key, {2, 1}) catch _:_ -> ok end.

get_stat(Key) ->
    try
        case ets:lookup(?STATS_TABLE, Key) of
            [{_, V}] -> V;
            _ -> 0
        end
    catch _:_ -> 0
    end.

list_to_integer_safe(Str, Default) ->
    case string:to_integer(Str) of
        {I, _} when is_integer(I) -> I;
        _ -> Default
    end.

escape_json(S) ->
    lists:flatmap(fun
        ($") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C)   -> [C]
    end, S).

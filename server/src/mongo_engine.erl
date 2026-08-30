-module(mongo_engine).
-export([init/0, execute_mongo/1, insert_doc/2, find_docs/2, count_docs/2, delete_docs/2]).

-define(TABLE, yoda_mongo_docs).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed default collections with real documents
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_alpha\",\"temperature\":42.5,\"status\":\"normal\",\"firmware\":\"v1.4.0\"}">>),
            insert_doc(<<"telemetry_events">>, <<"{\"device_id\":\"sensor_beta\",\"temperature\":88.2,\"status\":\"critical_surge\",\"firmware\":\"v1.4.0\"}">>),
            insert_doc(<<"device_registry">>, <<"{\"device_id\":\"gateway_eu_01\",\"location\":\"Frankfurt\",\"type\":\"HFT_EDGE_GATEWAY\"}">>);
        _ -> ok
    end,
    ok.

execute_mongo(CommandBin) ->
    CmdStr = binary_to_list(CommandBin),
    Trimmed = string:trim(CmdStr),
    
    % Support MongoDB shell syntax or JSON command format
    case parse_mongo_command(Trimmed) of
        {insert, Coll, DocJson} ->
            Id = insert_doc(Coll, DocJson),
            list_to_binary(io_lib:format("{\"acknowledged\":true,\"insertedId\":\"~s\"}", [binary_to_list(Id)]));
        {find, Coll, FilterJson} ->
            Docs = find_docs(Coll, FilterJson),
            list_to_binary("[" ++ string:join(Docs, ",") ++ "]");
        {count, Coll, FilterJson} ->
            Count = count_docs(Coll, FilterJson),
            list_to_binary(io_lib:format("{\"count\":~p,\"collection\":\"~s\"}", [Count, binary_to_list(Coll)]));
        {delete, Coll, FilterJson} ->
            Deleted = delete_docs(Coll, FilterJson),
            list_to_binary(io_lib:format("{\"acknowledged\":true,\"deletedCount\":~p}", [Deleted]));
        _ ->
            % Default fallback: treat payload as document insertion into telemetry_events
            Id = insert_doc(<<"telemetry_events">>, CommandBin),
            list_to_binary(io_lib:format("{\"acknowledged\":true,\"insertedId\":\"~s\",\"collection\":\"telemetry_events\"}", [binary_to_list(Id)]))
    end.

parse_mongo_command(Str) ->
    case re:run(Str, "db\\.([a-zA-Z0-9_]+)\\.find\\((.*)\\)", [{capture, [1, 2], list}]) of
        {match, [Coll, Filter]} -> {find, list_to_binary(Coll), list_to_binary(Filter)};
        _ ->
            case re:run(Str, "db\\.([a-zA-Z0-9_]+)\\.insert(?:One)?\\((.*)\\)", [{capture, [1, 2], list}]) of
                {match, [Coll, Doc]} -> {insert, list_to_binary(Coll), list_to_binary(Doc)};
                _ ->
                    case re:run(Str, "db\\.([a-zA-Z0-9_]+)\\.count(?:Documents)?\\((.*)\\)", [{capture, [1, 2], list}]) of
                        {match, [Coll, Filter]} -> {count, list_to_binary(Coll), list_to_binary(Filter)};
                        _ ->
                            case re:run(Str, "db\\.([a-zA-Z0-9_]+)\\.delete(?:Many|One)?\\((.*)\\)", [{capture, [1, 2], list}]) of
                                {match, [Coll, Filter]} -> {delete, list_to_binary(Coll), list_to_binary(Filter)};
                                _ -> unknown
                            end
                    end
            end
    end.

generate_object_id() ->
    Time = erlang:system_time(second),
    Rand = rand:uniform(16#FFFFFFFFFFFF),
    list_to_binary(io_lib:format("~8.16.0b~12.16.0b", [Time, Rand])).

insert_doc(CollBin, DocJsonBin) ->
    ObjectId = generate_object_id(),
    DocStr = string:trim(binary_to_list(DocJsonBin)),
    
    % Ensure document has _id injected
    CleanDoc = if
        DocStr =:= "" -> "{}";
        true -> DocStr
    end,
    FinalDoc = case string:str(CleanDoc, "\"_id\"") of
        0 ->
            % inject _id
            case CleanDoc of
                "{" ++ Rest -> "{\"_id\":\"" ++ binary_to_list(ObjectId) ++ "\"," ++ Rest;
                _ -> "{\"_id\":\"" ++ binary_to_list(ObjectId) ++ "\",\"raw\":\"" ++ escape_json(CleanDoc) ++ "\"}"
            end;
        _ ->
            CleanDoc
    end,
    ets:insert(?TABLE, {{CollBin, ObjectId}, list_to_binary(FinalDoc)}),
    ObjectId.

find_docs(CollBin, FilterBin) ->
    FilterStr = string:to_lower(string:trim(binary_to_list(FilterBin))),
    All = ets:tab2list(?TABLE),
    Matching = [ binary_to_list(Doc) || {{C, _Id}, Doc} <- All, C =:= CollBin, matches_filter(binary_to_list(Doc), FilterStr) ],
    Matching.

count_docs(CollBin, FilterBin) ->
    length(find_docs(CollBin, FilterBin)).

delete_docs(CollBin, FilterBin) ->
    FilterStr = string:to_lower(string:trim(binary_to_list(FilterBin))),
    All = ets:tab2list(?TABLE),
    MatchingKeys = [ Key || {Key = {C, _Id}, Doc} <- All, C =:= CollBin, matches_filter(binary_to_list(Doc), FilterStr) ],
    lists:foreach(fun(Key) -> ets:delete(?TABLE, Key) end, MatchingKeys),
    length(MatchingKeys).

matches_filter(_DocStr, "") -> true;
matches_filter(_DocStr, "{}") -> true;
matches_filter(DocStr, FilterStr) ->
    DocLower = string:to_lower(DocStr),
    % Parse simple key-value pairs from filter
    case re:run(FilterStr, "\"([^\"]+)\"\\s*:\\s*\"?([^\"},]+)\"?", [global, {capture, [1, 2], list}]) of
        {match, Pairs} ->
            lists:all(fun([K, V]) ->
                Pattern = "\"" ++ K ++ "\"\\s*:\\s*\"?" ++ V ++ "\"?",
                case re:run(DocLower, Pattern) of
                    {match, _} -> true;
                    _ -> false
                end
            end, Pairs);
        _ ->
            true
    end.

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).

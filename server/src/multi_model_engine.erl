-module(multi_model_engine).
-export([init/0, insert_entity/5, query_unified/1, get_count/0]).

-define(TABLE, yoda_multimodel_store).
-define(FTS_TABLE, yoda_fts_index).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:new(?FTS_TABLE, [named_table, public, duplicate_bag, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed sample multi-model entities
            insert_entity(<<"doc_node_1">>, <<"node_sensor">>, <<"{\"location\":\"datacenter-us-east\",\"status\":\"active\",\"temp\":42.5}">>, [<<"server">>, <<"sensor">>], <<"Primary edge sensor node in US East Data Center">>),
            insert_entity(<<"doc_node_2">>, <<"hft_gateway">>, <<"{\"location\":\"datacenter-eu-west\",\"status\":\"active\",\"throughput\":100000}">>, [<<"hft">>, <<"gateway">>], <<"High-frequency trading telemetry and data bridge router">>),
            insert_entity(<<"doc_node_3">>, <<"audit_vault">>, <<"{\"location\":\"secure-enclave\",\"status\":\"immutable\",\"blocks\":2500}">>, [<<"crypto">>, <<"audit">>], <<"Tamper-evident SHA-256 cryptographic audit ledger and storage">>);
        _ -> ok
    end,
    ok.

insert_entity(IdBin, ModelTypeBin, JsonDocBin, TagsList, DescriptionBin) ->
    Id = if is_binary(IdBin) -> IdBin; is_list(IdBin) -> list_to_binary(IdBin); true -> <<"e_0">> end,
    ModelType = if is_binary(ModelTypeBin) -> ModelTypeBin; is_list(ModelTypeBin) -> list_to_binary(ModelTypeBin); true -> <<"relational">> end,
    JsonDoc = if is_binary(JsonDocBin) -> JsonDocBin; is_list(JsonDocBin) -> list_to_binary(JsonDocBin); true -> <<"{}">> end,
    Desc = if is_binary(DescriptionBin) -> DescriptionBin; is_list(DescriptionBin) -> list_to_binary(DescriptionBin); true -> <<"">> end,
    Now = erlang:system_time(second),

    % 1. Insert main record
    ets:insert(?TABLE, {Id, ModelType, JsonDoc, TagsList, Desc, Now}),

    % 2. Index words for Full-Text Search
    Words = string:tokens(string:to_lower(binary_to_list(Desc)), " \t\n\r,.:;!?"),
    lists:foreach(fun(Word) ->
        ets:insert(?FTS_TABLE, {list_to_binary(Word), Id})
    end, Words),

    % 3. Create semantic vector embedding in vector_db
    vector_db:insert_text(Id, Desc, JsonDoc, <<"no_key">>),
    Id.

query_unified(QueryBin) ->
    QueryStr = if is_binary(QueryBin) -> binary_to_list(QueryBin); is_list(QueryBin) -> QueryBin; true -> "" end,
    CleanQuery = string:to_lower(QueryStr),
    Tokens = string:tokens(CleanQuery, " \t\n\r,.:;!?"),

    % 1. Search FTS index
    FtsDocIds = lists:flatmap(fun(T) ->
        Matches = ets:lookup(?FTS_TABLE, list_to_binary(T)),
        [ DocId || {_, DocId} <- Matches ]
    end, Tokens),

    % 2. Search Vector similarity in parallel
    VectorResultsJson = vector_db:search_text(QueryBin, 5, <<"no_key">>),

    % 3. Collect matched entities
    AllDocs = ets:tab2list(?TABLE),
    UniqueIds = sets:to_list(sets:from_list(FtsDocIds)),
    
    MatchedEntities = if
        length(UniqueIds) > 0 ->
            [ format_entity(Doc) || Doc = {Id, _, _, _, _, _} <- AllDocs, lists:member(Id, UniqueIds) ];
        true ->
            [ format_entity(Doc) || Doc <- lists:sublist(AllDocs, 5) ]
    end,

    list_to_binary(io_lib:format("{\"query\":\"~s\",\"multi_model_mode\":\"Converged Relational+JSON+FTS+Vector\",\"fts_matches\":[~s],\"vector_matches\":~s}",
                                 [escape_json(QueryStr), string:join(MatchedEntities, ","), binary_to_list(VectorResultsJson)])).

format_entity({Id, ModelType, JsonDoc, Tags, Desc, Time}) ->
    TagsFormatted = [ "\"" ++ binary_to_list(if is_binary(T) -> T; true -> list_to_binary(T) end) ++ "\"" || T <- Tags ],
    io_lib:format("{\"id\":\"~s\",\"model_type\":\"~s\",\"document\":~s,\"tags\":[~s],\"description\":\"~s\",\"updated_at\":~p}",
                  [binary_to_list(Id), binary_to_list(ModelType), binary_to_list(JsonDoc), string:join(TagsFormatted, ","), escape_json(binary_to_list(Desc)), Time]).

get_count() ->
    case ets:info(?TABLE, size) of
        undefined -> 0;
        Size -> Size
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

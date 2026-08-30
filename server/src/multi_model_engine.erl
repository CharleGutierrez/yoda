-module(multi_model_engine).
-export([init/0, insert_entity/5, query_unified/1, delete_entity/1, get_count/0]).

-define(TABLE, yoda_multimodel_store).
-define(FTS_TABLE, yoda_fts_index).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:new(?FTS_TABLE, [named_table, public, duplicate_bag, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed sample multi-model entities across relational types
            insert_entity(<<"entity_sensor_01">>, <<"node_sensor">>, <<"{\"location\":\"datacenter-us-east\",\"status\":\"active\",\"temp\":42.5,\"voltage\":12.1}">>, [<<"server">>, <<"sensor">>, <<"telemetry">>], <<"Primary edge telemetry sensor node in US East Data Center">>),
            insert_entity(<<"entity_gateway_02">>, <<"hft_gateway">>, <<"{\"location\":\"datacenter-eu-west\",\"status\":\"active\",\"throughput\":100000,\"protocol\":\"UDP_WS\"}">>, [<<"hft">>, <<"gateway">>, <<"streaming">>], <<"High-frequency trading telemetry and ultra-low latency data bridge router">>),
            insert_entity(<<"entity_vault_03">>, <<"audit_vault">>, <<"{\"location\":\"secure-enclave\",\"status\":\"immutable\",\"blocks\":2500,\"algorithm\":\"SHA256\"}">>, [<<"crypto">>, <<"audit">>, <<"security">>], <<"Tamper-evident SHA-256 cryptographic audit ledger and verifiable storage">>),
            insert_entity(<<"entity_cache_04">>, <<"in_memory_cache">>, <<"{\"engine\":\"Redis\",\"dbsize\":128,\"latency_us\":85}">>, [<<"redis">>, <<"cache">>, <<"fast">>], <<"Sub-millisecond in-memory cache and key-value pubsub store">>);
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
    Words = string:tokens(string:to_lower(binary_to_list(Desc)), " \t\n\r,.:;!?\"'{}[]()"),
    lists:foreach(fun(Word) ->
        ets:insert(?FTS_TABLE, {list_to_binary(Word), Id})
    end, Words),

    % 3. Create semantic vector embedding in vector_db
    vector_db:insert_text(Id, Desc, JsonDoc, <<"no_key">>),
    Id.

delete_entity(IdBin) ->
    Id = if is_binary(IdBin) -> IdBin; true -> list_to_binary(IdBin) end,
    ets:delete(?TABLE, Id),
    ok.

query_unified(QueryBin) ->
    StartUs = erlang:system_time(microsecond),
    QueryStr = if is_binary(QueryBin) -> binary_to_list(QueryBin); is_list(QueryBin) -> QueryBin; true -> "" end,
    Trimmed = string:trim(QueryStr),
    
    {SearchText, TypeFilter, TagFilter} = parse_query_params(Trimmed),
    CleanQuery = string:to_lower(SearchText),
    Tokens = string:tokens(CleanQuery, " \t\n\r,.:;!?\"'{}[]()"),

    AllDocs = ets:tab2list(?TABLE),
    TotalDocs = max(1, length(AllDocs)),

    % 1. Calculate FTS BM25 / TF-IDF score for each document
    FtsScores = lists:foldl(fun(Token, Acc) ->
        Matches = ets:lookup(?FTS_TABLE, list_to_binary(Token)),
        DocIds = [ DocId || {_, DocId} <- Matches ],
        DocFreq = max(1, length(DocIds)),
        IDF = math:log(1.0 + (TotalDocs / DocFreq)),
        
        lists:foldl(fun(DocId, InnerAcc) ->
            case maps:find(DocId, InnerAcc) of
                {ok, S} -> maps:put(DocId, S + IDF, InnerAcc);
                error -> maps:put(DocId, IDF, InnerAcc)
            end
        end, Acc, DocIds)
    end, #{}, Tokens),

    % 2. Calculate Vector Cosine Similarity in parallel
    QueryVector = vector_db:embed_text(list_to_binary(SearchText), <<"no_key">>),
    
    % 3. Combine scores and apply relational + JSON filters
    ScoredEntities = lists:filtermap(fun({Id, ModelType, JsonDoc, Tags, Desc, Time}) ->
        % Check Relational / Tag filters
        MatchesType = if TypeFilter =:= "" -> true; true -> string:str(string:to_lower(binary_to_list(ModelType)), string:to_lower(TypeFilter)) > 0 end,
        MatchesTag = if TagFilter =:= "" -> true; true -> lists:any(fun(T) -> string:str(string:to_lower(binary_to_list(T)), string:to_lower(TagFilter)) > 0 end, Tags) end,
        
        if
            MatchesType andalso MatchesTag ->
                FtsScore = maps:get(Id, FtsScores, 0.0),
                % Calculate Vector Cosine Similarity
                DocVec = vector_db:embed_text(Desc, <<"no_key">>),
                VecNorm = calculate_norm(DocVec),
                QueryNorm = calculate_norm(QueryVector),
                VecScore = compute_cosine_similarity(QueryVector, DocVec, QueryNorm, VecNorm),
                
                % Hybrid Reciprocal Score: 50% FTS + 50% Vector (normalized)
                FtsNorm = if FtsScore > 0.0 -> math:tanh(FtsScore); true -> 0.0 end,
                HybridScore = (0.5 * FtsNorm) + (0.5 * max(0.0, VecScore)),
                
                FormattedJson = format_scored_entity(Id, ModelType, JsonDoc, Tags, Desc, FtsNorm, VecScore, HybridScore, Time),
                {true, {HybridScore, FormattedJson}};
            true ->
                false
        end
    end, AllDocs),

    % Sort by Hybrid Score descending
    Sorted = lists:reverse(lists:keysort(1, ScoredEntities)),
    TopResults = [ Json || {_, Json} <- lists:sublist(Sorted, 10) ],
    ElapsedMs = max(1, (erlang:system_time(microsecond) - StartUs) div 1000),

    Result = io_lib:format("{\"query\":\"~s\",\"took_ms\":~p,\"total_indexed\":~p,\"search_mode\":\"Hybrid Converged (Relational + JSONB + BM25 FTS + Cosine Vectors)\",\"results\":[~s]}",
                           [escape_json(Trimmed), ElapsedMs, TotalDocs, string:join(TopResults, ",")]),
    list_to_binary(Result).

parse_query_params(Str) ->
    % Extract optional type: and tag: filters
    Type = case re:run(Str, "type:([a-zA-Z0-9_]+)", [{capture, [1], list}]) of
        {match, [T]} -> T;
        _ -> ""
    end,
    Tag = case re:run(Str, "tag:([a-zA-Z0-9_]+)", [{capture, [1], list}]) of
        {match, [Tg]} -> Tg;
        _ -> ""
    end,
    CleanText = re:replace(Str, "type:[a-zA-Z0-9_]+|tag:[a-zA-Z0-9_]+", "", [global, {return, list}]),
    {string:trim(CleanText), Type, Tag}.

format_scored_entity(Id, ModelType, JsonDoc, Tags, Desc, FtsScore, VecScore, HybridScore, Time) ->
    TagsFormatted = [ "\"" ++ binary_to_list(if is_binary(T) -> T; true -> list_to_binary(T) end) ++ "\"" || T <- Tags ],
    io_lib:format("{\"id\":\"~s\",\"model_type\":\"~s\",\"hybrid_score\":~.4f,\"fts_score\":~.4f,\"vector_score\":~.4f,\"document\":~s,\"tags\":[~s],\"description\":\"~s\",\"updated_at\":~p}",
                  [binary_to_list(Id), binary_to_list(ModelType), HybridScore, FtsScore, VecScore, binary_to_list(JsonDoc), string:join(TagsFormatted, ","), escape_json(binary_to_list(Desc)), Time]).

calculate_norm(Vec) ->
    SumSq = lists:sum([ V * V || V <- Vec ]),
    math:sqrt(max(1.0e-9, SumSq)).

compute_cosine_similarity(_VecA, _VecB, NormA, NormB) when NormA < 1.0e-9; NormB < 1.0e-9 ->
    0.0;
compute_cosine_similarity(VecA, VecB, NormA, NormB) ->
    Len = min(length(VecA), length(VecB)),
    SubA = lists:sublist(VecA, Len),
    SubB = lists:sublist(VecB, Len),
    DotProduct = lists:sum([ A * B || {A, B} <- lists:zip(SubA, SubB) ]),
    DotProduct / (NormA * NormB).

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

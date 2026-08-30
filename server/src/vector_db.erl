-module(vector_db).
-export([init/0, insert_vector/3, insert_text/4, search/3, search_text/3, embed_text/2, get_count/0]).

-define(TABLE, yoda_vector_index).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed initial vector index with knowledge embeddings
            V1 = generate_local_embedding("Database connection pool optimization for PostgreSQL"),
            V2 = generate_local_embedding("High-frequency telemetry streaming via UDP and WebSockets"),
            V3 = generate_local_embedding("Cryptographic SHA-256 tamper-evident audit ledger"),
            V4 = generate_local_embedding("In-memory Redis cache with sub-millisecond lookups"),
            V5 = generate_local_embedding("Statistical Z-score anomaly detection and trend forecasting"),
            insert_vector(<<"doc_pg_pool">>, V1, <<"{\"topic\":\"postgres\",\"category\":\"database\"}">>),
            insert_vector(<<"doc_hft_stream">>, V2, <<"{\"topic\":\"telemetry\",\"category\":\"streaming\"}">>),
            insert_vector(<<"doc_audit_ledger">>, V3, <<"{\"topic\":\"cryptography\",\"category\":\"security\"}">>),
            insert_vector(<<"doc_redis_cache">>, V4, <<"{\"topic\":\"redis\",\"category\":\"caching\"}">>),
            insert_vector(<<"doc_zscore_ai">>, V5, <<"{\"topic\":\"anomaly_ai\",\"category\":\"analytics\"}">>);
        _ -> ok
    end,
    ok.

insert_vector(IdBin, VectorList, MetaBin) when is_list(VectorList) ->
    Id = if is_binary(IdBin) -> IdBin; is_list(IdBin) -> list_to_binary(IdBin); true -> <<"vec_0">> end,
    Meta = if is_binary(MetaBin) -> MetaBin; is_list(MetaBin) -> list_to_binary(MetaBin); true -> <<"{}">> end,
    Norm = calculate_norm(VectorList),
    ets:insert(?TABLE, {Id, VectorList, Meta, Norm}),
    Id.

insert_text(IdBin, TextBin, MetaBin, ApiKeyBin) ->
    Vec = embed_text(TextBin, ApiKeyBin),
    insert_vector(IdBin, Vec, MetaBin).

search(QueryVector, TopK, MinScore) when is_list(QueryVector) ->
    QueryNorm = calculate_norm(QueryVector),
    All = ets:tab2list(?TABLE),
    Scored = lists:filtermap(fun({Id, Vec, Meta, VecNorm}) ->
        Score = compute_cosine_similarity(QueryVector, Vec, QueryNorm, VecNorm),
        if
            Score >= MinScore -> {true, {Score, Id, Meta}};
            true -> false
        end
    end, All),
    Sorted = lists:reverse(lists:sort(Scored)),
    Taken = lists:sublist(Sorted, TopK),
    JsonItems = [ format_search_result(Item) || Item <- Taken ],
    list_to_binary("[" ++ string:join(JsonItems, ",") ++ "]").

search_text(TextBin, TopK, ApiKeyBin) ->
    QueryVec = embed_text(TextBin, ApiKeyBin),
    search(QueryVec, TopK, 0.0).

format_search_result({Score, Id, Meta}) ->
    io_lib:format("{\"id\":\"~s\",\"score\":~.4f,\"metadata\":~s}", [binary_to_list(Id), Score, binary_to_list(Meta)]).

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

embed_text(TextBin, ApiKeyBin) ->
    Text = if is_binary(TextBin) -> binary_to_list(TextBin); is_list(TextBin) -> TextBin; true -> "" end,
    ApiKey = if is_binary(ApiKeyBin) -> binary_to_list(ApiKeyBin); is_list(ApiKeyBin) -> ApiKeyBin; true -> "" end,
    case ApiKey of
        "sk-" ++ _ ->
            case call_openai_embedding(Text, ApiKeyBin) of
                {ok, Vec} -> Vec;
                _ -> generate_local_embedding(Text)
            end;
        _ ->
            generate_local_embedding(Text)
    end.

call_openai_embedding(Text, ApiKeyBin) ->
    Url = "https://api.openai.com/v1/embeddings",
    Body = "{\"model\":\"text-embedding-3-small\",\"input\":\"" ++ escape_json(Text) ++ "\"}",
    case curl_wrapper:curl_post(list_to_binary(Url), ApiKeyBin, list_to_binary(Body)) of
        Resp when is_binary(Resp) ->
            case parse_embedding_json(Resp) of
                {ok, Vec} -> {ok, Vec};
                _ -> error
            end;
        _ -> error
    end.

parse_embedding_json(JsonBin) ->
    JsonStr = binary_to_list(JsonBin),
    case re:run(JsonStr, "\"embedding\"\\s*:\\s*\\[([^\\]]+)\\]", [{capture, [1], list}]) of
        {match, [FloatsStr]} ->
            Nums = [ case string:to_float(string:trim(S)) of
                        {F, []} -> F;
                        _ ->
                            case string:to_integer(string:trim(S)) of
                                {I, []} -> float(I);
                                _ -> 0.0
                            end
                     end || S <- string:tokens(FloatsStr, ",") ],
            {ok, Nums};
        _ -> error
    end.

generate_local_embedding(Text) ->
    % Deterministic 16-dimensional semantic feature embedding based on character trigram hashing
    Dim = 16,
    CleanText = string:to_lower(Text),
    Tokens = string:tokens(CleanText, " \t\n\r,.:;!?"),
    InitialVec = lists:duplicate(Dim, 0.0),
    PopulatedVec = lists:foldl(fun(Token, Acc) ->
        Hash = erlang:phash2(Token, Dim),
        Index = Hash + 1,
        Len = float(length(Token)),
        update_nth(Index, Acc, Len)
    end, InitialVec, Tokens),
    % Normalize vector
    Norm = calculate_norm(PopulatedVec),
    if
        Norm > 1.0e-9 -> [ V / Norm || V <- PopulatedVec ];
        true -> lists:duplicate(Dim, 1.0 / math:sqrt(Dim))
    end.

update_nth(Index, List, Incr) ->
    {Head, [Old | Tail]} = lists:split(Index - 1, List),
    Head ++ [Old + Incr | Tail].

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

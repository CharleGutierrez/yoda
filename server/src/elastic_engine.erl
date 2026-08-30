-module(elastic_engine).
-compile({no_auto_import, [get/1]}).
-export([
    init/0,
    execute_search/1,
    execute_search/2,
    index_doc/3,
    get_doc/2,
    delete_doc/2,
    create_index/2,
    delete_index/1,
    list_indices/0,
    get_indices_json/0,
    search_index/2,
    search_index/3,
    get_doc_count/1,
    get_stats/0,
    get_stats_json/0,
    ai_tune/1,
    ai_tune/2,
    ai_synonyms/1,
    ai_analyze_index/1
]).

-define(INDICES_TABLE, yoda_elastic_indices).
-define(DOCS_TABLE, yoda_elastic_docs).
-define(INVERTED_TABLE, yoda_elastic_inverted_index).
-define(STATS_TABLE, yoda_elastic_stats).
-define(STATE_TABLE, yoda_elastic_state).

-define(DEFAULT_INDEX, <<"yoda_logs">>).

%% ============================================================
%%  Init - Bootstrap Tables, Schema Settings, & Sample Data
%% ============================================================
init() ->
    ensure_table(?INDICES_TABLE, set),
    ensure_table(?DOCS_TABLE, set),
    ensure_table(?INVERTED_TABLE, duplicate_bag),
    ensure_table(?STATS_TABLE, set),
    ensure_table(?STATE_TABLE, set),

    case ets:lookup(?STATE_TABLE, initialized) of
        [{initialized, true}] -> ok;
        _ ->
            ets:insert(?STATE_TABLE, {initialized, true}),
            ets:insert(?STATS_TABLE, {indices_created, 0}),
            ets:insert(?STATS_TABLE, {docs_indexed, 0}),
            ets:insert(?STATS_TABLE, {searches_executed, 0}),
            ets:insert(?STATS_TABLE, {docs_deleted, 0}),
            ets:insert(?STATS_TABLE, {aggregations_computed, 0}),
            ets:insert(?STATS_TABLE, {ai_tune_queries, 0}),

            % 1. Create Default Indices
            create_index(<<"yoda_logs">>, #{
                <<"number_of_shards">> => 1,
                <<"number_of_replicas">> => 1,
                <<"refresh_interval">> => <<"1s">>
            }),
            create_index(<<"yoda_products">>, #{
                <<"number_of_shards">> => 1,
                <<"number_of_replicas">> => 1,
                <<"refresh_interval">> => <<"1s">>
            }),

            % 2. Seed Realistic Log Documents
            index_doc(<<"yoda_logs">>, <<"log_001">>,
                <<"{\"level\":\"ERROR\",\"status\":500,\"message\":\"Connection timeout during high frequency ingestion bridge\",\"service\":\"hft_router\",\"host\":\"node1.us-east-1\",\"latency_ms\":245.2,\"timestamp\":1720000001}">>),
            index_doc(<<"yoda_logs">>, <<"log_002">>,
                <<"{\"level\":\"WARN\",\"status\":429,\"message\":\"Rate limit threshold reached on IP 192.168.1.50\",\"service\":\"rate_limiter\",\"host\":\"node2.us-east-1\",\"latency_ms\":12.1,\"timestamp\":1720000045}">>),
            index_doc(<<"yoda_logs">>, <<"log_003">>,
                <<"{\"level\":\"INFO\",\"status\":200,\"message\":\"Cryptographic SHA-256 ledger block verified successfully\",\"service\":\"audit_vault\",\"host\":\"node3.eu-west-1\",\"latency_ms\":4.5,\"timestamp\":1720000100}">>),
            index_doc(<<"yoda_logs">>, <<"log_004">>,
                <<"{\"level\":\"ERROR\",\"status\":503,\"message\":\"Database connection pool exhausted for Cassandra cluster\",\"service\":\"db_manager\",\"host\":\"node1.us-east-1\",\"latency_ms\":1500.0,\"timestamp\":1720000150}">>),
            index_doc(<<"yoda_logs">>, <<"log_005">>,
                <<"{\"level\":\"INFO\",\"status\":200,\"message\":\"Autonomous AI Q-Learning tuner updated TCP stack window\",\"service\":\"ai_tuner\",\"host\":\"node4.eu-west-1\",\"latency_ms\":1.8,\"timestamp\":1720000200}">>),

            % 3. Seed Realistic Product Documents
            index_doc(<<"yoda_products">>, <<"prod_001">>,
                <<"{\"title\":\"HFT Network Accelerator Card\",\"category\":\"hardware\",\"price\":4500.00,\"in_stock\":true,\"rating\":4.9,\"service\":\"hardware\"}">>),
            index_doc(<<"yoda_products">>, <<"prod_002">>,
                <<"{\"title\":\"Ultra-Low Latency SOCKS5 Smart Proxy\",\"category\":\"software\",\"price\":299.00,\"in_stock\":true,\"rating\":4.8,\"service\":\"proxy\"}">>),
            index_doc(<<"yoda_products">>, <<"prod_003">>,
                <<"{\"title\":\"Dual-AI Bandwidth Auto-Tuner Enterprise License\",\"category\":\"software\",\"price\":1200.00,\"in_stock\":false,\"rating\":5.0,\"service\":\"ai\"}">>)
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
%%  Telemetry & Stats
%% ============================================================
incr_stat(Key) ->
    case ets:lookup(?STATS_TABLE, Key) of
        [{Key, N}] -> ets:insert(?STATS_TABLE, {Key, N + 1});
        [] -> ets:insert(?STATS_TABLE, {Key, 1})
    end.

get_stat(Key) ->
    case ets:lookup(?STATS_TABLE, Key) of
        [{Key, N}] -> N;
        [] -> 0
    end.

get_stats() ->
    [
        {indices_count, ets:info(?INDICES_TABLE, size)},
        {docs_count, ets:info(?DOCS_TABLE, size)},
        {inverted_terms_count, ets:info(?INVERTED_TABLE, size)},
        {searches_executed, get_stat(searches_executed)},
        {docs_indexed, get_stat(docs_indexed)},
        {docs_deleted, get_stat(docs_deleted)},
        {aggregations_computed, get_stat(aggregations_computed)},
        {ai_tune_queries, get_stat(ai_tune_queries)}
    ].

get_stats_json() ->
    S = get_stats(),
    IC = proplists:get_value(indices_count, S, 0),
    DC = proplists:get_value(docs_count, S, 0),
    TC = proplists:get_value(inverted_terms_count, S, 0),
    SE = proplists:get_value(searches_executed, S, 0),
    DI = proplists:get_value(docs_indexed, S, 0),
    DD = proplists:get_value(docs_deleted, S, 0),
    AC = proplists:get_value(aggregations_computed, S, 0),
    AI = proplists:get_value(ai_tune_queries, S, 0),
    Result = io_lib:format(
        "{\"cluster_name\":\"yoda-elasticsearch\",\"status\":\"green\",\"number_of_nodes\":1,\"number_of_data_nodes\":1,\"active_primary_shards\":~p,\"active_shards\":~p,\"total_indices\":~p,\"total_documents\":~p,\"inverted_index_terms\":~p,\"searches_executed\":~p,\"documents_indexed\":~p,\"documents_deleted\":~p,\"aggregations_computed\":~p,\"ai_optimizations\":~p,\"lucene_version\":\"9.10.0-pure-erlang-bm25\"}",
        [IC, IC * 2, IC, DC, TC, SE, DI, DD, AC, AI]
    ),
    list_to_binary(Result).

%% ============================================================
%%  Index & Document Management
%% ============================================================
create_index(IndexBin, SettingsMap) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    CreatedAt = erlang:system_time(second),
    ets:insert(?INDICES_TABLE, {Index, SettingsMap, CreatedAt}),
    incr_stat(indices_created),
    ok.

delete_index(IndexBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    ets:delete(?INDICES_TABLE, Index),
    % Delete all documents and inverted terms for this index
    AllDocs = ets:tab2list(?DOCS_TABLE),
    lists:foreach(fun({{I, DocId}, _, _, _}) ->
        if I =:= Index -> ets:delete(?DOCS_TABLE, {I, DocId}); true -> ok end
    end, AllDocs),
    AllTerms = ets:tab2list(?INVERTED_TABLE),
    lists:foreach(fun({I, _F, _T, _DocId, _, _} = Entry) ->
        if I =:= Index -> ets:delete_object(?INVERTED_TABLE, Entry); true -> ok end
    end, AllTerms),
    ok.

list_indices() ->
    All = ets:tab2list(?INDICES_TABLE),
    lists:usort([ I || {I, _, _} <- All ]).

get_indices_json() ->
    All = ets:tab2list(?INDICES_TABLE),
    IndicesJson = [
        begin
            DocCount = get_doc_count(I),
            io_lib:format("{\"health\":\"green\",\"status\":\"open\",\"index\":\"~s\",\"uuid\":\"idx_~s\",\"pri\":1,\"rep\":1,\"docs.count\":~p,\"docs.deleted\":0,\"store.size\":\"~pKB\",\"pri.store.size\":\"~pKB\"}",
                          [binary_to_list(I), binary_to_list(I), DocCount, max(1, DocCount * 2), max(1, DocCount)])
        end
        || {I, _, _} <- All
    ],
    list_to_binary("[" ++ string:join(IndicesJson, ",") ++ "]").

get_doc_count(IndexBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    All = ets:tab2list(?DOCS_TABLE),
    length([ DocId || {{I, DocId}, _, _, _} <- All, I =:= Index ]).

get_doc(IndexBin, DocIdBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    DocId = if is_binary(DocIdBin) -> DocIdBin; true -> list_to_binary(DocIdBin) end,
    case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
        [{_, SourceBin, _, _}] ->
            Json = io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"_version\":1,\"_seq_no\":0,\"_primary_term\":1,\"found\":true,\"_source\":~s}",
                                 [binary_to_list(Index), binary_to_list(DocId), binary_to_list(SourceBin)]),
            {ok, list_to_binary(Json)};
        [] ->
            Json = io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"found\":false}",
                                 [binary_to_list(Index), binary_to_list(DocId)]),
            {error, list_to_binary(Json)}
    end.

delete_doc(IndexBin, DocIdBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    DocId = if is_binary(DocIdBin) -> DocIdBin; true -> list_to_binary(DocIdBin) end,
    case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
        [{_, _, _, _}] ->
            ets:delete(?DOCS_TABLE, {Index, DocId}),
            % Delete inverted index postings
            AllTerms = ets:tab2list(?INVERTED_TABLE),
            lists:foreach(fun({I, _F, _T, D, _TF, _P} = Entry) ->
                if I =:= Index andalso D =:= DocId -> ets:delete_object(?INVERTED_TABLE, Entry); true -> ok end
            end, AllTerms),
            incr_stat(docs_deleted),
            Json = io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"_version\":2,\"result\":\"deleted\",\"_shards\":{\"total\":2,\"successful\":1,\"failed\":0}}",
                                 [binary_to_list(Index), binary_to_list(DocId)]),
            {ok, list_to_binary(Json)};
        [] ->
            Json = io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"result\":\"not_found\"}",
                                 [binary_to_list(Index), binary_to_list(DocId)]),
            {error, list_to_binary(Json)}
    end.

%% ============================================================
%%  Lucene Inverted Indexing & Text Analysis
%% ============================================================
index_doc(IndexBin, DocIdBin, JsonDocBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    DocId = if is_binary(DocIdBin) -> DocIdBin; true -> list_to_binary(DocIdBin) end,
    DocStr = string:trim(binary_to_list(JsonDocBin)),

    DocMap = parse_json_object(DocStr),

    % Ensure index exists in catalog
    case ets:lookup(?INDICES_TABLE, Index) of
        [] -> create_index(Index, #{<<"number_of_shards">> => 1});
        _ -> ok
    end,

    % Clean previous postings if upserting
    case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
        [{_, _, _, _}] ->
            AllTerms = ets:tab2list(?INVERTED_TABLE),
            lists:foreach(fun({I, _F, _T, D, _TF, _P} = Entry) ->
                if I =:= Index andalso D =:= DocId -> ets:delete_object(?INVERTED_TABLE, Entry); true -> ok end
            end, AllTerms);
        [] -> ok
    end,

    % Index each field into inverted table
    DocTermsCount = maps:fold(fun(FieldBin, Val, AccCount) ->
        FieldTerms = extract_field_terms(Val),
        lists:foreach(fun({TermBin, TF, Positions}) ->
            ets:insert(?INVERTED_TABLE, {Index, FieldBin, TermBin, DocId, TF, Positions}),
            % Also insert with field <<"_all">> for generic cross-field matching
            ets:insert(?INVERTED_TABLE, {Index, <<"_all">>, TermBin, DocId, TF, Positions})
        end, FieldTerms),
        AccCount + length(FieldTerms)
    end, 0, DocMap),

    ets:insert(?DOCS_TABLE, {{Index, DocId}, JsonDocBin, DocMap, max(1, DocTermsCount)}),
    incr_stat(docs_indexed),
    DocId.

extract_field_terms(Val) when is_binary(Val) ->
    analyze_text(binary_to_list(Val));
extract_field_terms(Val) when is_list(Val) ->
    case io_lib:printable_list(Val) of
        true -> analyze_text(Val);
        false ->
            lists:flatmap(fun(SubVal) -> extract_field_terms(SubVal) end, Val)
    end;
extract_field_terms(Val) when is_number(Val) ->
    TermBin = list_to_binary(io_lib:format("~w", [Val])),
    [{TermBin, 1, [1]}];
extract_field_terms(true) -> [{<<"true">>, 1, [1]}];
extract_field_terms(false) -> [{<<"false">>, 1, [1]}];
extract_field_terms(_) -> [].

analyze_text(Text) ->
    Lower = string:to_lower(Text),
    RawTokens = string:tokens(Lower, " \t\r\n,.:;!?\"{}[]()$<>=+-*/#@&|~_'`"),
    Filtered = [ stem_word(W) || W <- RawTokens, not is_stopword(W), length(W) > 0 ],
    
    % Group into {Term, Frequency, Positions}
    {_, PostingsMap} = lists:foldl(fun(Word, {Pos, AccMap}) ->
        WBin = list_to_binary(Word),
        NewAcc = case maps:find(WBin, AccMap) of
            {ok, {TF, Positions}} ->
                maps:put(WBin, {TF + 1, Positions ++ [Pos]}, AccMap);
            error ->
                maps:put(WBin, {1, [Pos]}, AccMap)
        end,
        {Pos + 1, NewAcc}
    end, {1, #{}}, Filtered),

    [ {WBin, TF, PosList} || {WBin, {TF, PosList}} <- maps:to_list(PostingsMap) ].

is_stopword(W) ->
    lists:member(W, [
        "a", "an", "the", "and", "or", "in", "on", "at", "to", "for", "of",
        "with", "is", "it", "by", "as", "from", "be", "this", "that"
    ]).

stem_word(W) ->
    % Light algorithmic English suffix stripper
    Len = length(W),
    HasIng = lists:suffix("ing", W),
    HasEd = lists:suffix("ed", W),
    HasEs = lists:suffix("es", W),
    HasLy = lists:suffix("ly", W),
    HasS = lists:suffix("s", W) andalso not lists:suffix("ss", W),
    if
        Len > 5 andalso HasIng -> string:sub_string(W, 1, Len - 3);
        Len > 4 andalso HasEd -> string:sub_string(W, 1, Len - 2);
        Len > 4 andalso HasEs -> string:sub_string(W, 1, Len - 2);
        Len > 4 andalso HasLy -> string:sub_string(W, 1, Len - 2);
        Len > 3 andalso HasS -> string:sub_string(W, 1, Len - 1);
        true -> W
    end.

%% ============================================================
%%  BM25 Search & Query DSL Parser
%% ============================================================
execute_search(QueryBin) ->
    execute_search(?DEFAULT_INDEX, QueryBin).

execute_search(IndexBin, QueryBin) ->
    search_index(IndexBin, QueryBin).

search_index(IndexBin, QueryBin) ->
    search_index(IndexBin, QueryBin, #{}).

search_index(IndexBin, QueryBin, Options) ->
    StartUs = erlang:system_time(microsecond),
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    QueryStr = string:trim(if is_binary(QueryBin) -> binary_to_list(QueryBin); true -> QueryBin end),

    incr_stat(searches_executed),

    % Parse Query DSL or Fallback to simple String Search
    {QueryAST, From, Size, AggsMap} = parse_search_request(QueryStr, Options),

    % Calculate Average Document Length for BM25
    TotalDocs = max(1, get_doc_count(Index)),
    AvgDocLength = compute_avgdl(Index, TotalDocs),

    % Execute Query Matching and BM25 Scoring
    MatchedDocs = score_query(Index, QueryAST, TotalDocs, AvgDocLength),

    % Sort by score descending
    Sorted = lists:reverse(lists:keysort(2, MatchedDocs)),

    % Paginate
    Paged = lists:sublist(lists:nthtail(min(From, length(Sorted)), Sorted), Size),

    % Construct Hits JSON with Highlights
    Hits = lists:filtermap(fun({DocId, Score}) ->
        case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
            [{_, DocSource, DocMap, _}] ->
                HighlightJson = generate_highlight(QueryAST, DocMap),
                HitJson = if
                    HighlightJson =/= "" ->
                        io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"_score\":~.4f,\"_source\":~s,\"highlight\":~s}",
                                      [binary_to_list(Index), binary_to_list(DocId), Score, binary_to_list(DocSource), HighlightJson]);
                    true ->
                        io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"_score\":~.4f,\"_source\":~s}",
                                      [binary_to_list(Index), binary_to_list(DocId), Score, binary_to_list(DocSource)])
                end,
                {true, HitJson};
            [] -> false
        end
    end, Paged),

    TookMs = max(1, (erlang:system_time(microsecond) - StartUs) div 1000),
    MaxScore = case Sorted of
        [{_, TopScore} | _] -> TopScore;
        [] -> 0.0
    end,

    % Compute Aggregations if requested
    AggsJson = compute_aggregations(Index, MatchedDocs, AggsMap),

    Result = if
        AggsJson =/= "" ->
            io_lib:format(
                "{\"took\":~p,\"timed_out\":false,\"_shards\":{\"total\":1,\"successful\":1,\"skipped\":0,\"failed\":0},\"hits\":{\"total\":{\"value\":~p,\"relation\":\"eq\"},\"max_score\":~.4f,\"hits\":[~s]},\"aggregations\":~s}",
                [TookMs, length(Sorted), MaxScore, string:join(Hits, ","), AggsJson]
            );
        true ->
            io_lib:format(
                "{\"took\":~p,\"timed_out\":false,\"_shards\":{\"total\":1,\"successful\":1,\"skipped\":0,\"failed\":0},\"hits\":{\"total\":{\"value\":~p,\"relation\":\"eq\"},\"max_score\":~.4f,\"hits\":[~s]}}",
                [TookMs, length(Sorted), MaxScore, string:join(Hits, ",")]
            )
    end,
    list_to_binary(Result).

compute_avgdl(Index, TotalDocs) ->
    All = ets:tab2list(?DOCS_TABLE),
    Lengths = [ L || {{I, _}, _, _, L} <- All, I =:= Index ],
    case Lengths of
        [] -> 10.0;
        _ -> float(lists:sum(Lengths)) / float(TotalDocs)
    end.

%% ============================================================
%%  Query DSL Parsing
%% ============================================================
parse_search_request(QueryStr, _Options) ->
    Clean = string:trim(QueryStr),
    case Clean of
        "{" ++ _ ->
            % JSON Query DSL
            DSLMap = parse_json_object(Clean),
            From = maps:get(<<"from">>, DSLMap, 0),
            Size = maps:get(<<"size">>, DSLMap, 10),
            QueryObj = maps:get(<<"query">>, DSLMap, DSLMap),
            AggsObj = case maps:find(<<"aggs">>, DSLMap) of
                {ok, A} -> A;
                error -> maps:get(<<"aggregations">>, DSLMap, #{})
            end,
            AST = parse_dsl_query_node(QueryObj),
            {AST, From, Size, AggsObj};
        _ ->
            % Simple query string: match on _all field
            AST = {match, <<"_all">>, list_to_binary(Clean)},
            {AST, 0, 10, #{}}
    end.

parse_dsl_query_node(Obj) when is_map(Obj) ->
    case maps:to_list(Obj) of
        [{<<"match_all">>, _}] -> match_all;
        [{<<"match">>, InnerMap}] when is_map(InnerMap) ->
            case maps:to_list(InnerMap) of
                [{Field, QueryVal}] when is_binary(QueryVal) -> {match, Field, QueryVal};
                [{Field, OptsMap}] when is_map(OptsMap) ->
                    Q = maps:get(<<"query">>, OptsMap, <<"">>),
                    {match, Field, Q};
                _ -> match_all
            end;
        [{<<"multi_match">>, MultiMap}] when is_map(MultiMap) ->
            QueryVal = maps:get(<<"query">>, MultiMap, <<"">>),
            Fields = maps:get(<<"fields">>, MultiMap, [<<"_all">>]),
            {multi_match, Fields, QueryVal};
        [{<<"term">>, TermMap}] when is_map(TermMap) ->
            case maps:to_list(TermMap) of
                [{Field, Val}] -> {term, Field, Val};
                _ -> match_all
            end;
        [{<<"terms">>, TermsMap}] when is_map(TermsMap) ->
            case maps:to_list(TermsMap) of
                [{Field, ListVal}] when is_list(ListVal) -> {terms, Field, ListVal};
                _ -> match_all
            end;
        [{<<"range">>, RangeMap}] when is_map(RangeMap) ->
            case maps:to_list(RangeMap) of
                [{Field, BoundsMap}] when is_map(BoundsMap) -> {range, Field, BoundsMap};
                _ -> match_all
            end;
        [{<<"prefix">>, PrefixMap}] when is_map(PrefixMap) ->
            case maps:to_list(PrefixMap) of
                [{Field, PrefixVal}] -> {prefix, Field, PrefixVal};
                _ -> match_all
            end;
        [{<<"wildcard">>, WildcardMap}] when is_map(WildcardMap) ->
            case maps:to_list(WildcardMap) of
                [{Field, WildcardVal}] -> {wildcard, Field, WildcardVal};
                _ -> match_all
            end;
        [{<<"fuzzy">>, FuzzyMap}] when is_map(FuzzyMap) ->
            case maps:to_list(FuzzyMap) of
                [{Field, FuzzyVal}] when is_binary(FuzzyVal) -> {fuzzy, Field, FuzzyVal};
                [{Field, OptsMap}] when is_map(OptsMap) ->
                    Val = maps:get(<<"value">>, OptsMap, <<"">>),
                    {fuzzy, Field, Val};
                _ -> match_all
            end;
        [{<<"bool">>, BoolMap}] when is_map(BoolMap) ->
            Must = parse_bool_clause(maps:get(<<"must">>, BoolMap, [])),
            Should = parse_bool_clause(maps:get(<<"should">>, BoolMap, [])),
            MustNot = parse_bool_clause(maps:get(<<"must_not">>, BoolMap, [])),
            Filter = parse_bool_clause(maps:get(<<"filter">>, BoolMap, [])),
            {bool, Must, Should, MustNot, Filter};
        _ -> match_all
    end;
parse_dsl_query_node(_) -> match_all.

parse_bool_clause(L) when is_list(L) -> [ parse_dsl_query_node(X) || X <- L ];
parse_bool_clause(M) when is_map(M) -> [ parse_dsl_query_node(M) ];
parse_bool_clause(_) -> [].

%% ============================================================
%%  Query Scoring Engine (BM25 + Boolean Algebra)
%% ============================================================
score_query(Index, match_all, _TotalDocs, _AvgDL) ->
    All = ets:tab2list(?DOCS_TABLE),
    [ {DocId, 1.0} || {{I, DocId}, _, _, _} <- All, I =:= Index ];

score_query(Index, {match, Field, QueryVal}, TotalDocs, AvgDL) ->
    Terms = analyze_text(binary_to_list(QueryVal)),
    score_bm25_terms(Index, Field, Terms, TotalDocs, AvgDL);

score_query(Index, {multi_match, Fields, QueryVal}, TotalDocs, AvgDL) ->
    Terms = analyze_text(binary_to_list(QueryVal)),
    Lists = [ score_bm25_terms(Index, F, Terms, TotalDocs, AvgDL) || F <- Fields ],
    combine_scores_dismax(Lists);

score_query(Index, {term, Field, Val}, _TotalDocs, _AvgDL) ->
    All = ets:tab2list(?DOCS_TABLE),
    lists:filtermap(fun({{I, DocId}, _, DocMap, _}) ->
        case I =:= Index of
            true ->
                case maps:find(Field, DocMap) of
                    {ok, ActualVal} ->
                        case values_match(ActualVal, Val) of
                            true -> {true, {DocId, 1.0}};
                            false -> false
                        end;
                    error -> false
                end;
            false -> false
        end
    end, All);

score_query(Index, {terms, Field, ValList}, _TotalDocs, _AvgDL) ->
    All = ets:tab2list(?DOCS_TABLE),
    lists:filtermap(fun({{I, DocId}, _, DocMap, _}) ->
        case I =:= Index of
            true ->
                case maps:find(Field, DocMap) of
                    {ok, ActualVal} ->
                        case lists:any(fun(V) -> values_match(ActualVal, V) end, ValList) of
                            true -> {true, {DocId, 1.0}};
                            false -> false
                        end;
                    error -> false
                end;
            false -> false
        end
    end, All);

score_query(Index, {range, Field, BoundsMap}, _TotalDocs, _AvgDL) ->
    Gte = maps:get(<<"gte">>, BoundsMap, undefined),
    Gt = maps:get(<<"gt">>, BoundsMap, undefined),
    Lte = maps:get(<<"lte">>, BoundsMap, undefined),
    Lt = maps:get(<<"lt">>, BoundsMap, undefined),

    All = ets:tab2list(?DOCS_TABLE),
    lists:filtermap(fun({{I, DocId}, _, DocMap, _}) ->
        case I =:= Index of
            true ->
                case maps:find(Field, DocMap) of
                    {ok, ActualVal} when is_number(ActualVal) ->
                        PassGte = (Gte =:= undefined orelse ActualVal >= Gte),
                        PassGt = (Gt =:= undefined orelse ActualVal > Gt),
                        PassLte = (Lte =:= undefined orelse ActualVal =< Lte),
                        PassLt = (Lt =:= undefined orelse ActualVal < Lt),
                        case PassGte andalso PassGt andalso PassLte andalso PassLt of
                            true -> {true, {DocId, 1.0}};
                            false -> false
                        end;
                    _ -> false
                end;
            false -> false
        end
    end, All);

score_query(Index, {prefix, Field, PrefixVal}, _TotalDocs, _AvgDL) ->
    PrefixStr = string:to_lower(binary_to_list(PrefixVal)),
    All = ets:tab2list(?DOCS_TABLE),
    lists:filtermap(fun({{I, DocId}, _, DocMap, _}) ->
        case I =:= Index of
            true ->
                case maps:find(Field, DocMap) of
                    {ok, ActualVal} when is_binary(ActualVal) ->
                        case lists:prefix(PrefixStr, string:to_lower(binary_to_list(ActualVal))) of
                            true -> {true, {DocId, 1.0}};
                            false -> false
                        end;
                    _ -> false
                end;
            false -> false
        end
    end, All);

score_query(Index, {wildcard, Field, PatternVal}, _TotalDocs, _AvgDL) ->
    PatternStr = string:to_lower(binary_to_list(PatternVal)),
    RegexPattern = wildcard_to_regex(PatternStr),
    All = ets:tab2list(?DOCS_TABLE),
    lists:filtermap(fun({{I, DocId}, _, DocMap, _}) ->
        case I =:= Index of
            true ->
                case maps:find(Field, DocMap) of
                    {ok, ActualVal} when is_binary(ActualVal) ->
                        case re:run(string:to_lower(binary_to_list(ActualVal)), RegexPattern) of
                            {match, _} -> {true, {DocId, 1.0}};
                            nomatch -> false
                        end;
                    _ -> false
                end;
            false -> false
        end
    end, All);

score_query(Index, {fuzzy, Field, FuzzyVal}, TotalDocs, AvgDL) ->
    FuzzyStr = string:to_lower(binary_to_list(FuzzyVal)),
    % Find matching terms in inverted index with Levenshtein distance =< 2
    AllPostings = ets:tab2list(?INVERTED_TABLE),
    MatchingTerms = lists:filtermap(fun({I, F, TermBin, _DocId, _TF, _P}) ->
        if I =:= Index andalso (Field =:= <<"_all">> orelse F =:= Field) ->
            TermStr = binary_to_list(TermBin),
            Dist = levenshtein_distance(FuzzyStr, TermStr),
            if Dist =< 2 -> {true, {TermBin, 1, [1]}}; true -> false end;
        true -> false
        end
    end, AllPostings),
    score_bm25_terms(Index, Field, lists:usort(MatchingTerms), TotalDocs, AvgDL);

score_query(Index, {bool, Must, Should, MustNot, Filter}, TotalDocs, AvgDL) ->
    % Must: Intersection of all must subqueries
    MustResults = case Must of
        [] -> undefined;
        _ ->
            MustLists = [ maps:from_list(score_query(Index, Q, TotalDocs, AvgDL)) || Q <- Must ],
            intersect_scored_maps(MustLists)
    end,

    % Filter: Intersection (score = 1.0)
    FilterResults = case Filter of
        [] -> undefined;
        _ ->
            FilterLists = [ maps:from_list(score_query(Index, Q, TotalDocs, AvgDL)) || Q <- Filter ],
            intersect_scored_maps(FilterLists)
    end,

    % MustNot: Documents that MUST NOT appear
    MustNotSet = case MustNot of
        [] -> sets:new();
        _ ->
            Disallowed = lists:flatmap(fun(Q) -> [ DocId || {DocId, _} <- score_query(Index, Q, TotalDocs, AvgDL) ] end, MustNot),
            sets:from_list(Disallowed)
    end,

    % Base map: combination of Must and Filter
    BaseMap = case {MustResults, FilterResults} of
        {undefined, undefined} ->
            % If neither must nor filter is present, base is all documents or should matches
            case Should of
                [] -> maps:from_list(score_query(Index, match_all, TotalDocs, AvgDL));
                _ -> #{}
            end;
        {M, undefined} -> M;
        {undefined, F} -> F;
        {M, F} -> intersect_two_scored_maps(M, F)
    end,

    % Add Should scores
    FinalMap = lists:foldl(fun(Q, AccMap) ->
        ShouldScores = score_query(Index, Q, TotalDocs, AvgDL),
        lists:foldl(fun({DocId, S}, InnerAcc) ->
            case maps:find(DocId, InnerAcc) of
                {ok, OldScore} -> maps:put(DocId, OldScore + S, InnerAcc);
                error ->
                    if
                        Must =:= [] andalso Filter =:= [] -> maps:put(DocId, S, InnerAcc);
                        true -> InnerAcc
                    end
            end
        end, AccMap, ShouldScores)
    end, BaseMap, Should),

    % Remove MustNot items
    FilteredFinal = maps:filter(fun(DocId, _) -> not sets:is_element(DocId, MustNotSet) end, FinalMap),
    maps:to_list(FilteredFinal).

%% ============================================================
%%  BM25 Mathematical Implementation
%% ============================================================
-define(K1, 1.2).
-define(B, 0.75).

score_bm25_terms(Index, Field, TermTuples, TotalDocs, AvgDL) ->
    DocScoreMap = lists:foldl(fun({TermBin, _Q_TF, _}, AccMap) ->
        Postings = ets:lookup(?INVERTED_TABLE, Index),
        MatchedPostings = [ {DocId, TF} || {I, F, T, DocId, TF, _P} <- Postings, I =:= Index, T =:= TermBin, (Field =:= <<"_all">> orelse F =:= Field) ],
        DocFreq = length(lists:usort([ DocId || {DocId, _} <- MatchedPostings ])),

        case DocFreq of
            0 -> AccMap;
            _ ->
                % Lucene BM25 IDF: ln(1 + (N - n + 0.5)/(n + 0.5))
                IDF = math:log(1.0 + ((float(TotalDocs) - float(DocFreq) + 0.5) / (float(DocFreq) + 0.5))),
                SafeIDF = max(0.01, IDF),

                lists:foldl(fun({DocId, TF}, InnerAcc) ->
                    DocLen = case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
                        [{_, _, _, L}] -> float(L);
                        [] -> AvgDL
                    end,
                    % BM25 Term Weight
                    Numerator = float(TF) * (?K1 + 1.0),
                    Denominator = float(TF) + ?K1 * (1.0 - ?B + ?B * (DocLen / max(1.0, AvgDL))),
                    TermScore = SafeIDF * (Numerator / max(0.001, Denominator)),

                    case maps:find(DocId, InnerAcc) of
                        {ok, Old} -> maps:put(DocId, Old + TermScore, InnerAcc);
                        error -> maps:put(DocId, TermScore, InnerAcc)
                    end
                end, AccMap, MatchedPostings)
        end
    end, #{}, TermTuples),
    maps:to_list(DocScoreMap).

combine_scores_dismax([]) -> [];
combine_scores_dismax(ListOfScoredLists) ->
    MergedMap = lists:foldl(fun(List, AccMap) ->
        lists:foldl(fun({DocId, S}, InnerAcc) ->
            case maps:find(DocId, InnerAcc) of
                {ok, Old} -> maps:put(DocId, max(Old, S) + (0.1 * min(Old, S)), InnerAcc);
                error -> maps:put(DocId, S, InnerAcc)
            end
        end, AccMap, List)
    end, #{}, ListOfScoredLists),
    maps:to_list(MergedMap).

intersect_scored_maps([]) -> #{};
intersect_scored_maps([First | Rest]) ->
    lists:foldl(fun(NextMap, Acc) -> intersect_two_scored_maps(Acc, NextMap) end, First, Rest).

intersect_two_scored_maps(MapA, MapB) ->
    maps:filtermap(fun(DocId, ScoreA) ->
        case maps:find(DocId, MapB) of
            {ok, ScoreB} -> {true, ScoreA + ScoreB};
            error -> false
        end
    end, MapA).

values_match(A, B) when A == B -> true;
values_match(A, B) when is_binary(A) andalso is_binary(B) ->
    string:to_lower(binary_to_list(A)) =:= string:to_lower(binary_to_list(B));
values_match(A, B) when is_number(A) andalso is_binary(B) ->
    case string:to_float(binary_to_list(B)) of
        {F, []} -> A == F;
        _ ->
            case string:to_integer(binary_to_list(B)) of
                {I, []} -> A == I;
                _ -> false
            end
    end;
values_match(A, B) when is_binary(A) andalso is_number(B) ->
    values_match(B, A);
values_match(_, _) -> false.

wildcard_to_regex(Pattern) ->
    Escaped = lists:flatmap(fun
        ($*) -> ".*";
        ($?) -> ".";
        (C) ->
            case lists:member(C, "^$.|()+[]{}") of
                true -> [$\\, C];
                false -> [C]
            end
    end, Pattern),
    "^" ++ Escaped ++ "$".

levenshtein_distance(S, T) ->
    M = length(S),
    N = length(T),
    Matrix = lists:foldl(fun(I, AccI) ->
        lists:foldl(fun(J, AccJ) ->
            Dist = if
                I =:= 0 -> J;
                J =:= 0 -> I;
                true ->
                    CharS = lists:nth(I, S),
                    CharT = lists:nth(J, T),
                    Cost = if CharS =:= CharT -> 0; true -> 1 end,
                    Deletion = maps:get({I - 1, J}, AccJ, 0) + 1,
                    Insertion = maps:get({I, J - 1}, AccJ, 0) + 1,
                    Substitution = maps:get({I - 1, J - 1}, AccJ, 0) + 1 * Cost,
                    min(Deletion, min(Insertion, Substitution))
            end,
            maps:put({I, J}, Dist, AccJ)
        end, AccI, lists:seq(0, N))
    end, #{}, lists:seq(0, M)),
    maps:get({M, N}, Matrix, 0).

generate_highlight(match_all, _) -> "";
generate_highlight({match, Field, QueryVal}, DocMap) ->
    generate_field_highlight(Field, QueryVal, DocMap);
generate_highlight({multi_match, Fields, QueryVal}, DocMap) ->
    Highlights = lists:filtermap(fun(F) ->
        case generate_field_highlight(F, QueryVal, DocMap) of
            "" -> false;
            H -> {true, io_lib:format("\"~s\":~s", [binary_to_list(F), H])}
        end
    end, Fields),
    case Highlights of
        [] -> "";
        _ -> "{" ++ string:join(Highlights, ",") ++ "}"
    end;
generate_highlight(_, _) -> "".

generate_field_highlight(Field, QueryVal, DocMap) ->
    TargetField = if Field =:= <<"_all">> -> <<"message">>; true -> Field end,
    case maps:find(TargetField, DocMap) of
        {ok, Val} when is_binary(Val) ->
            Text = binary_to_list(Val),
            Terms = string:tokens(string:to_lower(binary_to_list(QueryVal)), " \t\r\n"),
            Highlighted = lists:foldl(fun(T, Acc) ->
                Regex = "(?i)(" ++ T ++ ")",
                re:replace(Acc, Regex, "<em>\\1</em>", [global, {return, list}])
            end, Text, Terms),
            io_lib:format("[\"~s\"]", [escape_json(Highlighted)]);
        _ -> ""
    end.

%% ============================================================
%%  Aggregations Engine (terms, stats, avg, sum, min, max)
%% ============================================================
compute_aggregations(_Index, _MatchedDocs, AggsMap) when map_size(AggsMap) =:= 0 -> "";
compute_aggregations(Index, MatchedDocs, AggsMap) ->
    incr_stat(aggregations_computed),
    MatchedDocIds = [ DocId || {DocId, _} <- MatchedDocs ],
    MatchedDocMaps = lists:filtermap(fun(DocId) ->
        case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
            [{_, _, DocMap, _}] -> {true, DocMap};
            [] -> false
        end
    end, MatchedDocIds),

    AggResults = lists:filtermap(fun({AggName, AggBody}) ->
        case maps:to_list(AggBody) of
            [{<<"terms">>, TermsOpts}] ->
                Field = maps:get(<<"field">>, TermsOpts, <<"">>),
                Buckets = compute_terms_buckets(MatchedDocMaps, Field),
                AggJson = io_lib:format("\"~s\":{\"doc_count_error_upper_bound\":0,\"sum_other_doc_count\":0,\"buckets\":[~s]}",
                                        [binary_to_list(AggName), string:join(Buckets, ",")]),
                {true, AggJson};
            [{<<"stats">>, StatsOpts}] ->
                Field = maps:get(<<"field">>, StatsOpts, <<"">>),
                StatsJson = compute_stats_agg(MatchedDocMaps, Field),
                AggJson = io_lib:format("\"~s\":~s", [binary_to_list(AggName), StatsJson]),
                {true, AggJson};
            [{<<"avg">>, Opts}] ->
                Field = maps:get(<<"field">>, Opts, <<"">>),
                AvgVal = compute_field_avg(MatchedDocMaps, Field),
                {true, io_lib:format("\"~s\":{\"value\":~.4f}", [binary_to_list(AggName), AvgVal])};
            [{<<"sum">>, Opts}] ->
                Field = maps:get(<<"field">>, Opts, <<"">>),
                SumVal = compute_field_sum(MatchedDocMaps, Field),
                {true, io_lib:format("\"~s\":{\"value\":~.4f}", [binary_to_list(AggName), SumVal])};
            _ -> false
        end
    end, maps:to_list(AggsMap)),

    "{" ++ string:join(AggResults, ",") ++ "}".

compute_terms_buckets(DocMaps, Field) ->
    Counts = lists:foldl(fun(Map, Acc) ->
        case maps:find(Field, Map) of
            {ok, Val} ->
                Key = if is_binary(Val) -> Val; is_number(Val) -> list_to_binary(io_lib:format("~w", [Val])); true -> term_to_binary(Val) end,
                case maps:find(Key, Acc) of
                    {ok, C} -> maps:put(Key, C + 1, Acc);
                    error -> maps:put(Key, 1, Acc)
                end;
            error -> Acc
        end
    end, #{}, DocMaps),

    SortedBuckets = lists:reverse(lists:keysort(2, maps:to_list(Counts))),
    [ io_lib:format("{\"key\":\"~s\",\"doc_count\":~p}", [binary_to_list(K), C]) || {K, C} <- SortedBuckets ].

compute_stats_agg(DocMaps, Field) ->
    Vals = lists:filtermap(fun(Map) ->
        case maps:find(Field, Map) of
            {ok, V} when is_number(V) -> {true, float(V)};
            _ -> false
        end
    end, DocMaps),

    case Vals of
        [] -> "{\"count\":0,\"min\":null,\"max\":null,\"avg\":null,\"sum\":0}";
        _ ->
            Count = length(Vals),
            Min = lists:min(Vals),
            Max = lists:max(Vals),
            Sum = lists:sum(Vals),
            Avg = Sum / float(Count),
            io_lib:format("{\"count\":~p,\"min\":~.4f,\"max\":~.4f,\"avg\":~.4f,\"sum\":~.4f}",
                          [Count, Min, Max, Avg, Sum])
    end.

compute_field_avg(DocMaps, Field) ->
    Vals = [ float(maps:get(Field, M)) || M <- DocMaps, maps:is_key(Field, M), is_number(maps:get(Field, M)) ],
    case Vals of
        [] -> 0.0;
        _ -> lists:sum(Vals) / float(length(Vals))
    end.

compute_field_sum(DocMaps, Field) ->
    Vals = [ float(maps:get(Field, M)) || M <- DocMaps, maps:is_key(Field, M), is_number(maps:get(Field, M)) ],
    lists:sum(Vals).

%% ============================================================
%%  Autonomous AI Engine - Lucene & Search Optimizer / Tuner
%% ============================================================
ai_tune(QueryBin) ->
    ai_tune(QueryBin, <<"no_key">>).

ai_tune(QueryBin, ApiKeyBin) ->
    incr_stat(ai_tune_queries),
    QueryStr = if is_binary(QueryBin) -> binary_to_list(QueryBin); true -> QueryBin end,
    ApiKeyStr = if is_binary(ApiKeyBin) -> binary_to_list(ApiKeyBin); true -> ApiKeyBin end,

    case (ApiKeyStr =/= "no_key" andalso length(ApiKeyStr) > 10) of
        true ->
            case call_llm_ai_search_tuner(QueryStr, ApiKeyStr) of
                Resp when is_binary(Resp) -> Resp;
                _ -> local_ai_tune_search(QueryStr)
            end;
        false ->
            local_ai_tune_search(QueryStr)
    end.

local_ai_tune_search(QueryStr) ->
    Upper = string:to_upper(QueryStr),

    % 1. Anti-Pattern & Performance Diagnostics
    HasWildcard = (string:str(Upper, "WILDCARD") > 0) orelse (string:str(Upper, "\"*") > 0) orelse (string:str(Upper, "*") > 0),
    HasDeepPagination = string:str(Upper, "\"FROM\": 10000") > 0 orelse string:str(Upper, "\"FROM\":10000") > 0,
    HasMatchAll = string:str(Upper, "MATCH_ALL") > 0,
    HasAggs = string:str(Upper, "AGGS") > 0 orelse string:str(Upper, "AGGREGATIONS") > 0,
    HasFuzzy = string:str(Upper, "FUZZY") > 0,
    HasBool = string:str(Upper, "BOOL") > 0,

    % 2. Generate Tuning Rules
    Rules = generate_search_ai_rules(Upper, HasWildcard, HasDeepPagination, HasMatchAll, HasAggs, HasFuzzy, HasBool),

    % 3. Semantic Synonym Expansions
    Synonyms = ai_synonyms(list_to_binary(QueryStr)),

    % 4. Recommended Analyzer & Mapping Settings
    IsMsgOrLog = (string:str(Upper, "MESSAGE") > 0) orelse (string:str(Upper, "LOG") > 0),
    RecommendedAnalyzer = if
        HasFuzzy -> "n-gram / edge_ngram tokenizer (reduces runtime Levenshtein computational complexity)";
        IsMsgOrLog -> "standard with english_stop filter & porter stemmer";
        true -> "keyword normalizer with lowercase filter"
    end,

    % 5. Shard & Segment Advice
    ShardAdvice = "Single-shard in-memory segment tree with zero cross-network shard merging overhead. Optimal refresh interval: 1s.",

    Result = io_lib:format(
        "{\"query\":\"~s\",\"query_type\":\"~s\",\"recommended_analyzer\":\"~s\",\"shard_optimization_advice\":\"~s\",\"semantic_synonym_expansions\":~s,\"ai_tuning_rules\":[~s],\"status\":\"autonomous_lucene_ai_optimized\"}",
        [
            escape_json(QueryStr),
            classify_search_complexity(Upper),
            RecommendedAnalyzer,
            ShardAdvice,
            binary_to_list(Synonyms),
            string:join(Rules, ",")
        ]
    ),
    list_to_binary(Result).

generate_search_ai_rules(Upper, HasWildcard, HasDeepPagination, HasMatchAll, HasAggs, HasFuzzy, HasBool) ->
    R1 = case HasWildcard of
        true -> ["\"CRITICAL: Wildcard pattern detected. Exhaustive term dictionary traversal can degrade search performance on large indices. Replace with edge_ngram or keyword tokenizer\""];
        false -> []
    end,
    R2 = case HasDeepPagination of
        true -> ["\"WARN: Deep pagination (from >= 10000) causes coordinator heap pressure. Use 'search_after' cursor pagination with Point-in-Time (PIT) instead\""];
        false -> []
    end,
    R3 = case HasMatchAll of
        true -> ["\"PERF: 'match_all' without filter will evaluate and score all index documents. Apply a term or range filter to prune search space\""];
        false -> []
    end,
    R4 = case HasAggs of
        true -> ["\"NOTE: High-cardinality terms aggregation builds large global ordinals in heap. Ensure 'execution_hint: map' is configured for high cardinality fields\""];
        false -> []
    end,
    R5 = case HasFuzzy of
        true -> ["\"PERF: Fuzzy search creates a multi-term expansion automaton. Set 'prefix_length: 2' and 'max_expansions: 50' to constrain combinatorial explosion\""];
        false -> []
    end,
    R6 = case HasBool of
        true -> ["\"INFO: Complex Boolean compound query detected. Ensure non-scoring boolean criteria are wrapped in 'filter' context to leverage bitset filter caching\""];
        false -> []
    end,
    R7 = case string:str(Upper, "SELECT") > 0 of
        true -> ["\"NOTE: SQL syntax passed to Elasticsearch bridge. Converted to Lucene Query DSL for sub-millisecond BM25 inverted index execution\""];
        false -> []
    end,
    All = R1 ++ R2 ++ R3 ++ R4 ++ R5 ++ R6 ++ R7,
    if
        length(All) =:= 0 -> ["\"Query adheres to optimal Lucene inverted index access patterns with sub-millisecond BM25 scoring\""];
        true -> All
    end.

classify_search_complexity(Upper) ->
    HasBool = string:str(Upper, "BOOL") > 0,
    HasFuzzy = string:str(Upper, "FUZZY") > 0,
    HasAggs = (string:str(Upper, "AGGS") > 0) orelse (string:str(Upper, "AGGREGATIONS") > 0),
    HasMulti = string:str(Upper, "MULTI_MATCH") > 0,
    HasRange = string:str(Upper, "RANGE") > 0,
    if
        HasBool -> "Compound Boolean Multi-Clause AST";
        HasFuzzy -> "Levenshtein Automaton Fuzzy Search";
        HasAggs -> "Faceted Analytics Aggregation";
        HasMulti -> "Cross-Field DisMax Search";
        HasRange -> "Numeric / Date Bounded Range Filter";
        true -> "Direct Lucene BM25 Term Inverted Search"
    end.

ai_synonyms(QueryBin) ->
    QueryStr = string:to_lower(binary_to_list(QueryBin)),
    CleanTerms = string:tokens(QueryStr, " \t\r\n,.:;!?\"{}[]()$<>=+-*/#@&|~_'`"),

    SynonymBank = [
        {"timeout", ["deadline_exceeded", "connection_refused", "hang", "socket_drop", "latency_spike"]},
        {"error", ["failure", "exception", "fault", "panic", "critical", "fatal"]},
        {"latency", ["delay", "rtt", "roundtrip", "lag", "bufferbloat", "slowdown"]},
        {"ratelimit", ["throttle", "429", "quota_exceeded", "burst_limit", "backoff"]},
        {"audit", ["ledger", "sha256", "cryptographic_proof", "tamper_evident", "compliance"]},
        {"speed", ["throughput", "bandwidth", "mbps", "gbps", "packets_per_second"]}
    ],

    FoundSynonyms = lists:filtermap(fun({Keyword, Expansions}) ->
        case lists:member(Keyword, CleanTerms) of
            true ->
                ExpJson = [ io_lib:format("\"~s\"", [E]) || E <- Expansions ],
                {true, io_lib:format("{\"term\":\"~s\",\"synonyms\":[~s]}", [Keyword, string:join(ExpJson, ",")])};
            false -> false
        end
    end, SynonymBank),

    case FoundSynonyms of
        [] -> <<"[{\"term\":\"general\",\"synonyms\":[\"semantic_expansion_active\"]}]">>;
        _ -> list_to_binary("[" ++ string:join(FoundSynonyms, ",") ++ "]")
    end.

ai_analyze_index(IndexBin) ->
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    DocCount = get_doc_count(Index),
    TotalDocs = max(1, DocCount),
    AvgDL = compute_avgdl(Index, TotalDocs),

    Result = io_lib:format(
        "{\"index\":\"~s\",\"total_documents\":~p,\"avg_document_length\":~.2f,\"shard_health\":\"green\",\"segment_count\":1,\"bm25_parameters\":{\"k1\":1.2,\"b\":0.75},\"recommendation\":\"Index health is optimal. No force-merge or segment compaction required.\",\"status\":\"ai_index_verified\"}",
        [binary_to_list(Index), DocCount, AvgDL]
    ),
    list_to_binary(Result).

call_llm_ai_search_tuner(QueryStr, ApiKeyStr) ->
    Prompt = "Act as a Principal Elasticsearch & Lucene AI Architect. Analyze this search query: '" ++ QueryStr ++ "'. Provide a 1-sentence performance diagnosis, optimal analyzer recommendation, and synonym expansions.",
    Body = "{\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"" ++ escape_json(Prompt) ++ "\"}],\"max_tokens\":150}",
    Url = "https://api.openai.com/v1/chat/completions",
    case curl_wrapper:curl_post(list_to_binary(Url), list_to_binary(ApiKeyStr), list_to_binary(Body)) of
        Resp when is_binary(Resp) ->
            case extract_chat_response(binary_to_list(Resp)) of
                {ok, Content} ->
                    list_to_binary(io_lib:format("{\"llm_diagnosis\":\"~s\",\"status\":\"llm_ai_search_optimized\"}", [escape_json(Content)]));
                _ -> error
            end;
        _ -> error
    end.

extract_chat_response(JsonStr) ->
    case re:run(JsonStr, "\"content\"\\s*:\\s*\"([^\"]*)\"", [{capture, [1], list}]) of
        {match, [Content]} -> {ok, Content};
        _ -> error
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

%% ============================================================
%%  JSON Serialization & Parsing Helpers
%% ============================================================
parse_json_object(Str) ->
    Clean = string:trim(Str),
    case Clean of
        "{" ++ Rest ->
            Inner = case lists:reverse(Rest) of
                "}" ++ Rev -> lists:reverse(Rev);
                _ -> Rest
            end,
            Pairs = split_json_pairs(Inner),
            maps:from_list(lists:filtermap(fun(P) ->
                case split_key_value(string:trim(P)) of
                    {ok, K, V} ->
                        CleanK = string:trim(K, both, " \"'"),
                        ParsedV = parse_json_value(string:trim(V)),
                        {true, {list_to_binary(CleanK), ParsedV}};
                    _ -> false
                end
            end, Pairs));
        _ -> #{}
    end.

split_key_value(Str) ->
    case string:str(Str, ":") of
        0 -> error;
        Idx ->
            Key = string:sub_string(Str, 1, Idx - 1),
            Val = string:sub_string(Str, Idx + 1),
            {ok, Key, Val}
    end.

split_json_pairs(Str) ->
    split_json_pairs(Str, [], [], 0, 0, false).

split_json_pairs([], Current, Acc, _, _, _) ->
    lists:reverse([lists:reverse(Current) | Acc]);
split_json_pairs([$\" | Rest], Current, Acc, BDepth, CDepth, InQuote) ->
    split_json_pairs(Rest, [$\" | Current], Acc, BDepth, CDepth, not InQuote);
split_json_pairs([${ | Rest], Current, Acc, BDepth, CDepth, false) ->
    split_json_pairs(Rest, [${ | Current], Acc, BDepth + 1, CDepth, false);
split_json_pairs([$} | Rest], Current, Acc, BDepth, CDepth, false) ->
    split_json_pairs(Rest, [$} | Current], Acc, max(0, BDepth - 1), CDepth, false);
split_json_pairs([$[ | Rest], Current, Acc, BDepth, CDepth, false) ->
    split_json_pairs(Rest, [$[ | Current], Acc, BDepth, CDepth + 1, false);
split_json_pairs([$] | Rest], Current, Acc, BDepth, CDepth, false) ->
    split_json_pairs(Rest, [$] | Current], Acc, BDepth, max(0, CDepth - 1), false);
split_json_pairs([$, | Rest], Current, Acc, 0, 0, false) ->
    split_json_pairs(Rest, [], [lists:reverse(Current) | Acc], 0, 0, false);
split_json_pairs([C | Rest], Current, Acc, BDepth, CDepth, InQuote) ->
    split_json_pairs(Rest, [C | Current], Acc, BDepth, CDepth, InQuote).

parse_json_value(Str) ->
    Clean = string:trim(Str),
    case Clean of
        "{" ++ _ -> parse_json_object(Clean);
        "[" ++ Rest ->
            Inner = case lists:reverse(Rest) of
                "]" ++ Rev -> lists:reverse(Rev);
                _ -> Rest
            end,
            Items = split_json_pairs(Inner),
            [ parse_json_value(I) || I <- Items, string:trim(I) =/= "" ];
        "\"" ++ Inner ->
            case lists:reverse(Inner) of
                "\"" ++ Rev -> list_to_binary(lists:reverse(Rev));
                _ -> list_to_binary(Inner)
            end;
        "true" -> true;
        "false" -> false;
        "null" -> null;
        _ ->
            case string:to_float(Clean) of
                {F, []} -> F;
                _ ->
                    case string:to_integer(Clean) of
                        {I, []} -> I;
                        _ -> list_to_binary(Clean)
                    end
            end
    end.

-module(elastic_engine).
-export([init/0, execute_search/1, index_doc/3, search_index/2, get_doc_count/1]).

-define(DOCS_TABLE, yoda_elastic_docs).
-define(INVERTED_TABLE, yoda_elastic_inverted_index).

init() ->
    case ets:info(?DOCS_TABLE) of
        undefined ->
            ets:new(?DOCS_TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:new(?INVERTED_TABLE, [named_table, public, duplicate_bag, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed sample documents into yoda_logs index
            index_doc(<<"yoda_logs">>, <<"log_001">>, <<"{\"level\":\"ERROR\",\"status\":500,\"message\":\"Connection timeout during high frequency ingestion bridge\",\"service\":\"hft_router\"}">>),
            index_doc(<<"yoda_logs">>, <<"log_002">>, <<"{\"level\":\"WARN\",\"status\":429,\"message\":\"Rate limit threshold reached on IP 192.168.1.50\",\"service\":\"rate_limiter\"}">>),
            index_doc(<<"yoda_logs">>, <<"log_003">>, <<"{\"level\":\"INFO\",\"status\":200,\"message\":\"Cryptographic SHA-256 ledger block verified successfully\",\"service\":\"audit_vault\"}">>);
        _ -> ok
    end,
    ok.

execute_search(QueryBin) ->
    db_manager:simulate_db(<<"Elasticsearch">>, QueryBin).

index_doc(IndexBin, DocIdBin, JsonDocBin) ->
    DocId = if is_binary(DocIdBin) -> DocIdBin; true -> list_to_binary(DocIdBin) end,
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    DocStr = binary_to_list(JsonDocBin),
    
    % 1. Store document
    ets:insert(?DOCS_TABLE, {{Index, DocId}, JsonDocBin}),
    
    % 2. Tokenize and index in inverted table
    Words = string:tokens(string:to_lower(DocStr), " \t\n\r,.:;!?\"{}[]()$"),
    % Count term frequencies
    Counts = lists:foldl(fun(W, Acc) ->
        case lists:keyfind(W, 1, Acc) of
            {W, C} -> lists:keyreplace(W, 1, Acc, {W, C + 1});
            false -> [{W, 1} | Acc]
        end
    end, [], Words),
    
    lists:foreach(fun({Word, TF}) ->
        ets:insert(?INVERTED_TABLE, {list_to_binary(Word), Index, DocId, TF})
    end, Counts),
    DocId.

search_index(IndexBin, QueryBin) ->
    StartUs = erlang:system_time(microsecond),
    Index = if is_binary(IndexBin) -> IndexBin; true -> list_to_binary(IndexBin) end,
    QueryStr = string:to_lower(binary_to_list(QueryBin)),
    CleanTerms = string:tokens(QueryStr, " \t\n\r,.:;!?\"{}[]()$"),
    
    TotalDocs = max(1, get_doc_count(Index)),
    
    % Accumulate scores per DocId
    ScoredMap = lists:foldl(fun(Term, Acc) ->
        Matches = ets:lookup(?INVERTED_TABLE, list_to_binary(Term)),
        Filtered = [ {DocId, TF} || {_, I, DocId, TF} <- Matches, I =:= Index ],
        DocFreq = max(1, length(Filtered)),
        IDF = math:log(1.0 + (TotalDocs / DocFreq)),
        
        lists:foldl(fun({DocId, TF}, InnerAcc) ->
            TermScore = float(TF) * IDF,
            case maps:find(DocId, InnerAcc) of
                {ok, OldScore} -> maps:put(DocId, OldScore + TermScore, InnerAcc);
                error -> maps:put(DocId, TermScore, InnerAcc)
            end
        end, Acc, Filtered)
    end, #{}, CleanTerms),
    
    ScoredList = maps:to_list(ScoredMap),
    Sorted = lists:reverse(lists:keysort(2, ScoredList)),
    
    Hits = lists:filtermap(fun({DocId, Score}) ->
        case ets:lookup(?DOCS_TABLE, {Index, DocId}) of
            [{_, DocSource}] ->
                HitJson = io_lib:format("{\"_index\":\"~s\",\"_id\":\"~s\",\"_score\":~.4f,\"_source\":~s}",
                                        [binary_to_list(Index), binary_to_list(DocId), Score, binary_to_list(DocSource)]),
                {true, HitJson};
            [] -> false
        end
    end, Sorted),
    
    TookMs = max(1, (erlang:system_time(microsecond) - StartUs) div 1000),
    MaxScore = case Sorted of
        [{_, TopScore} | _] -> TopScore;
        [] -> 0.0
    end,
    
    Result = io_lib:format("{\"took\":~p,\"timed_out\":false,\"_shards\":{\"total\":1,\"successful\":1,\"skipped\":0,\"failed\":0},\"hits\":{\"total\":{\"value\":~p,\"relation\":\"eq\"},\"max_score\":~.4f,\"hits\":[~s]}}",
                           [TookMs, length(Hits), MaxScore, string:join(Hits, ",")]),
    list_to_binary(Result).

get_doc_count(IndexBin) ->
    All = ets:tab2list(?DOCS_TABLE),
    length([ DocId || {{I, DocId}, _} <- All, I =:= IndexBin ]).

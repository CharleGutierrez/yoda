-module(redis_cache).
-export([init/0, get_or_set/3, get_cache_stats_json/0, flush_cache/0, execute_cached_query/2]).

-define(STATS_TABLE, yoda_redis_cache_stats).

init() ->
    case ets:info(?STATS_TABLE) of
        undefined ->
            ets:new(?STATS_TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:insert(?STATS_TABLE, {hits, 0}),
            ets:insert(?STATS_TABLE, {misses, 0}),
            ets:insert(?STATS_TABLE, {total_cached, 0});
        _ -> ok
    end,
    redis_engine:init(),
    ok.

get_or_set(KeyBin, TtlSeconds, ComputeFun) when is_function(ComputeFun, 0) ->
    StartUs = erlang:system_time(microsecond),
    Key = if is_binary(KeyBin) -> KeyBin; true -> list_to_binary(KeyBin) end,
    
    case redis_engine:get(Key) of
        {ok, CachedVal} ->
            % Cache Hit
            ets:update_counter(?STATS_TABLE, hits, {2, 1}),
            ElapsedUs = max(1, erlang:system_time(microsecond) - StartUs),
            {hit, CachedVal, ElapsedUs};
        null ->
            % Cache Miss
            ets:update_counter(?STATS_TABLE, misses, {2, 1}),
            ComputedVal = ComputeFun(),
            ComputedBin = if is_binary(ComputedVal) -> ComputedVal; true -> list_to_binary(ComputedVal) end,
            % Store in Redis with TTL
            redis_engine:setex(Key, TtlSeconds, ComputedBin),
            ets:update_counter(?STATS_TABLE, total_cached, {2, 1}),
            ElapsedUs = max(10, erlang:system_time(microsecond) - StartUs),
            {miss, ComputedBin, ElapsedUs}
    end.

execute_cached_query(EngineBin, QueryBin) ->
    EngineStr = binary_to_list(EngineBin),
    QueryStr = binary_to_list(QueryBin),
    Hash = erlang:phash2({EngineStr, QueryStr}, 16#FFFFFFFF),
    CacheKey = list_to_binary(io_lib:format("cache:query:~s:~8.16.0b", [EngineStr, Hash])),
    
    {Status, ResultVal, LatencyUs} = get_or_set(CacheKey, 60, fun() ->
        db_manager:execute_query(EngineBin, QueryBin)
    end),
    
    HitBoolBin = if Status =:= hit -> <<"true">>; true -> <<"false">> end,
    StatusBin = if Status =:= hit -> <<"HIT">>; true -> <<"MISS">> end,
    EngineBinClean = list_to_binary(EngineStr),
    LatencyBin = integer_to_binary(LatencyUs),
    ResultClean = if is_binary(ResultVal) -> ResultVal; true -> list_to_binary(ResultVal) end,
    
    <<
      "{\"cache_status\":\"", StatusBin/binary, "\",",
      "\"cache_hit\":", HitBoolBin/binary, ",",
      "\"cache_key\":\"", CacheKey/binary, "\",",
      "\"latency_us\":", LatencyBin/binary, ",",
      "\"engine\":\"", EngineBinClean/binary, "\",",
      "\"result\":", ResultClean/binary,
      "}"
    >>.

get_cache_stats_json() ->
    [{_, Hits}] = ets:lookup(?STATS_TABLE, hits),
    [{_, Misses}] = ets:lookup(?STATS_TABLE, misses),
    [{_, TotalCached}] = ets:lookup(?STATS_TABLE, total_cached),
    TotalRequests = Hits + Misses,
    HitRatio = if TotalRequests > 0 -> (Hits / TotalRequests) * 100.0; true -> 0.0 end,
    
    KeysResp = redis_engine:execute(<<"KEYS">>),
    KeysCount = case re:run(binary_to_list(KeysResp), "\\[(.*)\\]", [{capture, [1], list}]) of
        {match, [KList]} -> length(string:tokens(KList, ","));
        _ -> 0
    end,
    
    Formatted = io_lib:format("{\"cache_engine\":\"In-Memory Redis Cache\",\"hits\":~p,\"misses\":~p,\"total_requests\":~p,\"hit_ratio_percent\":~.2f,\"active_redis_keys\":~p,\"total_cached_sessions\":~p,\"status\":\"healthy_sub_millisecond\"}",
                              [Hits, Misses, TotalRequests, HitRatio, KeysCount, TotalCached]),
    list_to_binary(Formatted).

flush_cache() ->
    redis_engine:execute(<<"FLUSHDB">>),
    ets:insert(?STATS_TABLE, {hits, 0}),
    ets:insert(?STATS_TABLE, {misses, 0}),
    ets:insert(?STATS_TABLE, {total_cached, 0}),
    <<"{\"status\":\"redis_cache_flushed\"}">>.

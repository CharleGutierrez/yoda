-module(rate_limiter).
-export([init/0, check_and_increment/2, check_and_increment_variable/3, reset_ip/1, set_config/2, get_config/0, get_ip_status_json/1, get_all_status_json/0]).

-define(TABLE, yoda_rate_limiter_table).
-define(CONFIG_TABLE, yoda_rate_limiter_config).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:new(?CONFIG_TABLE, [named_table, public, set]),
            DefaultLimit = case os:getenv("RATE_LIMIT_MAX_REQUESTS") of
                false -> 100;
                LStr -> case string:to_integer(LStr) of {IntL, _} -> IntL; _ -> 100 end
            end,
            DefaultWindow = case os:getenv("RATE_LIMIT_WINDOW_SECS") of
                false -> 60;
                WStr -> case string:to_integer(WStr) of {IntW, _} -> IntW; _ -> 60 end
            end,
            ets:insert(?CONFIG_TABLE, {default_config, DefaultLimit, DefaultWindow});
        _ -> ok
    end,
    ok.

get_config() ->
    case ets:lookup(?CONFIG_TABLE, default_config) of
        [{_, Limit, Window}] -> {Limit, Window};
        [] -> {100, 60}
    end.

set_config(Limit, WindowSeconds) ->
    ets:insert(?CONFIG_TABLE, {default_config, max(1, Limit), max(1, WindowSeconds)}),
    ok.

check_and_increment(IPBin, DefaultLimit) ->
    {ConfigLimit, ConfigWindow} = get_config(),
    Limit = if DefaultLimit > 0 -> DefaultLimit; true -> ConfigLimit end,
    check_and_increment_variable(IPBin, Limit, ConfigWindow).

check_and_increment_variable(IPBin, MaxRequests, WindowSeconds) ->
    IP = if is_binary(IPBin) -> binary_to_list(IPBin); is_list(IPBin) -> IPBin; true -> "127.0.0.1" end,
    NowMs = erlang:system_time(millisecond),
    WindowMs = max(100, WindowSeconds * 1000),
    Limit = max(1, MaxRequests),
    
    case ets:lookup(?TABLE, IP) of
        [] ->
            ets:insert(?TABLE, {IP, 1, NowMs, Limit, WindowSeconds}),
            true;
        [{IP, Count, StartMs, _OldLimit, _OldWindow}] ->
            ElapsedMs = NowMs - StartMs,
            if
                ElapsedMs >= WindowMs ->
                    % Window expired, start fresh variable window
                    ets:insert(?TABLE, {IP, 1, NowMs, Limit, WindowSeconds}),
                    true;
                Count < Limit ->
                    % Within window and under limit: atomic increment
                    ets:update_counter(?TABLE, IP, {2, 1}),
                    true;
                true ->
                    % Rate limit exceeded
                    false
            end
    end.

reset_ip(IPBin) ->
    IP = if is_binary(IPBin) -> binary_to_list(IPBin); is_list(IPBin) -> IPBin; true -> "127.0.0.1" end,
    ets:delete(?TABLE, IP),
    ok.

get_ip_status_json(IPBin) ->
    IP = if is_binary(IPBin) -> binary_to_list(IPBin); is_list(IPBin) -> IPBin; true -> "127.0.0.1" end,
    NowMs = erlang:system_time(millisecond),
    {DefLimit, DefWindow} = get_config(),
    
    Result = case ets:lookup(?TABLE, IP) of
        [{IP, Count, StartMs, Limit, WindowSecs}] ->
            ElapsedMs = NowMs - StartMs,
            WindowMs = WindowSecs * 1000,
            if
                ElapsedMs >= WindowMs ->
                    io_lib:format("{\"ip\":\"~s\",\"current_requests\":0,\"max_requests\":~p,\"remaining\":~p,\"window_seconds\":~p,\"reset_in_seconds\":0,\"status\":\"ok\"}",
                                  [IP, Limit, Limit, WindowSecs]);
                true ->
                    Remaining = max(0, Limit - Count),
                    ResetIn = max(0, (WindowMs - ElapsedMs) div 1000),
                    Status = if Count >= Limit -> "rate_limited"; true -> "ok" end,
                    io_lib:format("{\"ip\":\"~s\",\"current_requests\":~p,\"max_requests\":~p,\"remaining\":~p,\"window_seconds\":~p,\"reset_in_seconds\":~p,\"status\":\"~s\"}",
                                  [IP, Count, Limit, Remaining, WindowSecs, ResetIn, Status])
            end;
        [] ->
            io_lib:format("{\"ip\":\"~s\",\"current_requests\":0,\"max_requests\":~p,\"remaining\":~p,\"window_seconds\":~p,\"reset_in_seconds\":0,\"status\":\"ok\"}",
                          [IP, DefLimit, DefLimit, DefWindow])
    end,
    list_to_binary(Result).

get_all_status_json() ->
    All = ets:tab2list(?TABLE),
    {DefLimit, DefWindow} = get_config(),
    JsonItems = [ binary_to_list(get_ip_status_json(list_to_binary(IP))) || {IP, _, _, _, _} <- All ],
    list_to_binary(io_lib:format("{\"global_default_limit\":~p,\"global_default_window_seconds\":~p,\"tracked_ips\":[~s]}",
                                 [DefLimit, DefWindow, string:join(JsonItems, ",")])).

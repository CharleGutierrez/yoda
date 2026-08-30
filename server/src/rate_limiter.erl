-module(rate_limiter).
-export([init/0, check_and_increment/2, reset_ip/1]).

init() ->
    ets:new(rate_limiter, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
    ok.

check_and_increment(IPBin, Limit) ->
    IP = binary_to_list(IPBin),
    Now = erlang:system_time(second),
    case ets:lookup(rate_limiter, IP) of
        [] ->
            ets:insert(rate_limiter, {IP, 1, Now}),
            true;
        [{IP, Count, Timestamp}] ->
            if
                Now - Timestamp > 60 ->
                    ets:insert(rate_limiter, {IP, 1, Now}),
                    true;
                Count < Limit ->
                    ets:update_counter(rate_limiter, IP, {2, 1}),
                    true;
                true ->
                    false
            end
    end.

reset_ip(IPBin) ->
    IP = binary_to_list(IPBin),
    ets:delete(rate_limiter, IP),
    ok.

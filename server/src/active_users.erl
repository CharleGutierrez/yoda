-module(active_users).
-export([init/0, increment/0, decrement/0, get_count/0]).

init() ->
    ets:new(active_users_table, [named_table, public, set]),
    ets:insert(active_users_table, {count, 0}),
    ok.

increment() ->
    ets:update_counter(active_users_table, count, {2, 1}).

decrement() ->
    ets:update_counter(active_users_table, count, {2, -1}).

get_count() ->
    [{count, Count}] = ets:lookup(active_users_table, count),
    Count.

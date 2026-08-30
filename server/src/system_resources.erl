-module(system_resources).
-export([get_memory_total/0, get_cpu_time/0]).

get_memory_total() ->
    erlang:memory(total).

get_cpu_time() ->
    {TotalTime, _} = erlang:statistics(runtime),
    TotalTime.

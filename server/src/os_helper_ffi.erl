-module(os_helper_ffi).
-export([get_env/1, system_time_seconds/0, get_argv/0]).

get_env(KeyBin) ->
    Key = binary_to_list(KeyBin),
    case os:getenv(Key) of
        false -> {error, nil};
        Val -> {ok, list_to_binary(Val)}
    end.

system_time_seconds() ->
    erlang:system_time(second).

get_argv() ->
    Args = init:get_plain_arguments(),
    [list_to_binary(A) || A <- Args].

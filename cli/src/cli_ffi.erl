-module(cli_ffi).
-export([status/0, anomalies/0, top/0, unban/1, test_webhook/1, archive/0, get_argv/0]).

status() ->
    inets:start(),
    case httpc:request(get, {"http://localhost:8000/api/status", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} ->
            list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

anomalies() ->
    inets:start(),
    case httpc:request(get, {"http://localhost:8000/api/anomalies", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} ->
            list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

top() ->
    inets:start(),
    case httpc:request(get, {"http://localhost:8000/api/system_resources", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} ->
            list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

unban(IP) ->
    inets:start(),
    Body = binary_to_list(IP),
    case httpc:request(post, {"http://localhost:8000/api/unban", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} ->
            list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

test_webhook(Url) ->
    inets:start(),
    Body = binary_to_list(Url),
    case httpc:request(post, {"http://localhost:8000/api/test_webhook", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} ->
            list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

archive() ->
    inets:start(),
    case httpc:request(post, {"http://localhost:8000/api/archive", [], "text/plain", ""}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} ->
            list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} ->
            list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} ->
            <<"Error connecting to server">>
    end.

get_argv() ->
    Args = init:get_plain_arguments(),
    [list_to_binary(A) || A <- Args].

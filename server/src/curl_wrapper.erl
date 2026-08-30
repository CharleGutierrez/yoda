-module(curl_wrapper).
-export([curl_post/3]).

curl_post(Url, Key, Body) ->
    inets:start(),
    ssl:start(),
    Headers = [{"Authorization", "Bearer " ++ binary_to_list(Key)}],
    Request = {binary_to_list(Url), Headers, "application/json", binary_to_list(Body)},
    case httpc:request(post, Request, [], []) of
        {ok, {{_Version, _Code, _ReasonPhrase}, _RespHeaders, RespBody}} ->
            list_to_binary(RespBody);
        {error, Reason} ->
            list_to_binary(io_lib:format("Error: ~p", [Reason]))
    end.

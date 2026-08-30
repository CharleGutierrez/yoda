-module(webhook_helper).
-export([dispatch/2]).

dispatch(UrlBin, PayloadBin) ->
    inets:start(),
    ssl:start(),
    Url = binary_to_list(UrlBin),
    Payload = binary_to_list(PayloadBin),
    Request = {Url, [], "application/json", Payload},
    spawn(fun() ->
        httpc:request(post, Request, [{ssl, [{verify, verify_none}]}], [])
    end),
    nil.

-module(ws_broadcaster).
-export([init/0, subscribe/1, unsubscribe/1, broadcast/1, get_subscribers/0]).

init() ->
    case ets:info(ws_subscribers) of
        undefined ->
            ets:new(ws_subscribers, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]);
        _ ->
            ok
    end,
    ok.

subscribe(Subject) ->
    ets:insert(ws_subscribers, {Subject}),
    ok.

unsubscribe(Subject) ->
    ets:delete(ws_subscribers, Subject),
    ok.

broadcast(MsgBin) ->
    Items = [Item || {Item} <- ets:tab2list(ws_subscribers)],
    lists:foreach(fun(Item) ->
        case Item of
            {subject, Owner, Tag} ->
                Owner ! {Tag, MsgBin};
            Pid when is_pid(Pid) ->
                Pid ! MsgBin;
            _ ->
                ok
        end
    end, Items),
    length(Items).

get_subscribers() ->
    case ets:info(ws_subscribers) of
        undefined -> 0;
        _ -> ets:info(ws_subscribers, size)
    end.

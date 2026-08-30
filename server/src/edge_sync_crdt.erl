-module(edge_sync_crdt).
-export([init/0, update_lww/3, get_state_json/0, sync_state/1, increment_pn/2, decrement_pn/2, get_pn_total/0]).

-define(LWW_TABLE, yoda_crdt_lww_map).
-define(PN_TABLE, yoda_crdt_pn_counter).

init() ->
    case ets:info(?LWW_TABLE) of
        undefined ->
            ets:new(?LWW_TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            ets:new(?PN_TABLE, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]),
            update_lww(<<"edge_config:sample_rate">>, <<"1000Hz">>, <<"server_core">>),
            update_lww(<<"edge_config:offline_mode">>, <<"enabled">>, <<"server_core">>),
            update_lww(<<"edge_node:01:status">>, <<"synced">>, <<"edge_node_01">>),
            increment_pn(<<"server_core">>, 10);
        _ -> ok
    end,
    ok.

update_lww(KeyBin, ValBin, NodeIdBin) ->
    Now = erlang:system_time(millisecond),
    Key = if is_binary(KeyBin) -> KeyBin; true -> list_to_binary(KeyBin) end,
    Val = if is_binary(ValBin) -> ValBin; true -> list_to_binary(ValBin) end,
    NodeId = if is_binary(NodeIdBin) -> NodeIdBin; true -> list_to_binary(NodeIdBin) end,
    
    case ets:lookup(?LWW_TABLE, Key) of
        [{_, _OldVal, OldTime, _OldNode}] when OldTime > Now ->
            ignore;
        [{_, _OldVal, OldTime, OldNode}] when OldTime =:= Now, OldNode >= NodeId ->
            ignore;
        _ ->
            ets:insert(?LWW_TABLE, {Key, Val, Now, NodeId})
    end,
    ok.

increment_pn(NodeIdBin, Amount) ->
    NodeId = if is_binary(NodeIdBin) -> NodeIdBin; true -> list_to_binary(NodeIdBin) end,
    case ets:lookup(?PN_TABLE, NodeId) of
        [{_, P, N}] -> ets:insert(?PN_TABLE, {NodeId, P + Amount, N});
        [] -> ets:insert(?PN_TABLE, {NodeId, Amount, 0})
    end,
    ok.

decrement_pn(NodeIdBin, Amount) ->
    NodeId = if is_binary(NodeIdBin) -> NodeIdBin; true -> list_to_binary(NodeIdBin) end,
    case ets:lookup(?PN_TABLE, NodeId) of
        [{_, P, N}] -> ets:insert(?PN_TABLE, {NodeId, P, N + Amount});
        [] -> ets:insert(?PN_TABLE, {NodeId, 0, Amount})
    end,
    ok.

get_pn_total() ->
    All = ets:tab2list(?PN_TABLE),
    lists:foldl(fun({_, P, N}, Acc) -> Acc + P - N end, 0, All).

get_state_json() ->
    LwwList = ets:tab2list(?LWW_TABLE),
    FormattedLww = [ format_lww_entry(E) || E <- LwwList ],
    PnTotal = get_pn_total(),
    list_to_binary(io_lib:format("{\"crdt_model\":\"Local-First LWW-Map & PN-Counter\",\"pn_counter_total\":~p,\"lww_entries\":[~s],\"synchronized_at\":~p}",
                                 [PnTotal, string:join(FormattedLww, ","), erlang:system_time(millisecond)])).

format_lww_entry({Key, Val, Time, NodeId}) ->
    io_lib:format("{\"key\":\"~s\",\"value\":\"~s\",\"timestamp\":~p,\"node_id\":\"~s\"}",
                  [binary_to_list(Key), escape_json(binary_to_list(Val)), Time, binary_to_list(NodeId)]).

sync_state(IncomingJsonBin) ->
    IncomingStr = binary_to_list(IncomingJsonBin),
    case re:run(IncomingStr, "\"key\"\\s*:\\s*\"([^\"]+)\"\\s*,\\s*\"value\"\\s*:\\s*\"([^\"]+)\"", [global, {capture, [1, 2], list}]) of
        {match, Matches} ->
            lists:foreach(fun([K, V]) ->
                update_lww(list_to_binary(K), list_to_binary(V), <<"edge_client_sync">>)
            end, Matches);
        _ -> ok
    end,
    get_state_json().

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).

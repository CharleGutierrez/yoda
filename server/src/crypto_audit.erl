-module(crypto_audit).
-export([init/0, add_block/1, get_chain_json/1, verify_chain/0, get_block_count/0]).

init() ->
    case ets:info(audit_chain_table) of
        undefined ->
            ets:new(audit_chain_table, [named_table, public, ordered_set]),
            GenesisHash = crypto:hash(sha256, <<"GENESIS_YODA_LEDGER">>),
            GenesisHex = list_to_binary([io_lib:format("~2.16.0b", [B]) || B <- binary_to_list(GenesisHash)]),
            ets:insert(audit_chain_table, {0, erlang:system_time(second), <<"0000000000000000000000000000000000000000000000000000000000000000">>, GenesisHex, <<"Genesis Block">>});
        _ ->
            ok
    end,
    ok.

add_block(PayloadBin) ->
    LastKey = ets:last(audit_chain_table),
    [{LastKey, _LastTime, _LastPrevHash, LastHash, _LastPayload}] = ets:lookup(audit_chain_table, LastKey),
    NewIndex = LastKey + 1,
    Now = erlang:system_time(second),
    DataToHash = <<LastHash/binary, (integer_to_binary(Now))/binary, PayloadBin/binary>>,
    NewHash = crypto:hash(sha256, DataToHash),
    NewHashHex = list_to_binary([io_lib:format("~2.16.0b", [B]) || B <- binary_to_list(NewHash)]),
    ets:insert(audit_chain_table, {NewIndex, Now, LastHash, NewHashHex, PayloadBin}),
    NewHashHex.

get_block_count() ->
    ets:info(audit_chain_table, size).

get_chain_json(Limit) ->
    All = ets:tab2list(audit_chain_table),
    Sorted = lists:reverse(lists:sort(All)),
    Taken = lists:sublist(Sorted, Limit),
    JsonBlocks = [format_block_json(B) || B <- Taken],
    list_to_binary("[" ++ string:join(JsonBlocks, ",") ++ "]").

format_block_json({Index, Timestamp, PrevHash, Hash, Payload}) ->
    EscapedPayload = binary:replace(Payload, <<"\"">>, <<"\\\"">>, [global]),
    io_lib:format("{\"index\":~p,\"timestamp\":~p,\"prev_hash\":\"~s\",\"hash\":\"~s\",\"payload\":\"~s\"}",
                  [Index, Timestamp, binary_to_list(PrevHash), binary_to_list(Hash), binary_to_list(EscapedPayload)]).

verify_chain() ->
    All = lists:sort(ets:tab2list(audit_chain_table)),
    verify_blocks(All, <<"0000000000000000000000000000000000000000000000000000000000000000">>).

verify_blocks([], _ExpectedPrevHash) ->
    true;
verify_blocks([{0, _Time, PrevHash, Hash, _Payload} | Rest], _ExpectedPrev) ->
    GenesisHash = crypto:hash(sha256, <<"GENESIS_YODA_LEDGER">>),
    GenesisHex = list_to_binary([io_lib:format("~2.16.0b", [B]) || B <- binary_to_list(GenesisHash)]),
    if
        PrevHash =:= <<"0000000000000000000000000000000000000000000000000000000000000000">>, Hash =:= GenesisHex ->
            verify_blocks(Rest, Hash);
        true ->
            false
    end;
verify_blocks([{_Index, Time, PrevHash, Hash, Payload} | Rest], ExpectedPrevHash) ->
    if
        PrevHash =:= ExpectedPrevHash ->
            DataToHash = <<PrevHash/binary, (integer_to_binary(Time))/binary, Payload/binary>>,
            CalculatedHash = crypto:hash(sha256, DataToHash),
            CalculatedHex = list_to_binary([io_lib:format("~2.16.0b", [B]) || B <- binary_to_list(CalculatedHash)]),
            if
                CalculatedHex =:= Hash ->
                    verify_blocks(Rest, Hash);
                true ->
                    false
            end;
        true ->
            false
    end.

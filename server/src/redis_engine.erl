-module(redis_engine).
-compile({no_auto_import, [get/1]}).
-export([init/0, execute/1, check_expired/1, set/2, setex/3, get/1]).

-define(KV_TABLE, yoda_redis_kv).
-define(HASH_TABLE, yoda_redis_hash).
-define(LIST_TABLE, yoda_redis_list).
-define(SET_TABLE, yoda_redis_set).
-define(ZSET_TABLE, yoda_redis_zset).
-define(TTL_TABLE, yoda_redis_ttl).

init() ->
    ensure_table(?KV_TABLE, set),
    ensure_table(?HASH_TABLE, set),
    ensure_table(?LIST_TABLE, ordered_set),
    ensure_table(?SET_TABLE, bag),
    ensure_table(?ZSET_TABLE, set),
    ensure_table(?TTL_TABLE, set),
    % Seed sample Redis keys
    set(<<"system:name">>, <<"Yoda-Sentinel">>),
    ok.

ensure_table(TableName, Type) ->
    case ets:info(TableName) of
        undefined ->
            ets:new(TableName, [named_table, public, Type, {read_concurrency, true}, {write_concurrency, true}]);
        _ -> ok
    end.

set(KeyBin, ValBin) ->
    Key = if is_binary(KeyBin) -> KeyBin; true -> list_to_binary(KeyBin) end,
    Val = if is_binary(ValBin) -> ValBin; true -> list_to_binary(ValBin) end,
    ets:delete(?TTL_TABLE, Key),
    ets:insert(?KV_TABLE, {Key, Val}),
    ok.

setex(KeyBin, Seconds, ValBin) ->
    Key = if is_binary(KeyBin) -> KeyBin; true -> list_to_binary(KeyBin) end,
    Val = if is_binary(ValBin) -> ValBin; true -> list_to_binary(ValBin) end,
    ExpireMs = erlang:system_time(millisecond) + (max(1, Seconds) * 1000),
    ets:insert(?KV_TABLE, {Key, Val}),
    ets:insert(?TTL_TABLE, {Key, ExpireMs}),
    ok.

get(KeyBin) ->
    Key = if is_binary(KeyBin) -> KeyBin; true -> list_to_binary(KeyBin) end,
    case check_expired(Key) of
        true -> null;
        false ->
            case ets:lookup(?KV_TABLE, Key) of
                [{_, Val}] -> {ok, Val};
                [] -> null
            end
    end.

check_expired(KeyBin) ->
    NowMs = erlang:system_time(millisecond),
    case ets:lookup(?TTL_TABLE, KeyBin) of
        [{_, ExpireTimeMs}] when ExpireTimeMs =< NowMs ->
            ets:delete(?TTL_TABLE, KeyBin),
            ets:delete(?KV_TABLE, KeyBin),
            ets:delete(?HASH_TABLE, KeyBin),
            ets:delete(?LIST_TABLE, KeyBin),
            ets:delete(?SET_TABLE, KeyBin),
            ets:delete(?ZSET_TABLE, KeyBin),
            true;
        _ -> false
    end.

execute(CommandBin) ->
    CmdStr = string:trim(if is_binary(CommandBin) -> binary_to_list(CommandBin); true -> CommandBin end),
    Tokens = string:tokens(CmdStr, " \t\r\n"),
    case Tokens of
        [Op | Args] -> dispatch_cmd(string:to_upper(Op), Args);
        [] -> <<"{\"error\":\"Empty Redis command\"}">>
    end.

dispatch_cmd("PING", []) ->
    <<"\"PONG\"">>;
dispatch_cmd("PING", [Msg | _]) ->
    list_to_binary(io_lib:format("\"~s\"", [Msg]));

% --- Strings ---
dispatch_cmd("SET", [Key | ValRest]) ->
    ValStr = string:join(ValRest, " "),
    set(Key, ValStr),
    <<"{\"result\":\"OK\"}">>;

dispatch_cmd("SETEX", [Key, SecondsStr | ValRest]) ->
    Seconds = list_to_integer_safe(SecondsStr, 60),
    ValStr = string:join(ValRest, " "),
    setex(Key, Seconds, ValStr),
    <<"{\"result\":\"OK\"}">>;

dispatch_cmd("GET", [Key | _]) ->
    case get(Key) of
        null -> list_to_binary(io_lib:format("{\"key\":\"~s\",\"value\":null}", [Key]));
        {ok, Val} -> list_to_binary(io_lib:format("{\"key\":\"~s\",\"value\":\"~s\"}", [Key, binary_to_list(Val)]))
    end;

dispatch_cmd("MGET", Keys) ->
    Results = [ case get(K) of
                    null -> io_lib:format("{\"key\":\"~s\",\"value\":null}", [K]);
                    {ok, V} -> io_lib:format("{\"key\":\"~s\",\"value\":\"~s\"}", [K, binary_to_list(V)])
                end || K <- Keys ],
    list_to_binary("[" ++ string:join(Results, ",") ++ "]");

dispatch_cmd("INCR", [Key | _]) ->
    incr_by(Key, 1);

dispatch_cmd("INCRBY", [Key, StepStr | _]) ->
    Step = list_to_integer_safe(StepStr, 1),
    incr_by(Key, Step);

dispatch_cmd("DECR", [Key | _]) ->
    incr_by(Key, -1);

dispatch_cmd("DECRBY", [Key, StepStr | _]) ->
    Step = list_to_integer_safe(StepStr, 1),
    incr_by(Key, -Step);

dispatch_cmd("APPEND", [Key | ExtraRest]) ->
    ExtraVal = string:join(ExtraRest, " "),
    KeyBin = list_to_binary(Key),
    case check_expired(KeyBin) of true -> ok; false -> ok end,
    NewVal = case ets:lookup(?KV_TABLE, KeyBin) of
        [{_, Current}] -> <<Current/binary, (list_to_binary(ExtraVal))/binary>>;
        [] -> list_to_binary(ExtraVal)
    end,
    ets:insert(?KV_TABLE, {KeyBin, NewVal}),
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"length\":~p}", [Key, byte_size(NewVal)]));

dispatch_cmd("STRLEN", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    case check_expired(KeyBin) of true -> ok; false -> ok end,
    Len = case ets:lookup(?KV_TABLE, KeyBin) of
        [{_, V}] -> byte_size(V);
        [] -> 0
    end,
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"length\":~p}", [Key, Len]));

dispatch_cmd("DEL", Keys) ->
    Deleted = lists:foldl(fun(K, Acc) ->
        KeyBin = list_to_binary(K),
        case ets:member(?KV_TABLE, KeyBin) of
            true -> ets:delete(?KV_TABLE, KeyBin), ets:delete(?TTL_TABLE, KeyBin), Acc + 1;
            false -> Acc
        end
    end, 0, Keys),
    list_to_binary(io_lib:format("{\"deleted\":~p}", [Deleted]));

dispatch_cmd("EXISTS", Keys) ->
    Count = lists:foldl(fun(K, Acc) ->
        KeyBin = list_to_binary(K),
        case check_expired(KeyBin) of
            false ->
                case ets:member(?KV_TABLE, KeyBin) of
                    true -> Acc + 1;
                    false -> Acc
                end;
            true -> Acc
        end
    end, 0, Keys),
    list_to_binary(io_lib:format("{\"exists\":~p}", [Count]));

dispatch_cmd("KEYS", _) ->
    AllKeys = [ binary_to_list(K) || {K, _} <- ets:tab2list(?KV_TABLE), not check_expired(K) ],
    Formatted = [ "\"" ++ K ++ "\"" || K <- AllKeys ],
    list_to_binary("{\"keys\":[" ++ string:join(Formatted, ",") ++ "]}");

dispatch_cmd("DBSIZE", _) ->
    Size = ets:info(?KV_TABLE, size),
    list_to_binary(io_lib:format("{\"dbsize\":~p}", [Size]));

dispatch_cmd("FLUSHDB", _) ->
    ets:delete_all_objects(?KV_TABLE),
    ets:delete_all_objects(?HASH_TABLE),
    ets:delete_all_objects(?LIST_TABLE),
    ets:delete_all_objects(?SET_TABLE),
    ets:delete_all_objects(?ZSET_TABLE),
    ets:delete_all_objects(?TTL_TABLE),
    <<"{\"result\":\"OK\"}">>;

% --- Hashes ---
dispatch_cmd("HSET", [Key, Field, Val | Rest]) ->
    KeyBin = list_to_binary(Key),
    ets:insert(?HASH_TABLE, {{KeyBin, list_to_binary(Field)}, list_to_binary(Val)}),
    process_extra_hset(KeyBin, Rest),
    <<"{\"result\":\"OK\"}">>;

dispatch_cmd("HGET", [Key, Field | _]) ->
    KeyBin = list_to_binary(Key),
    FieldBin = list_to_binary(Field),
    case ets:lookup(?HASH_TABLE, {KeyBin, FieldBin}) of
        [{_, Val}] -> list_to_binary(io_lib:format("{\"field\":\"~s\",\"value\":\"~s\"}", [Field, binary_to_list(Val)]));
        [] -> list_to_binary(io_lib:format("{\"field\":\"~s\",\"value\":null}", [Field]))
    end;

dispatch_cmd("HGETALL", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?HASH_TABLE),
    Fields = [ io_lib:format("\"~s\":\"~s\"", [binary_to_list(F), binary_to_list(V)]) || {{K, F}, V} <- All, K =:= KeyBin ],
    list_to_binary("{\"key\":\"" ++ Key ++ "\",\"hash\":{" ++ string:join(Fields, ",") ++ "}}");

dispatch_cmd("HLEN", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?HASH_TABLE),
    Count = length([ F || {{K, F}, _} <- All, K =:= KeyBin ]),
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"hlen\":~p}", [Key, Count]));

dispatch_cmd("HDEL", [Key | Fields]) ->
    KeyBin = list_to_binary(Key),
    Deleted = lists:foldl(fun(F, Acc) ->
        case ets:member(?HASH_TABLE, {KeyBin, list_to_binary(F)}) of
            true -> ets:delete(?HASH_TABLE, {KeyBin, list_to_binary(F)}), Acc + 1;
            false -> Acc
        end
    end, 0, Fields),
    list_to_binary(io_lib:format("{\"hdel\":~p}", [Deleted]));

% --- Lists ---
dispatch_cmd("LPUSH", [Key | Values]) ->
    KeyBin = list_to_binary(Key),
    lists:foreach(fun(V) ->
        NowUs = erlang:system_time(microsecond),
        ets:insert(?LIST_TABLE, {{KeyBin, -NowUs}, list_to_binary(V)})
    end, Values),
    list_to_binary(io_lib:format("{\"lpush\":\"~s\",\"count\":~p}", [Key, length(Values)]));

dispatch_cmd("RPUSH", [Key | Values]) ->
    KeyBin = list_to_binary(Key),
    lists:foreach(fun(V) ->
        NowUs = erlang:system_time(microsecond),
        ets:insert(?LIST_TABLE, {{KeyBin, NowUs}, list_to_binary(V)})
    end, Values),
    list_to_binary(io_lib:format("{\"rpush\":\"~s\",\"count\":~p}", [Key, length(Values)]));

dispatch_cmd("LRANGE", [Key, _Start, _Stop | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?LIST_TABLE),
    Items = [ "\"" ++ binary_to_list(V) ++ "\"" || {{K, _Idx}, V} <- All, K =:= KeyBin ],
    list_to_binary("{\"key\":\"" ++ Key ++ "\",\"list\":[" ++ string:join(Items, ",") ++ "]}");

dispatch_cmd("LLEN", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?LIST_TABLE),
    Len = length([ V || {{K, _}, V} <- All, K =:= KeyBin ]),
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"llen\":~p}", [Key, Len]));

% --- Sets ---
dispatch_cmd("SADD", [Key | Members]) ->
    KeyBin = list_to_binary(Key),
    Added = lists:foldl(fun(M, Acc) ->
        MBin = list_to_binary(M),
        case ets:match_object(?SET_TABLE, {KeyBin, MBin}) of
            [] -> ets:insert(?SET_TABLE, {KeyBin, MBin}), Acc + 1;
            _ -> Acc
        end
    end, 0, Members),
    list_to_binary(io_lib:format("{\"sadd\":~p}", [Added]));

dispatch_cmd("SMEMBERS", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    Members = [ "\"" ++ binary_to_list(M) ++ "\"" || {K, M} <- ets:tab2list(?SET_TABLE), K =:= KeyBin ],
    list_to_binary("{\"key\":\"" ++ Key ++ "\",\"members\":[" ++ string:join(Members, ",") ++ "]}");

dispatch_cmd("SISMEMBER", [Key, Member | _]) ->
    KeyBin = list_to_binary(Key),
    MBin = list_to_binary(Member),
    IsMem = case ets:match_object(?SET_TABLE, {KeyBin, MBin}) of
        [] -> 0;
        _ -> 1
    end,
    list_to_binary(io_lib:format("{\"sismember\":~p}", [IsMem]));

% --- Sorted Sets (ZSets) ---
dispatch_cmd("ZADD", [Key | ScoreMemberPairs]) ->
    KeyBin = list_to_binary(Key),
    Added = process_zadd_pairs(KeyBin, ScoreMemberPairs, 0),
    list_to_binary(io_lib:format("{\"zadd\":~p}", [Added]));

dispatch_cmd("ZRANGE", [Key, _Start, _Stop | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?ZSET_TABLE),
    Matching = [ {Score, Member} || {{K, Member}, Score} <- All, K =:= KeyBin ],
    Sorted = lists:keysort(1, Matching),
    JsonList = [ io_lib:format("{\"member\":\"~s\",\"score\":~.2f}", [binary_to_list(M), S]) || {S, M} <- Sorted ],
    list_to_binary("{\"key\":\"" ++ Key ++ "\",\"zrange\":[" ++ string:join(JsonList, ",") ++ "]}");

dispatch_cmd("ZCARD", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    All = ets:tab2list(?ZSET_TABLE),
    Count = length([ M || {{K, M}, _} <- All, K =:= KeyBin ]),
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"zcard\":~p}", [Key, Count]));

% --- TTL & Expiration ---
dispatch_cmd("EXPIRE", [Key, SecsStr | _]) ->
    KeyBin = list_to_binary(Key),
    Secs = list_to_integer_safe(SecsStr, 60),
    ExpireMs = erlang:system_time(millisecond) + (Secs * 1000),
    ets:insert(?TTL_TABLE, {KeyBin, ExpireMs}),
    <<"{\"expire\":1}">>;

dispatch_cmd("TTL", [Key | _]) ->
    KeyBin = list_to_binary(Key),
    NowMs = erlang:system_time(millisecond),
    Ttl = case ets:lookup(?TTL_TABLE, KeyBin) of
        [{_, ExpireMs}] when ExpireMs > NowMs -> (ExpireMs - NowMs) div 1000;
        [{_, _}] -> -2; % expired
        [] ->
            case ets:member(?KV_TABLE, KeyBin) of
                true -> -1; % persistent without TTL
                false -> -2 % key doesn't exist
            end
    end,
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"ttl\":~p}", [Key, Ttl]));

dispatch_cmd("PUBLISH", [Channel, Msg | _]) ->
    ws_broadcaster:broadcast(list_to_binary(io_lib:format("{\"pubsub_channel\":\"~s\",\"message\":\"~s\"}", [Channel, Msg]))),
    <<"{\"published\":1}">>;

dispatch_cmd(UnknownOp, _) ->
    list_to_binary(io_lib:format("{\"error\":\"ERR unknown command '~s'\"}", [UnknownOp])).

% --- Internal Helpers ---
incr_by(Key, Step) ->
    KeyBin = list_to_binary(Key),
    case check_expired(KeyBin) of true -> ok; false -> ok end,
    NewVal = case ets:lookup(?KV_TABLE, KeyBin) of
        [{_, Current}] ->
            case string:to_integer(binary_to_list(Current)) of
                {Int, _} -> Int + Step;
                _ -> Step
            end;
        [] -> Step
    end,
    ets:insert(?KV_TABLE, {KeyBin, integer_to_binary(NewVal)}),
    list_to_binary(io_lib:format("{\"key\":\"~s\",\"value\":~p}", [Key, NewVal])).

process_extra_hset(_KeyBin, []) -> ok;
process_extra_hset(KeyBin, [Field, Val | Rest]) ->
    ets:insert(?HASH_TABLE, {{KeyBin, list_to_binary(Field)}, list_to_binary(Val)}),
    process_extra_hset(KeyBin, Rest);
process_extra_hset(_KeyBin, _) -> ok.

process_zadd_pairs(_KeyBin, [], Count) -> Count;
process_zadd_pairs(KeyBin, [ScoreStr, Member | Rest], Count) ->
    Score = list_to_float_safe(ScoreStr, 0.0),
    MBin = list_to_binary(Member),
    ets:insert(?ZSET_TABLE, {{KeyBin, MBin}, Score}),
    process_zadd_pairs(KeyBin, Rest, Count + 1);
process_zadd_pairs(_KeyBin, _, Count) -> Count.

list_to_integer_safe(Str, Default) ->
    case string:to_integer(Str) of
        {Int, _} -> Int;
        _ -> Default
    end.

list_to_float_safe(Str, Default) ->
    case string:to_float(Str) of
        {F, []} -> F;
        _ ->
            case string:to_integer(Str) of
                {I, []} -> float(I);
                _ -> Default
            end
    end.

-module(vella_nif).
-export([initialize/0, vella_optimize_system/0, vella_tune_timeseries/2, vella_tune_compression/2, query_sqlite/2, watch_legacy_dbf/1, connect_legacy_odbc/1, query_legacy_odbc/2, broadcast_mutation/3]).
-on_load(init/0).

init() ->
    SoPaths = [
        "priv/vella_nif",
        "../core_bridge/priv/vella_nif",
        "core_bridge/priv/vella_nif",
        "core_bridge/native/vella_nif/target/release/libvella_nif",
        "core_bridge/native/vella_nif/target/debug/libvella_nif",
        "../core_bridge/native/vella_nif/target/release/libvella_nif",
        "../core_bridge/native/vella_nif/target/debug/libvella_nif"
    ],
    try_load(SoPaths).

try_load([]) ->
    ok;
try_load([Path | Rest]) ->
    case filelib:is_file(Path ++ ".so") of
        true ->
            case erlang:load_nif(Path, 0) of
                ok -> ok;
                _ -> try_load(Rest)
            end;
        false ->
            try_load(Rest)
    end.

initialize() -> <<"Yoda Native Vella OS Engine v0.1.0 Active (Dual AI Optimizer & HFT Bridge)">>.
vella_optimize_system() ->
    db_manager:simulate_db(<<"Vella_Optimizer">>, <<"OPTIMIZE SYSTEM">>).
vella_tune_timeseries(Base, Latency) when Latency > 200 -> Base * 5;
vella_tune_timeseries(Base, _) -> Base.
vella_tune_compression(Base, Disk) when Disk > 85.0 -> Base * 2.0;
vella_tune_compression(Base, Disk) when Disk < 40.0 -> Base * 0.5;
vella_tune_compression(Base, _) -> Base.
query_sqlite(_Db, QueryBin) ->
    Q = if is_binary(QueryBin) -> QueryBin; true -> list_to_binary(QueryBin) end,
    db_manager:simulate_db(<<"SQLite_NIF">>, Q).
watch_legacy_dbf(Path) -> <<"Watching DBF: ", Path/binary>>.
connect_legacy_odbc(_Conn) -> <<"ODBC Ready">>.
query_legacy_odbc(_Conn, QueryBin) ->
    Q = if is_binary(QueryBin) -> QueryBin; true -> list_to_binary(QueryBin) end,
    db_manager:simulate_db(<<"ODBC_NIF">>, Q).
broadcast_mutation(Topic, Path, Status) ->
    T = if is_binary(Topic) -> Topic; true -> list_to_binary(Topic) end,
    P = if is_binary(Path) -> Path; true -> list_to_binary(Path) end,
    S = if is_binary(Status) -> Status; true -> list_to_binary(Status) end,
    <<"{\"topic\":\"", T/binary, "\",\"path\":\"", P/binary, "\",\"status\":\"", S/binary, "\"}">>.

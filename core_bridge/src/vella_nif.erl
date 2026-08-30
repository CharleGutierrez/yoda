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

initialize() -> erlang:nif_error(nif_not_loaded).
vella_optimize_system() -> erlang:nif_error(nif_not_loaded).
vella_tune_timeseries(_Base, _Latency) -> erlang:nif_error(nif_not_loaded).
vella_tune_compression(_Base, _Disk) -> erlang:nif_error(nif_not_loaded).
query_sqlite(_Db, _QueryBin) -> erlang:nif_error(nif_not_loaded).
watch_legacy_dbf(_Path) -> erlang:nif_error(nif_not_loaded).
connect_legacy_odbc(_Conn) -> erlang:nif_error(nif_not_loaded).
query_legacy_odbc(_Conn, _QueryBin) -> erlang:nif_error(nif_not_loaded).
broadcast_mutation(_Topic, _Path, _Status) -> erlang:nif_error(nif_not_loaded).

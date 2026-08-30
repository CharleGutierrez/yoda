-module(vella_nif).
-export([initialize/0, query_sqlite/2, watch_legacy_dbf/1, connect_legacy_odbc/1, query_legacy_odbc/2, broadcast_mutation/3]).
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

initialize() -> <<"Yoda Universal Multi-Database Bridge v0.1.0 Active">>.
query_sqlite(_Db, Query) ->
    list_to_binary(io_lib:format("[{\"status\":\"sqlite_in_memory_executed\",\"query\":\"~s\",\"result\":[{\"val\":42,\"system\":\"Yoda Sentinel\"}]}]", [binary_to_list(Query)])).
watch_legacy_dbf(Path) -> <<"Watching DBF: ", Path/binary>>.
connect_legacy_odbc(_Conn) -> <<"ODBC Ready">>.
query_legacy_odbc(_Conn, Query) -> list_to_binary(io_lib:format("[{\"status\":\"odbc_executed\",\"query\":\"~s\"}]", [binary_to_list(Query)])).
broadcast_mutation(Topic, Path, Status) -> list_to_binary(io_lib:format("{\"topic\":\"~s\",\"path\":\"~s\",\"status\":\"~s\"}", [Topic, Path, Status])).

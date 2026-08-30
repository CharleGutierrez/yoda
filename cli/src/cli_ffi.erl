-module(cli_ffi).
-export([status/0, anomalies/0, top/0, unban/1, test_webhook/1, archive/0, get_argv/0,
         odbc_connect/1, odbc_query/1, audit_chain/0, audit_verify/0, diagnose/1,
         stats/0, forecast/0, export_data/1, watch_dashboard/0,
         db_list/0, db_query/2, db_tune/1, db_stats/0,
         vector_search/1, vector_insert/2, multimodel_query/1, crdt_state/0, crdt_sync/1,
         vella_optimize/0, rate_limit_status/1, rate_limit_set/2, rate_limit_all/0]).

get_base_url() ->
    case os:getenv("YODA_SERVER_URL") of
        false ->
            case os:getenv("PORT") of
                false -> "http://localhost:8000";
                Port -> "http://localhost:" ++ Port
            end;
        Url -> Url
    end.

status() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/status", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

rate_limit_status(IP) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/rate_limit/status?ip=" ++ binary_to_list(IP),
    case httpc:request(get, {Url, []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

rate_limit_all() ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/rate_limit/all",
    case httpc:request(get, {Url, []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

rate_limit_set(Limit, WindowSecs) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/rate_limit/config?limit=" ++ binary_to_list(Limit) ++ "&window=" ++ binary_to_list(WindowSecs),
    case httpc:request(post, {Url, [], "text/plain", ""}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

vella_optimize() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/vella/optimize", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

vector_search(Text) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/vector/search",
    Body = binary_to_list(Text),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

vector_insert(_Id, Text) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/vector/insert",
    Body = binary_to_list(Text),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

multimodel_query(Query) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/multimodel/query",
    Body = binary_to_list(Query),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

crdt_state() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/crdt/state", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

crdt_sync(SyncJson) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/crdt/sync",
    Body = binary_to_list(SyncJson),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

db_list() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/db/engines", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

db_query(Engine, Query) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/db/query?engine=" ++ binary_to_list(Engine),
    Body = binary_to_list(Query),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

db_tune(Query) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/db/tune",
    Body = binary_to_list(Query),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

db_stats() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/db/pool_stats", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

stats() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/stats", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

forecast() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/forecast", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

export_data(Format) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/export?format=" ++ binary_to_list(Format),
    case httpc:request(get, {Url, []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

anomalies() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/anomalies", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

top() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/system_resources", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

unban(IP) ->
    inets:start(),
    Base = get_base_url(),
    Body = binary_to_list(IP),
    case httpc:request(post, {Base ++ "/api/unban", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

test_webhook(Url) ->
    inets:start(),
    Base = get_base_url(),
    Body = binary_to_list(Url),
    case httpc:request(post, {Base ++ "/api/test_webhook", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

archive() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(post, {Base ++ "/api/archive", [], "text/plain", ""}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

odbc_connect(ConnStr) ->
    inets:start(),
    Base = get_base_url(),
    Body = binary_to_list(ConnStr),
    case httpc:request(post, {Base ++ "/api/odbc_connect", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

odbc_query(Query) ->
    inets:start(),
    Base = get_base_url(),
    Body = binary_to_list(Query),
    case httpc:request(post, {Base ++ "/api/odbc_query", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

audit_chain() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/audit_chain", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

audit_verify() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/audit_verify", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

diagnose(AnomalyText) ->
    inets:start(),
    Base = get_base_url(),
    Body = binary_to_list(AnomalyText),
    case httpc:request(post, {Base ++ "/api/ai_diagnose", [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

watch_dashboard() ->
    io:format("\033[2J\033[H"),
    io:format("╔══════════════════════════════════════════════════════════════════════╗~n"),
    io:format("║         YODA SENTINEL - REAL-TIME TERMINAL TELEMETRY MONITOR         ║~n"),
    io:format("╚══════════════════════════════════════════════════════════════════════╝~n"),
    io:format("Connecting to ~s ...~n", [get_base_url()]),
    Status = status(),
    Stats = stats(),
    Forecast = forecast(),
    Audit = audit_verify(),
    io:format("Server Status: ~s~n", [Status]),
    io:format("Rolling Stats: ~s~n", [Stats]),
    io:format("AI Forecast:   ~s~n", [Forecast]),
    io:format("Ledger Proof:  ~s~n", [Audit]),
    io:format("────────────────────────────────────────────────────────────────────────~n"),
    <<"Live Monitor Finished">>.

get_argv() ->
    Args = init:get_plain_arguments(),
    [list_to_binary(A) || A <- Args].

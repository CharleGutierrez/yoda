-module(cli_ffi).
-export([status/0, anomalies/0, top/0, unban/1, test_webhook/1, archive/0, get_argv/0,
         odbc_connect/1, odbc_query/1, audit_chain/0, audit_verify/0, diagnose/1,
         stats/0, forecast/0, export_data/1, watch_dashboard/0,
         db_list/0, db_query/2, db_tune/1, db_stats/0,
         vector_search/1, vector_insert/2, multimodel_query/1, crdt_state/0, crdt_sync/1,
         vella_optimize/0, rate_limit_status/1, rate_limit_set/2, rate_limit_all/0,
         cache_stats/0, cache_flush/0, cache_query/2,
         mongo_command/1, mongo_insert/2, mongo_find/2, mongo_findone/2,
         mongo_count/2, mongo_update/3, mongo_delete/2, mongo_aggregate/2,
         mongo_collections/0, mongo_stats/0,
         cassandra_cql/1, cassandra_ring/0, cassandra_stats/0,
         cassandra_ai_tune/1, cassandra_ai_ring/0,
         cassandra_tables/0, cassandra_keyspaces/0,
         elastic_search/2, elastic_index/3, elastic_indices/0,
         elastic_stats/0, elastic_ai_tune/1, elastic_ai_analyze/1]).

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

cache_stats() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ "/api/cache/stats", []}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

cache_flush() ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(post, {Base ++ "/api/cache/flush", [], "text/plain", ""}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _Body}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

cache_query(Engine, Query) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ "/api/cache/query?engine=" ++ binary_to_list(Engine),
    Body = binary_to_list(Query),
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _ReasonPhrase}, _Headers, _RespBody}} -> list_to_binary("Error: " ++ integer_to_list(Code));
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

% ====================================================================
%  MongoDB CLI helpers
% ====================================================================
mongo_post(Path, Body) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ Path,
    case httpc:request(post, {Url, [], "application/json", Body}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

mongo_get(Path) ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ Path, []}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

mongo_command(CmdBin) ->
    mongo_post("/api/mongo/command", binary_to_list(CmdBin)).

mongo_insert(CollBin, DocBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/insert?collection=" ++ Coll, binary_to_list(DocBin)).

mongo_find(CollBin, FilterBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/find?collection=" ++ Coll, binary_to_list(FilterBin)).

mongo_findone(CollBin, FilterBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/findone?collection=" ++ Coll, binary_to_list(FilterBin)).

mongo_count(CollBin, FilterBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/count?collection=" ++ Coll, binary_to_list(FilterBin)).

mongo_update(CollBin, FilterBin, UpdateBin) ->
    Coll = binary_to_list(CollBin),
    Filter = uri_string:quote(binary_to_list(FilterBin), []),
    mongo_post("/api/mongo/update?collection=" ++ Coll ++ "&filter=" ++ Filter, binary_to_list(UpdateBin)).

mongo_delete(CollBin, FilterBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/delete?collection=" ++ Coll, binary_to_list(FilterBin)).

mongo_aggregate(CollBin, PipelineBin) ->
    Coll = binary_to_list(CollBin),
    mongo_post("/api/mongo/aggregate?collection=" ++ Coll, binary_to_list(PipelineBin)).

mongo_collections() ->
    mongo_get("/api/mongo/collections").

mongo_stats() ->
    mongo_get("/api/mongo/stats").

% ====================================================================
%  Cassandra / CQL CLI helpers
% ====================================================================
cassandra_post(Path, Body) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ Path,
    case httpc:request(post, {Url, [], "text/plain", Body}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

cassandra_get(Path) ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ Path, []}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

cassandra_cql(CqlBin) ->
    cassandra_post("/api/cassandra/cql", binary_to_list(CqlBin)).

cassandra_ring() ->
    cassandra_get("/api/cassandra/ring").

cassandra_stats() ->
    cassandra_get("/api/cassandra/stats").

cassandra_ai_tune(CqlBin) ->
    cassandra_post("/api/cassandra/ai_tune", binary_to_list(CqlBin)).

cassandra_ai_ring() ->
    cassandra_get("/api/cassandra/ai_analyze_ring").

cassandra_tables() ->
    cassandra_get("/api/cassandra/tables").

cassandra_keyspaces() ->
    cassandra_get("/api/cassandra/keyspaces").

% ====================================================================
%  Elasticsearch / Lucene CLI helpers
% ====================================================================
elastic_post(Path, Body) ->
    inets:start(),
    Base = get_base_url(),
    Url = Base ++ Path,
    case httpc:request(post, {Url, [], "application/json", Body}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, 201, _}, _Headers, RespBody}} -> list_to_binary(RespBody);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

elastic_get(Path) ->
    inets:start(),
    Base = get_base_url(),
    case httpc:request(get, {Base ++ Path, []}, [], []) of
        {ok, {{_Version, 200, _}, _Headers, Body}} -> list_to_binary(Body);
        {ok, {{_Version, Code, _}, _Headers, _}} -> list_to_binary("Error: " ++ integer_to_list(Code));
        {error, _} -> <<"Error connecting to server">>
    end.

elastic_search(IndexBin, QueryBin) ->
    Index = binary_to_list(IndexBin),
    elastic_post("/api/elastic/search?index=" ++ Index, binary_to_list(QueryBin)).

elastic_index(IndexBin, IdBin, DocBin) ->
    Index = binary_to_list(IndexBin),
    Id = binary_to_list(IdBin),
    elastic_post("/api/elastic/index?index=" ++ Index ++ "&id=" ++ Id, binary_to_list(DocBin)).

elastic_indices() ->
    elastic_get("/api/elastic/indices").

elastic_stats() ->
    elastic_get("/api/elastic/stats").

elastic_ai_tune(QueryBin) ->
    elastic_post("/api/elastic/ai_tune", binary_to_list(QueryBin)).

elastic_ai_analyze(IndexBin) ->
    Index = binary_to_list(IndexBin),
    elastic_get("/api/elastic/ai_analyze_index?index=" ++ Index).

get_argv() ->
    Args = init:get_plain_arguments(),
    [list_to_binary(A) || A <- Args].

import gleam/io
import glint

@external(erlang, "cli_ffi", "unban")
pub fn unban(ip: String) -> String

@external(erlang, "cli_ffi", "status")
pub fn ping_status() -> String

@external(erlang, "cli_ffi", "vella_optimize")
pub fn vella_optimize() -> String

@external(erlang, "cli_ffi", "anomalies")
pub fn get_anomalies() -> String

@external(erlang, "cli_ffi", "top")
pub fn get_top() -> String

@external(erlang, "cli_ffi", "test_webhook")
pub fn test_webhook(url: String) -> String

@external(erlang, "cli_ffi", "archive")
pub fn archive_log() -> String

@external(erlang, "cli_ffi", "odbc_connect")
pub fn odbc_connect(conn_str: String) -> String

@external(erlang, "cli_ffi", "odbc_query")
pub fn odbc_query(query: String) -> String

@external(erlang, "cli_ffi", "audit_chain")
pub fn audit_chain() -> String

@external(erlang, "cli_ffi", "audit_verify")
pub fn audit_verify() -> String

@external(erlang, "cli_ffi", "diagnose")
pub fn ai_diagnose(anomaly: String) -> String

@external(erlang, "cli_ffi", "stats")
pub fn get_stats() -> String

@external(erlang, "cli_ffi", "forecast")
pub fn get_forecast() -> String

@external(erlang, "cli_ffi", "export_data")
pub fn export_telemetry(format: String) -> String

@external(erlang, "cli_ffi", "watch_dashboard")
pub fn watch_live_dashboard() -> String

@external(erlang, "cli_ffi", "db_list")
pub fn db_list_engines() -> String

@external(erlang, "cli_ffi", "db_query")
pub fn db_run_query(engine: String, query: String) -> String

@external(erlang, "cli_ffi", "db_tune")
pub fn db_run_tuner(query: String) -> String

@external(erlang, "cli_ffi", "db_stats")
pub fn db_get_stats() -> String

@external(erlang, "cli_ffi", "db_auto_route")
pub fn db_auto_route(query: String) -> String

@external(erlang, "cli_ffi", "db_tune_pool")
pub fn db_tune_pool(engine: String, max: String, idle: String) -> String

@external(erlang, "cli_ffi", "vector_search")
pub fn vector_search_text(text: String) -> String

@external(erlang, "cli_ffi", "vector_insert")
pub fn vector_insert_text(id: String, text: String) -> String

@external(erlang, "cli_ffi", "multimodel_query")
pub fn multimodel_run_query(query: String) -> String

@external(erlang, "cli_ffi", "crdt_state")
pub fn crdt_get_state() -> String

@external(erlang, "cli_ffi", "crdt_sync")
pub fn crdt_sync_state(json: String) -> String

@external(erlang, "cli_ffi", "rate_limit_status")
pub fn rate_limit_ip_status(ip: String) -> String

@external(erlang, "cli_ffi", "rate_limit_set")
pub fn rate_limit_configure(limit: String, window: String) -> String

@external(erlang, "cli_ffi", "rate_limit_all")
pub fn rate_limit_view_all() -> String

@external(erlang, "cli_ffi", "cache_stats")
pub fn get_cache_stats() -> String

@external(erlang, "cli_ffi", "cache_flush")
pub fn run_cache_flush() -> String

@external(erlang, "cli_ffi", "cache_query")
pub fn run_cached_query(engine: String, query: String) -> String

@external(erlang, "cli_ffi", "mongo_command")
pub fn mongo_command(cmd: String) -> String

@external(erlang, "cli_ffi", "mongo_insert")
pub fn mongo_insert(coll: String, doc: String) -> String

@external(erlang, "cli_ffi", "mongo_find")
pub fn mongo_find(coll: String, filter: String) -> String

@external(erlang, "cli_ffi", "mongo_findone")
pub fn mongo_findone(coll: String, filter: String) -> String

@external(erlang, "cli_ffi", "mongo_count")
pub fn mongo_count(coll: String, filter: String) -> String

@external(erlang, "cli_ffi", "mongo_update")
pub fn mongo_update(coll: String, filter: String, update: String) -> String

@external(erlang, "cli_ffi", "mongo_delete")
pub fn mongo_delete(coll: String, filter: String) -> String

@external(erlang, "cli_ffi", "mongo_aggregate")
pub fn mongo_aggregate(coll: String, pipeline: String) -> String

@external(erlang, "cli_ffi", "mongo_collections")
pub fn mongo_collections() -> String

@external(erlang, "cli_ffi", "mongo_stats")
pub fn mongo_get_stats() -> String

@external(erlang, "cli_ffi", "cassandra_cql")
pub fn cassandra_cql(cql: String) -> String

@external(erlang, "cli_ffi", "cassandra_ring")
pub fn cassandra_ring() -> String

@external(erlang, "cli_ffi", "cassandra_stats")
pub fn cassandra_stats() -> String

@external(erlang, "cli_ffi", "cassandra_ai_tune")
pub fn cassandra_ai_tune(cql: String) -> String

@external(erlang, "cli_ffi", "cassandra_ai_ring")
pub fn cassandra_ai_ring() -> String

@external(erlang, "cli_ffi", "cassandra_tables")
pub fn cassandra_tables() -> String

@external(erlang, "cli_ffi", "cassandra_keyspaces")
pub fn cassandra_keyspaces() -> String

@external(erlang, "cli_ffi", "elastic_search")
pub fn elastic_search(index: String, query: String) -> String

@external(erlang, "cli_ffi", "elastic_index")
pub fn elastic_index(index: String, id: String, doc: String) -> String

@external(erlang, "cli_ffi", "elastic_indices")
pub fn elastic_indices() -> String

@external(erlang, "cli_ffi", "elastic_stats")
pub fn elastic_stats() -> String

@external(erlang, "cli_ffi", "elastic_ai_tune")
pub fn elastic_ai_tune(query: String) -> String

@external(erlang, "cli_ffi", "elastic_ai_analyze")
pub fn elastic_ai_analyze(index: String) -> String

@external(erlang, "cli_ffi", "olap_query")
pub fn olap_query(query: String) -> String

@external(erlang, "cli_ffi", "olap_tables")
pub fn olap_tables() -> String

@external(erlang, "cli_ffi", "olap_stats")
pub fn olap_stats() -> String

@external(erlang, "cli_ffi", "olap_ai_tune")
pub fn olap_ai_tune(query: String) -> String

@external(erlang, "cli_ffi", "olap_ai_analyze")
pub fn olap_ai_analyze() -> String

@external(erlang, "cli_ffi", "get_argv")
pub fn get_argv() -> List(String)

pub fn main() {
  let app =
    glint.new()
    |> glint.with_name("yoda")
    |> glint.pretty_help(glint.default_pretty_help())
    |> glint.add(
      at: ["status"],
      do: glint.command_help(
        "Pings the server status",
        fn() { glint.command(fn(_, _, _) { io.println(ping_status()) }) },
      ),
    )
    |> glint.add(
      at: ["version"],
      do: glint.command_help(
        "Prints CLI version",
        fn() { glint.command(fn(_, _, _) { io.println("Yoda CLI version 1.6.0 (Redis Semantic Cache & Multi-Model Platform)") }) },
      ),
    )
    |> glint.add(
      at: ["mongo", "command"],
      do: glint.command_help(
        "Execute any MongoDB shell command: yoda mongo command 'db.collection.find({})'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [cmd, ..] -> io.println(mongo_command(cmd))
              _ -> io.println("Usage: yoda mongo command '<mongo_shell_cmd>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "insert"],
      do: glint.command_help(
        "Insert a document: yoda mongo insert <collection> '{\"key\":\"value\"}'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, doc, ..] -> io.println(mongo_insert(coll, doc))
              _ -> io.println("Usage: yoda mongo insert <collection> '<json_doc>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "find"],
      do: glint.command_help(
        "Find documents: yoda mongo find <collection> '{\"field\":\"value\"}'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, filter, ..] -> io.println(mongo_find(coll, filter))
              [coll] -> io.println(mongo_find(coll, "{}"))
              _ -> io.println("Usage: yoda mongo find <collection> '<filter>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "findone"],
      do: glint.command_help(
        "Find first matching document: yoda mongo findone <collection> '{\"field\":\"value\"}'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, filter, ..] -> io.println(mongo_findone(coll, filter))
              [coll] -> io.println(mongo_findone(coll, "{}"))
              _ -> io.println("Usage: yoda mongo findone <collection> '<filter>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "count"],
      do: glint.command_help(
        "Count documents: yoda mongo count <collection> '<filter>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, filter, ..] -> io.println(mongo_count(coll, filter))
              [coll] -> io.println(mongo_count(coll, "{}"))
              _ -> io.println("Usage: yoda mongo count <collection> '<filter>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "update"],
      do: glint.command_help(
        "Update a document: yoda mongo update <collection> '{\"filter\":{}} '{\"$set\":{\"field\":\"val\"}}'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, filter, update, ..] -> io.println(mongo_update(coll, filter, update))
              _ -> io.println("Usage: yoda mongo update <collection> '<filter>' '<update>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "delete"],
      do: glint.command_help(
        "Delete documents: yoda mongo delete <collection> '{\"field\":\"value\"}'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, filter, ..] -> io.println(mongo_delete(coll, filter))
              _ -> io.println("Usage: yoda mongo delete <collection> '<filter>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "aggregate"],
      do: glint.command_help(
        "Run aggregation pipeline: yoda mongo aggregate <collection> '[{\"$match\":{}},{\"$group\":{...}}]'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [coll, pipeline, ..] -> io.println(mongo_aggregate(coll, pipeline))
              _ -> io.println("Usage: yoda mongo aggregate <collection> '<pipeline>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["mongo", "collections"],
      do: glint.command_help(
        "List all MongoDB collections",
        fn() { glint.command(fn(_, _, _) { io.println(mongo_collections()) }) },
      ),
    )
    |> glint.add(
      at: ["mongo", "stats"],
      do: glint.command_help(
        "Show MongoDB engine stats (documents, inserts, finds, updates, deletes)",
        fn() { glint.command(fn(_, _, _) { io.println(mongo_get_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["cassandra", "cql"],
      do: glint.command_help(
        "Execute CQL query: yoda cassandra cql \"SELECT * FROM telemetry_by_device WHERE device_id = 'device_alpha';\"",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [cql, ..] -> io.println(cassandra_cql(cql))
              _ -> io.println("Usage: yoda cassandra cql \"<cql_statement>\"")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["cassandra", "ring"],
      do: glint.command_help(
        "Show Murmur3 token distribution ring and virtual node topology",
        fn() { glint.command(fn(_, _, _) { io.println(cassandra_ring()) }) },
      ),
    )
    |> glint.add(
      at: ["cassandra", "stats"],
      do: glint.command_help(
        "Show Cassandra/ScyllaDB engine telemetry (writes, reads, tombstones, partitions)",
        fn() { glint.command(fn(_, _, _) { io.println(cassandra_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["cassandra", "ai-tune"],
      do: glint.command_help(
        "Run Autonomous AI CQL Optimizer on a query: yoda cassandra ai-tune \"<cql>\"",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [cql, ..] -> io.println(cassandra_ai_tune(cql))
              _ -> io.println("Usage: yoda cassandra ai-tune \"<cql>\"")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["cassandra", "ai-ring"],
      do: glint.command_help(
        "Run Autonomous AI Partition Hotspot & Ring Skew analysis",
        fn() { glint.command(fn(_, _, _) { io.println(cassandra_ai_ring()) }) },
      ),
    )
    |> glint.add(
      at: ["cassandra", "tables"],
      do: glint.command_help(
        "List all tables in current Cassandra keyspace",
        fn() { glint.command(fn(_, _, _) { io.println(cassandra_tables()) }) },
      ),
    )
    |> glint.add(
      at: ["cassandra", "keyspaces"],
      do: glint.command_help(
        "List all Cassandra keyspaces",
        fn() { glint.command(fn(_, _, _) { io.println(cassandra_keyspaces()) }) },
      ),
    )
    |> glint.add(
      at: ["elastic", "search"],
      do: glint.command_help(
        "Execute BM25 Lucene search or Query DSL: yoda elastic search <index> '<query_or_dsl>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [index, query, ..] -> io.println(elastic_search(index, query))
              [query, ..] -> io.println(elastic_search("yoda_logs", query))
              _ -> io.println("Usage: yoda elastic search <index> '<query_or_dsl>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["elastic", "index"],
      do: glint.command_help(
        "Index document into Elasticsearch: yoda elastic index <index> <id> '<json_doc>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [index, id, doc, ..] -> io.println(elastic_index(index, id, doc))
              _ -> io.println("Usage: yoda elastic index <index> <id> '<json_doc>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["elastic", "indices"],
      do: glint.command_help(
        "List all Elasticsearch indices and shard statuses",
        fn() { glint.command(fn(_, _, _) { io.println(elastic_indices()) }) },
      ),
    )
    |> glint.add(
      at: ["elastic", "stats"],
      do: glint.command_help(
        "Show Elasticsearch engine telemetry (documents, terms, searches, aggregations)",
        fn() { glint.command(fn(_, _, _) { io.println(elastic_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["elastic", "ai-tune"],
      do: glint.command_help(
        "Run Autonomous AI Lucene Search Optimizer: yoda elastic ai-tune '<query_or_dsl>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(elastic_ai_tune(query))
              _ -> io.println("Usage: yoda elastic ai-tune '<query_or_dsl>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["elastic", "ai-analyze"],
      do: glint.command_help(
        "Analyze index BM25 term distribution and shard health: yoda elastic ai-analyze <index>",
        fn() {
          glint.command(fn(_named, args, _flags) {
            let index = case args {
              [idx, ..] -> idx
              _ -> "yoda_logs"
            }
            io.println(elastic_ai_analyze(index))
          })
        },
      ),
    )
    |> glint.add(
      at: ["olap", "query"],
      do: glint.command_help(
        "Execute vectorized SQL OLAP analytics: yoda olap query 'SELECT region, AVG(temperature) FROM sensor_telemetry GROUP BY region'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(olap_query(query))
              _ -> io.println("Usage: yoda olap query '<sql_query>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["olap", "tables"],
      do: glint.command_help(
        "List all columnar OLAP tables and row counts",
        fn() { glint.command(fn(_, _, _) { io.println(olap_tables()) }) },
      ),
    )
    |> glint.add(
      at: ["olap", "stats"],
      do: glint.command_help(
        "Show Snowflake/ClickHouse columnar engine telemetry (scanned rows, bytes, aggregations)",
        fn() { glint.command(fn(_, _, _) { io.println(olap_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["olap", "ai-tune"],
      do: glint.command_help(
        "Run Autonomous AI OLAP Query & Clustering Key Optimizer: yoda olap ai-tune '<sql_query>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(olap_ai_tune(query))
              _ -> io.println("Usage: yoda olap ai-tune '<sql_query>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["olap", "ai-analyze"],
      do: glint.command_help(
        "Run Autonomous AI Warehouse Micro-Partition & Granule Health analysis",
        fn() { glint.command(fn(_, _, _) { io.println(olap_ai_analyze()) }) },
      ),
    )
    |> glint.add(
      at: ["cache-stats"],
      do: glint.command_help(
        "Show live Redis Cache statistics (Hits, Misses, Hit Ratio %, Active Keys)",
        fn() { glint.command(fn(_, _, _) { io.println(get_cache_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["cache-flush"],
      do: glint.command_help(
        "Flush and reset all cached query results in Redis",
        fn() { glint.command(fn(_, _, _) { io.println(run_cache_flush()) }) },
      ),
    )
    |> glint.add(
      at: ["cache-query"],
      do: glint.command_help(
        "Execute query with transparent Redis semantic caching: yoda cache-query <engine> <query>",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [engine, query, ..] -> io.println(run_cached_query(engine, query))
              _ -> io.println("Usage: yoda cache-query <engine> <query>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["rate-limit", "status"],
      do: glint.command_help(
        "Check remaining quota and reset timer for a client IP",
        fn() {
          glint.command(fn(_named, args, _flags) {
            let ip = case args {
              [target_ip, ..] -> target_ip
              _ -> "127.0.0.1"
            }
            io.println(rate_limit_ip_status(ip))
          })
        },
      ),
    )
    |> glint.add(
      at: ["rate-limit", "set"],
      do: glint.command_help(
        "Set variable rate limit: yoda rate-limit set <max_requests> <window_seconds>",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [limit, window, ..] -> io.println(rate_limit_configure(limit, window))
              _ -> io.println("Usage: yoda rate-limit set <limit> <window_seconds>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["rate-limit", "all"],
      do: glint.command_help(
        "List all actively tracked client IPs and their rate limit states",
        fn() { glint.command(fn(_, _, _) { io.println(rate_limit_view_all()) }) },
      ),
    )
    |> glint.add(
      at: ["vella-optimize"],
      do: glint.command_help(
        "Run emergency Vella AI Optimizer-Tuner on system hardware, memory, and telemetry queues",
        fn() { glint.command(fn(_, _, _) { io.println(vella_optimize()) }) },
      ),
    )
    |> glint.add(
      at: ["vector-search"],
      do: glint.command_help(
        "Search vector database via cosine similarity and semantic embeddings",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [text, ..] -> io.println(vector_search_text(text))
              _ -> io.println("Usage: yoda vector-search <text>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["vector-insert"],
      do: glint.command_help(
        "Embed and insert text vector into vector store",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [id, text, ..] -> io.println(vector_insert_text(id, text))
              _ -> io.println("Usage: yoda vector-insert <id> <text>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["multimodel-query"],
      do: glint.command_help(
        "Execute unified multi-model query (Relational + JSONB + FTS + Vectors)",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(multimodel_run_query(query))
              _ -> io.println("Usage: yoda multimodel-query <query>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["crdt-state"],
      do: glint.command_help(
        "Inspect local-first CRDT LWW-Map and PN-Counter distributed state",
        fn() { glint.command(fn(_, _, _) { io.println(crdt_get_state()) }) },
      ),
    )
    |> glint.add(
      at: ["crdt-sync"],
      do: glint.command_help(
        "Merge edge device state with server CRDT state conflict-free",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [json, ..] -> io.println(crdt_sync_state(json))
              _ -> io.println("Usage: yoda crdt-sync <json>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["db-list"],
      do: glint.command_help(
        "List all Top 10 supported database engines and connection statuses",
        fn() { glint.command(fn(_, _, _) { io.println(db_list_engines()) }) },
      ),
    )
    |> glint.add(
      at: ["db-query"],
      do: glint.command_help(
        "Execute query on a specific database (postgres, mysql, redis, sqlite, mongodb, mssql, oracle, snowflake, elasticsearch, scylla)",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [engine, query, ..] -> io.println(db_run_query(engine, query))
              _ -> io.println("Usage: yoda db-query <engine> <query>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["db-tune"],
      do: glint.command_help(
        "Run the Autonomous AI Optimizer-Tuner on a SQL/NoSQL query to get plan diagnostics and index recommendations",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(db_run_tuner(query))
              _ -> io.println("Usage: yoda db-tune <query>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["db-stats"],
      do: glint.command_help(
        "Show live connection pool statuses across all 10 databases",
        fn() { glint.command(fn(_, _, _) { io.println(db_get_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["db-auto"],
      do: glint.command_help(
        "Auto-route query across the Top 10 Database engines automatically: yoda db-auto '<query>'",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(db_auto_route(query))
              _ -> io.println("Usage: yoda db-auto '<query>'")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["db-tune-pool"],
      do: glint.command_help(
        "Dynamically adjust connection pool size: yoda db-tune-pool <engine> <max> <idle>",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [engine, max, idle, ..] -> io.println(db_tune_pool(engine, max, idle))
              _ -> io.println("Usage: yoda db-tune-pool <engine> <max> <idle>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["stats"],
      do: glint.command_help(
        "Show rolling in-memory time-series statistics (min, max, avg, stddev, p95, p99)",
        fn() { glint.command(fn(_, _, _) { io.println(get_stats()) }) },
      ),
    )
    |> glint.add(
      at: ["forecast"],
      do: glint.command_help(
        "Show real-time trend regression and telemetry forecasting",
        fn() { glint.command(fn(_, _, _) { io.println(get_forecast()) }) },
      ),
    )
    |> glint.add(
      at: ["export"],
      do: glint.command_help(
        "Export telemetry stream to CSV or JSON format",
        fn() {
          glint.command(fn(_named, args, _flags) {
            let fmt = case args {
              [f, ..] -> f
              _ -> "csv"
            }
            io.println(export_telemetry(fmt))
          })
        },
      ),
    )
    |> glint.add(
      at: ["watch"],
      do: glint.command_help(
        "Launch real-time live terminal monitoring dashboard",
        fn() { glint.command(fn(_, _, _) { io.println(watch_live_dashboard()) }) },
      ),
    )
    |> glint.add(
      at: ["anomalies"],
      do: glint.command_help(
        "Fetch and print anomalous data points",
        fn() { glint.command(fn(_, _, _) { io.println(get_anomalies()) }) },
      ),
    )
    |> glint.add(
      at: ["top"],
      do: glint.command_help(
        "Show live system resources (top)",
        fn() { glint.command(fn(_, _, _) { io.println(get_top()) }) },
      ),
    )
    |> glint.add(
      at: ["unban"],
      do: glint.command_help(
        "Manually unban an IP address",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [ip, ..] -> io.println(unban(ip))
              _ -> io.println("Usage: yoda unban <ip>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["test-webhook"],
      do: glint.command_help(
        "Send a test webhook payload to a Discord, Slack, or REST URL",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [url, ..] -> io.println(test_webhook(url))
              _ -> io.println("Usage: yoda test-webhook <url>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["archive"],
      do: glint.command_help(
        "Trigger a manual log rotation and archiving",
        fn() { glint.command(fn(_, _, _) { io.println(archive_log()) }) },
      ),
    )
    |> glint.add(
      at: ["odbc-connect"],
      do: glint.command_help(
        "Test an ODBC connection string",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [conn_str, ..] -> io.println(odbc_connect(conn_str))
              _ -> io.println("Usage: yoda odbc-connect <connection_string>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["odbc-query"],
      do: glint.command_help(
        "Execute a SQL query via ODBC bridge",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [query, ..] -> io.println(odbc_query(query))
              _ -> io.println("Usage: yoda odbc-query <sql_query>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["audit-chain"],
      do: glint.command_help(
        "Fetch the cryptographic SHA-256 hash-chained audit ledger",
        fn() { glint.command(fn(_, _, _) { io.println(audit_chain()) }) },
      ),
    )
    |> glint.add(
      at: ["audit-verify"],
      do: glint.command_help(
        "Verify cryptographic audit chain integrity",
        fn() { glint.command(fn(_, _, _) { io.println(audit_verify()) }) },
      ),
    )
    |> glint.add(
      at: ["diagnose"],
      do: glint.command_help(
        "Run autonomous AI root-cause diagnostic on an anomaly",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [anomaly, ..] -> io.println(ai_diagnose(anomaly))
              _ -> io.println("Usage: yoda diagnose <anomaly_text>")
            }
          })
        },
      ),
    )

  let args = get_argv()
  glint.run(app, args)
}

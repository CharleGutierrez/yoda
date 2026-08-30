import gleam/io
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import gleam/http/request
import gleam/http/response
import gleam/option.{Some}
import legacy_bridge
import file_helper
import os_helper
import gleam/string
import gleam/http
import gleam/bytes_tree
import gleam/list
import gleam/int

@external(erlang, "curl_wrapper", "curl_post")
pub fn curl_post(url: String, key: String, body: String) -> String

@external(erlang, "system_resources", "get_memory_total")
pub fn get_memory_total() -> Int

@external(erlang, "system_resources", "get_cpu_time")
pub fn get_cpu_time() -> Int

@external(erlang, "rate_limiter", "init")
pub fn init_rate_limiter() -> Nil

@external(erlang, "rate_limiter", "check_and_increment")
pub fn rate_limit_check(ip: String, limit: Int) -> Bool

@external(erlang, "rate_limiter", "check_and_increment_variable")
pub fn rate_limit_check_variable(ip: String, max_requests: Int, window_seconds: Int) -> Bool

@external(erlang, "rate_limiter", "reset_ip")
pub fn rate_limit_reset(ip: String) -> Nil

@external(erlang, "rate_limiter", "set_config")
pub fn rate_limit_set_config(limit: Int, window_seconds: Int) -> Nil

@external(erlang, "rate_limiter", "get_ip_status_json")
pub fn rate_limit_get_ip_status(ip: String) -> String

@external(erlang, "rate_limiter", "get_all_status_json")
pub fn rate_limit_get_all_status() -> String

@external(erlang, "webhook_router", "dispatch_alert")
pub fn dispatch_webhook_alert(url: String, alert_msg: String, diagnostic: String) -> Nil

@external(erlang, "log_rotator", "start")
pub fn start_log_rotator() -> Nil

@external(erlang, "log_rotator", "rotate")
pub fn rotate_log() -> Nil

@external(erlang, "active_users", "init")
pub fn init_active_users() -> Nil

@external(erlang, "active_users", "increment")
pub fn active_users_increment() -> Int

@external(erlang, "active_users", "decrement")
pub fn active_users_decrement() -> Int

@external(erlang, "active_users", "get_count")
pub fn active_users_get_count() -> Int

@external(erlang, "ws_broadcaster", "init")
pub fn init_ws_broadcaster() -> Nil

@external(erlang, "ws_broadcaster", "subscribe")
pub fn ws_subscribe(subj: process.Subject(String)) -> Nil

@external(erlang, "ws_broadcaster", "unsubscribe")
pub fn ws_unsubscribe(subj: process.Subject(String)) -> Nil

@external(erlang, "ws_broadcaster", "broadcast")
pub fn ws_broadcast(msg: String) -> Int

@external(erlang, "crypto_audit", "init")
pub fn init_crypto_audit() -> Nil

@external(erlang, "crypto_audit", "add_block")
pub fn crypto_audit_add(payload: String) -> String

@external(erlang, "crypto_audit", "get_chain_json")
pub fn crypto_audit_get_chain(limit: Int) -> String

@external(erlang, "crypto_audit", "verify_chain")
pub fn crypto_audit_verify() -> Bool

@external(erlang, "crypto_audit", "get_block_count")
pub fn crypto_audit_count() -> Int

@external(erlang, "timeseries_store", "init")
pub fn init_timeseries_store() -> Nil

@external(erlang, "timeseries_store", "record_raw")
pub fn timeseries_record_raw(msg: String) -> Nil

@external(erlang, "timeseries_store", "get_timeseries_json")
pub fn timeseries_get_json(window_seconds: Int) -> String

@external(erlang, "timeseries_store", "get_stats_json")
pub fn timeseries_get_stats() -> String

@external(erlang, "timeseries_store", "get_total_points")
pub fn timeseries_total_points() -> Int

@external(erlang, "anomaly_engine", "get_forecast_json")
pub fn anomaly_get_forecast() -> String

@external(erlang, "export_engine", "export_csv")
pub fn export_csv_data() -> String

@external(erlang, "export_engine", "export_json")
pub fn export_json_data() -> String

@external(erlang, "db_manager", "init")
pub fn init_db_manager() -> Nil

@external(erlang, "db_manager", "list_engines")
pub fn db_list_engines() -> String

@external(erlang, "db_manager", "execute_query")
pub fn db_execute_query(engine: String, query: String) -> String

@external(erlang, "db_manager", "get_pool_stats")
pub fn db_get_pool_stats() -> String

@external(erlang, "db_ai_tuner", "tune_query")
pub fn db_tune_query(query: String, key: String) -> String

@external(erlang, "mongo_engine", "execute_mongo")
pub fn mongo_execute(cmd: String) -> String

@external(erlang, "mongo_engine", "insert_doc")
pub fn mongo_insert_doc(coll: String, doc: String) -> String

@external(erlang, "mongo_engine", "find_docs")
pub fn mongo_find_docs(coll: String, filter: String) -> List(String)

@external(erlang, "mongo_engine", "find_one")
pub fn mongo_find_one(coll: String, filter: String) -> String

@external(erlang, "mongo_engine", "count_docs")
pub fn mongo_count_docs(coll: String, filter: String) -> Int

@external(erlang, "mongo_engine", "update_one")
pub fn mongo_update_one(coll: String, filter: String, update: String) -> #(Int, Int)

@external(erlang, "mongo_engine", "delete_docs")
pub fn mongo_delete_docs(coll: String, filter: String) -> Int

@external(erlang, "mongo_engine", "delete_one")
pub fn mongo_delete_one(coll: String, filter: String) -> Int

@external(erlang, "mongo_engine", "list_collections")
pub fn mongo_list_collections() -> List(String)

@external(erlang, "mongo_engine", "drop_collection")
pub fn mongo_drop_collection(coll: String) -> Nil

@external(erlang, "mongo_engine", "aggregate")
pub fn mongo_aggregate(coll: String, pipeline: String) -> List(String)

@external(erlang, "mongo_engine", "get_engine_stats")
pub fn mongo_get_stats() -> String

@external(erlang, "redis_cache", "init")
pub fn init_redis_cache() -> Nil

@external(erlang, "redis_cache", "get_cache_stats_json")
pub fn redis_get_cache_stats() -> String

@external(erlang, "redis_cache", "flush_cache")
pub fn redis_flush_cache() -> String

@external(erlang, "cassandra_engine", "execute_cql")
pub fn cassandra_execute_cql(cql: String) -> String

@external(erlang, "cassandra_engine", "get_ring_json")
pub fn cassandra_get_ring() -> String

@external(erlang, "cassandra_engine", "get_stats_json")
pub fn cassandra_get_stats() -> String

@external(erlang, "cassandra_engine", "ai_tune")
pub fn cassandra_ai_tune(cql: String, key: String) -> String

@external(erlang, "cassandra_engine", "ai_analyze_ring")
pub fn cassandra_ai_analyze_ring() -> String

@external(erlang, "cassandra_engine", "list_tables")
pub fn cassandra_list_tables() -> List(String)

@external(erlang, "cassandra_engine", "list_keyspaces")
pub fn cassandra_list_keyspaces() -> List(String)

@external(erlang, "elastic_engine", "execute_search")
pub fn elastic_search(query: String) -> String

@external(erlang, "elastic_engine", "search_index")
pub fn elastic_search_index(index: String, query: String) -> String

@external(erlang, "elastic_engine", "index_doc")
pub fn elastic_index_doc(index: String, id: String, doc: String) -> String

@external(erlang, "elastic_engine", "get_indices_json")
pub fn elastic_get_indices() -> String

@external(erlang, "elastic_engine", "get_stats_json")
pub fn elastic_get_stats() -> String

@external(erlang, "elastic_engine", "ai_tune")
pub fn elastic_ai_tune(query: String, key: String) -> String

@external(erlang, "elastic_engine", "ai_analyze_index")
pub fn elastic_ai_analyze_index(index: String) -> String

@external(erlang, "elastic_engine", "list_indices")
pub fn elastic_list_indices() -> List(String)

@external(erlang, "redis_cache", "execute_cached_query")
pub fn redis_execute_cached_query(engine: String, query: String) -> String

@external(erlang, "vector_db", "init")
pub fn init_vector_db() -> Nil

@external(erlang, "vector_db", "search_text")
pub fn vector_search_text(text: String, top_k: Int, key: String) -> String

@external(erlang, "vector_db", "insert_text")
pub fn vector_insert_text(id: String, text: String, metadata: String, key: String) -> String

@external(erlang, "multi_model_engine", "init")
pub fn init_multi_model_engine() -> Nil

@external(erlang, "multi_model_engine", "query_unified")
pub fn multi_model_query(query: String) -> String

@external(erlang, "edge_sync_crdt", "init")
pub fn init_edge_sync_crdt() -> Nil

@external(erlang, "edge_sync_crdt", "get_state_json")
pub fn crdt_get_state() -> String

@external(erlang, "edge_sync_crdt", "sync_state")
pub fn crdt_sync_state(incoming: String) -> String

@external(erlang, "udp_receiver", "start")
pub fn start_udp_receiver(port: Int) -> Nil

@external(erlang, "ai_diagnostics", "diagnose_anomaly")
pub fn ai_diagnose_anomaly(anomaly: String, key: String) -> String

@external(erlang, "anomaly_helper", "check_anomaly")
pub fn check_anomaly_robust(msg: String) -> Bool

pub fn main() {
  wisp.configure_logger()
  init_rate_limiter()
  init_active_users()
  init_ws_broadcaster()
  init_crypto_audit()
  init_timeseries_store()
  init_db_manager()
  init_redis_cache()
  init_vector_db()
  init_multi_model_engine()
  init_edge_sync_crdt()
  start_log_rotator()
  
  let udp_port = case os_helper.get_env("HFT_DEST_PORT") {
    Ok(p_str) -> case int.parse(p_str) {
      Ok(p) -> p
      Error(_) -> 8080
    }
    Error(_) -> 8080
  }
  start_udp_receiver(udp_port)
  
  let start_time = os_helper.system_time_seconds()
  
  let handler = fn(req) {
    let path = wisp.path_segments(req)
    let ip = case request.get_header(req, "x-forwarded-for") {
      Ok(i) -> i
      Error(_) -> "127.0.0.1"
    }

    case path {
      ["metrics"] -> {
        let uptime_val = os_helper.system_time_seconds() - start_time
        let active_ws = active_users_get_count()
        let mem = get_memory_total()
        let cpu = get_cpu_time()
        let blocks = crypto_audit_count()
        let ts_points = timeseries_total_points()
        let metrics_text = 
          "# HELP yoda_uptime Server uptime in seconds\n# TYPE yoda_uptime gauge\nyoda_uptime " <> int.to_string(uptime_val) <> "\n"
          <> "# HELP yoda_active_websockets Active WebSocket client connections\n# TYPE yoda_active_websockets gauge\nyoda_active_websockets " <> int.to_string(active_ws) <> "\n"
          <> "# HELP yoda_memory_bytes Total BEAM VM allocated memory\n# TYPE yoda_memory_bytes gauge\nyoda_memory_bytes " <> int.to_string(mem) <> "\n"
          <> "# HELP yoda_cpu_time Total CPU runtime\n# TYPE yoda_cpu_time counter\nyoda_cpu_time " <> int.to_string(cpu) <> "\n"
          <> "# HELP yoda_audit_blocks_total Total cryptographic audit chain ledger blocks\n# TYPE yoda_audit_blocks_total counter\nyoda_audit_blocks_total " <> int.to_string(blocks) <> "\n"
          <> "# HELP yoda_timeseries_points_total In-memory time-series data points\n# TYPE yoda_timeseries_points_total gauge\nyoda_timeseries_points_total " <> int.to_string(ts_points) <> "\n"
        wisp.html_response(metrics_text, 200)
      }
      _ -> {
        let is_api = case path {
          ["api", ..] -> True
          _ -> False
        }
        let is_auth = case request.get_header(req, "authorization") {
          Ok("Bearer " <> t) -> case os_helper.get_env("API_TOKEN") {
            Ok(env_t) -> t == env_t
            Error(_) -> False
          }
          _ -> case list.key_find(wisp.get_query(req), "token") {
            Ok(t) -> case os_helper.get_env("API_TOKEN") {
              Ok(env_t) -> t == env_t
              Error(_) -> False
            }
            _ -> False
          }
        }
        case is_api, is_auth {
          True, False -> wisp.json_response("{\"error\":\"Unauthorized\"}", 401)
          _, _ -> {
            case rate_limit_check(ip, 0) {
          False -> {
            wisp.html_response("Too Many Requests", 429)
          }
          True -> {
            case path {
              ["api", "unban"] -> {
                use req_body <- wisp.require_string_body(req)
                rate_limit_reset(string.trim(req_body))
                wisp.json_response("{\"status\":\"unbanned\"}", 200)
              }
              ["api", "rate_limit", "status"] -> {
                let query_ip = case list.key_find(wisp.get_query(req), "ip") {
                  Ok(target_ip) -> target_ip
                  Error(_) -> ip
                }
                let status_json = rate_limit_get_ip_status(query_ip)
                wisp.json_response(status_json, 200)
              }
              ["api", "rate_limit", "all"] -> {
                let all_json = rate_limit_get_all_status()
                wisp.json_response(all_json, 200)
              }
              ["api", "rate_limit", "config"] -> {
                let queries = wisp.get_query(req)
                let max_reqs = case list.key_find(queries, "limit") {
                  Ok(l_str) -> case int.parse(l_str) {
                    Ok(l) -> l
                    Error(_) -> 100
                  }
                  Error(_) -> 100
                }
                let window_secs = case list.key_find(queries, "window") {
                  Ok(w_str) -> case int.parse(w_str) {
                    Ok(w) -> w
                    Error(_) -> 60
                  }
                  Error(_) -> 60
                }
                rate_limit_set_config(max_reqs, window_secs)
                wisp.json_response("{\"status\":\"rate_limiter_configured\",\"limit\":" <> int.to_string(max_reqs) <> ",\"window_seconds\":" <> int.to_string(window_secs) <> "}", 200)
              }
              ["api", "status"] -> {
                let uptime_val = os_helper.system_time_seconds() - start_time
                let dyn_val = int.to_string(uptime_val)
                wisp.json_response("{\"status\":\"healthy\",\"uptime\":" <> dyn_val <> "}", 200)
              }
              ["api", "cache", "stats"] -> {
                let stats = redis_get_cache_stats()
                wisp.json_response(stats, 200)
              }
              ["api", "cache", "flush"] -> {
                let res = redis_flush_cache()
                wisp.json_response(res, 200)
              }
              ["api", "cache", "query"] -> {
                use req_body <- wisp.require_string_body(req)
                let engine = case list.key_find(wisp.get_query(req), "engine") {
                  Ok(e) -> e
                  Error(_) -> "sqlite"
                }
                let result = redis_execute_cached_query(engine, string.trim(req_body))
                wisp.json_response(result, 200)
              }
              ["api", "vella", "optimize"] -> {
                let vella_report = legacy_bridge.run_vella_system_optimization()
                wisp.json_response(vella_report, 200)
              }
              ["api", "vector", "search"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let results = vector_search_text(string.trim(req_body), 5, key)
                wisp.json_response(results, 200)
              }
              ["api", "vector", "insert"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let id = "vec_" <> int.to_string(os_helper.system_time_seconds())
                let res = vector_insert_text(id, string.trim(req_body), "{\"source\":\"api\"}", key)
                wisp.json_response("{\"id\":\"" <> res <> "\",\"status\":\"vector_indexed\"}", 200)
              }
              ["api", "multimodel", "query"] -> {
                use req_body <- wisp.require_string_body(req)
                let json = multi_model_query(string.trim(req_body))
                wisp.json_response(json, 200)
              }
              ["api", "crdt", "state"] -> {
                let state_json = crdt_get_state()
                wisp.json_response(state_json, 200)
              }
              ["api", "crdt", "sync"] -> {
                use req_body <- wisp.require_string_body(req)
                let merged = crdt_sync_state(string.trim(req_body))
                wisp.json_response(merged, 200)
              }
              // ── MongoDB dedicated routes ───────────────────────────────────
              ["api", "mongo", "command"] -> {
                use req_body <- wisp.require_string_body(req)
                let result = mongo_execute(string.trim(req_body))
                wisp.json_response(result, 200)
              }
              ["api", "mongo", "insert"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let id = mongo_insert_doc(coll, string.trim(req_body))
                wisp.json_response("{\"acknowledged\":true,\"insertedId\":\"" <> id <> "\",\"collection\":\"" <> coll <> "\"}", 200)
              }
              ["api", "mongo", "find"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let filter = string.trim(req_body)
                let docs = mongo_find_docs(coll, filter)
                wisp.json_response("[" <> string.join(docs, ",") <> "]", 200)
              }
              ["api", "mongo", "findone"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let doc = mongo_find_one(coll, string.trim(req_body))
                wisp.json_response(doc, 200)
              }
              ["api", "mongo", "count"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let count = mongo_count_docs(coll, string.trim(req_body))
                wisp.json_response("{\"count\":" <> int.to_string(count) <> ",\"collection\":\"" <> coll <> "\"}", 200)
              }
              ["api", "mongo", "update"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let filter = case list.key_find(wisp.get_query(req), "filter") {
                  Ok(f) -> f
                  Error(_) -> "{}"
                }
                let #(matched, modified) = mongo_update_one(coll, filter, string.trim(req_body))
                wisp.json_response("{\"acknowledged\":true,\"matchedCount\":" <> int.to_string(matched) <> ",\"modifiedCount\":" <> int.to_string(modified) <> "}", 200)
              }
              ["api", "mongo", "delete"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let deleted = mongo_delete_docs(coll, string.trim(req_body))
                wisp.json_response("{\"acknowledged\":true,\"deletedCount\":" <> int.to_string(deleted) <> "}", 200)
              }
              ["api", "mongo", "aggregate"] -> {
                use req_body <- wisp.require_string_body(req)
                let coll = case list.key_find(wisp.get_query(req), "collection") {
                  Ok(c) -> c
                  Error(_) -> "telemetry_events"
                }
                let results = mongo_aggregate(coll, string.trim(req_body))
                wisp.json_response("[" <> string.join(results, ",") <> "]", 200)
              }
              ["api", "mongo", "collections"] -> {
                let colls = mongo_list_collections()
                wisp.json_response("{\"collections\":[" <> string.join(list.map(colls, fn(c) { "\"" <> c <> "\"" }), ",") <> "]}", 200)
              }
              ["api", "mongo", "stats"] -> {
                let stats = mongo_get_stats()
                wisp.json_response(stats, 200)
              }
              // ── End MongoDB routes ─────────────────────────────────────────────
              // ── Cassandra / CQL routes ─────────────────────────────────────────
              ["api", "cassandra", "cql"] -> {
                use req_body <- wisp.require_string_body(req)
                let result = cassandra_execute_cql(string.trim(req_body))
                wisp.json_response(result, 200)
              }
              ["api", "cassandra", "ring"] -> {
                let ring = cassandra_get_ring()
                wisp.json_response(ring, 200)
              }
              ["api", "cassandra", "stats"] -> {
                let stats = cassandra_get_stats()
                wisp.json_response(stats, 200)
              }
              ["api", "cassandra", "ai_tune"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let report = cassandra_ai_tune(string.trim(req_body), key)
                wisp.json_response(report, 200)
              }
              ["api", "cassandra", "ai_analyze_ring"] -> {
                let report = cassandra_ai_analyze_ring()
                wisp.json_response(report, 200)
              }
              ["api", "cassandra", "tables"] -> {
                let tables = cassandra_list_tables()
                wisp.json_response("{\"tables\":[" <> string.join(list.map(tables, fn(t) { "\"" <> t <> "\"" }), ",") <> "]}", 200)
              }
              ["api", "cassandra", "keyspaces"] -> {
                let kss = cassandra_list_keyspaces()
                wisp.json_response("{\"keyspaces\":[" <> string.join(list.map(kss, fn(k) { "\"" <> k <> "\"" }), ",") <> "]}", 200)
              }
              // ── End Cassandra routes ───────────────────────────────────────────
              // ── Elasticsearch / Lucene routes ──────────────────────────────────
              ["api", "elastic", "search"] -> {
                use req_body <- wisp.require_string_body(req)
                let index = case list.key_find(wisp.get_query(req), "index") {
                  Ok(i) -> i
                  Error(_) -> "yoda_logs"
                }
                let result = elastic_search_index(index, string.trim(req_body))
                wisp.json_response(result, 200)
              }
              ["api", "elastic", "index"] -> {
                use req_body <- wisp.require_string_body(req)
                let index = case list.key_find(wisp.get_query(req), "index") {
                  Ok(i) -> i
                  Error(_) -> "yoda_logs"
                }
                let id = case list.key_find(wisp.get_query(req), "id") {
                  Ok(d) -> d
                  Error(_) -> "doc_auto"
                }
                let doc_id = elastic_index_doc(index, id, string.trim(req_body))
                wisp.json_response("{\"_index\":\"" <> index <> "\",\"_id\":\"" <> doc_id <> "\",\"result\":\"created\"}", 201)
              }
              ["api", "elastic", "indices"] -> {
                let indices = elastic_get_indices()
                wisp.json_response(indices, 200)
              }
              ["api", "elastic", "stats"] -> {
                let stats = elastic_get_stats()
                wisp.json_response(stats, 200)
              }
              ["api", "elastic", "ai_tune"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let report = elastic_ai_tune(string.trim(req_body), key)
                wisp.json_response(report, 200)
              }
              ["api", "elastic", "ai_analyze_index"] -> {
                let index = case list.key_find(wisp.get_query(req), "index") {
                  Ok(i) -> i
                  Error(_) -> "yoda_logs"
                }
                let report = elastic_ai_analyze_index(index)
                wisp.json_response(report, 200)
              }
              // ── End Elasticsearch routes ───────────────────────────────────────
              ["api", "db", "engines"] -> {
                let json = db_list_engines()
                wisp.json_response(json, 200)
              }
              ["api", "db", "query"] -> {
                use req_body <- wisp.require_string_body(req)
                let engine = case list.key_find(wisp.get_query(req), "engine") {
                  Ok(e) -> e
                  Error(_) -> "sqlite"
                }
                let result = db_execute_query(engine, string.trim(req_body))
                wisp.json_response(result, 200)
              }
              ["api", "db", "tune"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let report = db_tune_query(string.trim(req_body), key)
                wisp.json_response(report, 200)
              }
              ["api", "db", "pool_stats"] -> {
                let stats = db_get_pool_stats()
                wisp.json_response(stats, 200)
              }
              ["api", "stats"] -> {
                let stats = timeseries_get_stats()
                wisp.json_response(stats, 200)
              }
              ["api", "timeseries"] -> {
                let json = timeseries_get_json(60)
                wisp.json_response(json, 200)
              }
              ["api", "forecast"] -> {
                let json = anomaly_get_forecast()
                wisp.json_response(json, 200)
              }
              ["api", "export"] -> {
                case list.key_find(wisp.get_query(req), "format") {
                  Ok("json") -> wisp.json_response(export_json_data(), 200)
                  _ -> wisp.html_response(export_csv_data(), 200)
                }
              }
              ["api", "ai_insights"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let url = "https://api.openai.com/v1/chat/completions"
                let resp_body = curl_post(url, key, req_body)
                wisp.json_response(resp_body, 200)
              }
              ["api", "ai_diagnose"] -> {
                use req_body <- wisp.require_string_body(req)
                let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                  Ok(k) -> k
                  Error(_) -> "no_key"
                }
                let diagnosis = ai_diagnose_anomaly(string.trim(req_body), key)
                wisp.json_response(diagnosis, 200)
              }
              ["api", "audit_chain"] -> {
                let json = crypto_audit_get_chain(50)
                wisp.json_response(json, 200)
              }
              ["api", "audit_verify"] -> {
                let is_valid = crypto_audit_verify()
                let json = case is_valid {
                  True -> "{\"verified\": true, \"status\": \"Cryptographic SHA-256 Ledger Intact\"}"
                  False -> "{\"verified\": false, \"status\": \"Tamper Detected in Ledger\"}"
                }
                wisp.json_response(json, 200)
              }
              ["api", "odbc_connect"] -> {
                use req_body <- wisp.require_string_body(req)
                let conn_str = string.trim(req_body)
                let status = legacy_bridge.test_odbc_connection(conn_str)
                wisp.json_response("{\"status\":\"" <> status <> "\"}", 200)
              }
              ["api", "odbc_query"] -> {
                use req_body <- wisp.require_string_body(req)
                let conn_str = case os_helper.get_env("ODBC_CONNECTION_STRING") {
                  Ok(c) -> c
                  Error(_) -> "DSN=default"
                }
                let query = string.trim(req_body)
                let result_json = legacy_bridge.execute_odbc_query(conn_str, query)
                wisp.json_response(result_json, 200)
              }
              ["api", "history"] -> {
                let tail = file_helper.read_tail("data_history.log", 50)
                let json_array = "[" <> string.join(list.map(tail, fn(s) { "\"" <> string.replace(s, "\"", "\\\"") <> "\"" }), ",") <> "]"
                wisp.json_response(json_array, 200)
              }
              ["api", "anomalies"] -> {
                let tail = file_helper.read_tail("data_history.log", 100)
                let anomalies = list.filter(tail, is_anomaly)
                let json_array = "[" <> string.join(list.map(anomalies, fn(s) { "\"" <> string.replace(s, "\"", "\\\"") <> "\"" }), ",") <> "]"
                wisp.json_response(json_array, 200)
              }
              ["api", "system_resources"] -> {
                let mem = get_memory_total()
                let cpu = get_cpu_time()
                let json = "{\"memory\": " <> int.to_string(mem) <> ", \"cpu\": " <> int.to_string(cpu) <> "}"
                wisp.json_response(json, 200)
              }
              ["api", "test_webhook"] -> {
                use req_body <- wisp.require_string_body(req)
                let url = string.trim(req_body)
                dispatch_webhook_alert(url, "Yoda Anomaly Test Trigger", "Synthetic test alert verified via Yoda Sentinel")
                wisp.json_response("{\"status\":\"dispatched\"}", 200)
              }
              ["api", "active_users"] -> {
                let count = active_users_get_count()
                let json = "{\"active_users\": " <> int.to_string(count) <> "}"
                wisp.json_response(json, 200)
              }
              ["api", "archive"] -> {
                case req.method {
                  http.Post -> {
                    rotate_log()
                    wisp.json_response("{\"status\":\"archived\"}", 200)
                  }
                  _ -> wisp.html_response("Method Not Allowed", 405)
                }
              }
              _ -> wisp.html_response("<html><body><h1>Yoda Server Active</h1></body></html>", 200)
            }
          }
        }
      }
    }
  }
  }
  }
  let secret = wisp.random_string(64)
  let wisp_app = wisp_mist.handler(handler, secret)
  
  let router = fn(req: request.Request(mist.Connection)) -> response.Response(mist.ResponseData) {
    case request.path_segments(req) {
      ["ws"] -> {
        let is_auth = case request.get_query(req) {
          Ok(queries) -> case list.key_find(queries, "token") {
            Ok(t) -> case os_helper.get_env("WS_TOKEN") {
              Ok(env_t) -> t == env_t
              Error(_) -> False
            }
            _ -> False
          }
          _ -> False
        }
        case is_auth {
          True -> {
            mist.websocket(
              request: req,
              on_init: fn(_conn) { 
                let _ = active_users_increment()
                let subj = process.new_subject()
                let sel = process.new_selector() |> process.select(subj)
                ws_subscribe(subj)
                #(subj, Some(sel)) 
              },
              on_close: fn(subj) { 
                let _ = active_users_decrement()
                ws_unsubscribe(subj)
                Nil 
              },
              handler: fn(subj, message, conn) {
                case message {
                  mist.Custom(broadcast_msg) -> {
                    let _ = mist.send_text_frame(conn, broadcast_msg)
                    mist.continue(subj)
                  }
                  mist.Text("start") -> {
                    let data = legacy_bridge.start_legacy_sync("data.dbf")
                    let msg = "HFT Stream Active: " <> data
                    let _ = mist.send_text_frame(conn, msg)
                    file_helper.append_log("data_history.log", msg)
                    let _ = crypto_audit_add(msg)
                    timeseries_record_raw(msg)
                    let _ = ws_broadcast(msg)
                    mist.continue(subj)
                  }
                  mist.Text(text) -> {
                    let msg = "Update: " <> text
                    let _ = mist.send_text_frame(conn, msg)
                    file_helper.append_log("data_history.log", msg)
                    let _ = crypto_audit_add(msg)
                    timeseries_record_raw(msg)
                    let _ = ws_broadcast(msg)
                    case is_anomaly(msg) {
                      True -> {
                        case os_helper.get_env("WEBHOOK_URL") {
                          Ok(url) -> {
                            let key = case os_helper.get_env("AI_GATEWAY_KEY") {
                              Ok(k) -> k
                              Error(_) -> "no_key"
                            }
                            let diag = ai_diagnose_anomaly(msg, key)
                            dispatch_webhook_alert(url, msg, diag)
                          }
                          Error(_) -> Nil
                        }
                      }
                      False -> Nil
                    }
                    mist.continue(subj)
                  }
                  _ -> mist.continue(subj)
                }
              }
            )
          }
          False -> {
            response.new(401)
            |> response.set_body(mist.Bytes(bytes_tree.new()))
          }
        }
      }
      _ -> wisp_app(req)
    }
  }

  let port = parse_port(os_helper.get_env("PORT"))

  let assert Ok(_) =
    router
    |> mist.new
    |> mist.port(port)
    |> mist.start

  io.println("Yoda Semantic Redis Cache & Multi-Model Server started on http://localhost:" <> int.to_string(port))
  process.sleep_forever()
}

pub fn parse_port(port_str: Result(String, Nil)) -> Int {
  case port_str {
    Ok(val) -> case int.parse(val) {
      Ok(p) -> p
      Error(_) -> 8000
    }
    Error(_) -> 8000
  }
}

pub fn is_anomaly(s: String) -> Bool {
  check_anomaly_robust(s)
}

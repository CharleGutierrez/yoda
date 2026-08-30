import gleeunit
import gleeunit/should
import server
import gleam/string

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_port_test() {
  // Test valid port
  server.parse_port(Ok("8080"))
  |> should.equal(8080)

  // Test invalid port defaults to 8000
  server.parse_port(Ok("not_a_number"))
  |> should.equal(8000)

  // Test missing port defaults to 8000
  server.parse_port(Error(Nil))
  |> should.equal(8000)
}

pub fn is_anomaly_test() {
  // Normal value (< 80)
  server.is_anomaly("Update: 45.2")
  |> should.equal(False)

  server.is_anomaly("{\"sensor\":\"pressure\",\"value\":35.0}")
  |> should.equal(False)

  // Anomalous value (> 80)
  server.is_anomaly("Update: 89.4")
  |> should.equal(True)

  server.is_anomaly("{\"sensor\":\"temp_01\",\"value\":94.8}")
  |> should.equal(True)

  server.is_anomaly("Critical surge 99.9 psi")
  |> should.equal(True)
}

pub fn active_users_test() {
  server.init_active_users()
  
  // increment
  server.active_users_increment()
  |> should.equal(1)
  
  server.active_users_increment()
  |> should.equal(2)
  
  // decrement
  server.active_users_decrement()
  |> should.equal(1)
  
  // count
  server.active_users_get_count()
  |> should.equal(1)
}

pub fn rate_limiter_test() {
  server.init_rate_limiter()
  let limit = 5
  
  server.rate_limit_check("127.0.0.1", limit)
  |> should.equal(True)
}

pub fn cassandra_engine_cql_crud_test() {
  server.init_db_manager()

  // 1. Describe tables
  let desc = server.cassandra_execute_cql("DESCRIBE TABLES;")
  should.be_true(string.contains(desc, "telemetry_by_device"))

  // 2. Select initial seeded row
  let sel1 = server.cassandra_execute_cql("SELECT * FROM telemetry_by_device WHERE device_id = 'device_alpha';")
  should.be_true(string.contains(sel1, "device_alpha") || string.contains(sel1, "rows"))

  // 3. Insert wide row with TTL
  let ins = server.cassandra_execute_cql("INSERT INTO telemetry_by_device (device_id, bucket_day, timestamp, temperature, voltage, status) VALUES ('dev_omega', '2026-08-30', 1720000888, 55.4, 12.5, 'SURGE') USING TTL 3600;")
  should.be_true(string.contains(ins, "applied") && string.contains(ins, "token"))

  // 4. Select inserted row
  let sel2 = server.cassandra_execute_cql("SELECT temperature, status FROM telemetry_by_device WHERE device_id = 'dev_omega';")
  should.be_true(string.contains(sel2, "55.4") || string.contains(sel2, "SURGE"))

  // 5. Update row
  let upd = server.cassandra_execute_cql("UPDATE telemetry_by_device SET temperature = 60.1 WHERE device_id = 'dev_omega';")
  should.be_true(string.contains(upd, "applied"))

  // 6. Delete row (tombstone)
  let del = server.cassandra_execute_cql("DELETE FROM telemetry_by_device WHERE device_id = 'dev_omega';")
  should.be_true(string.contains(del, "tombstoned") || string.contains(del, "ok"))

  // 7. Consistency setting
  let c_res = server.cassandra_execute_cql("CONSISTENCY LOCAL_QUORUM;")
  should.be_true(string.contains(c_res, "LOCAL_QUORUM"))
}

pub fn cassandra_full_e2e_integration_test() {
  server.init_db_manager()

  // 1. Create Keyspace
  let create_ks = server.cassandra_execute_cql("CREATE KEYSPACE test_analytics WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 3};")
  should.be_true(string.contains(create_ks, "ok") && string.contains(create_ks, "CREATE_KEYSPACE"))

  // 2. Use Keyspace
  let use_ks = server.cassandra_execute_cql("USE test_analytics;")
  should.be_true(string.contains(use_ks, "test_analytics"))

  // 3. Create Table with Composite Partition Key and Clustering Key
  let create_tab = server.cassandra_execute_cql("CREATE TABLE metrics_stream (device_id text, region text, timestamp bigint, value double, PRIMARY KEY ((device_id, region), timestamp));")
  should.be_true(string.contains(create_tab, "metrics_stream") && string.contains(create_tab, "CREATE_TABLE"))

  // 4. Insert Row with TTL
  let ins = server.cassandra_execute_cql("INSERT INTO metrics_stream (device_id, region, timestamp, value) VALUES ('dev_alpha', 'us_east', 1720001000, 99.4) USING TTL 7200;")
  should.be_true(string.contains(ins, "applied") && string.contains(ins, "token"))

  // 5. Batch Insert
  let batch = server.cassandra_execute_cql("BEGIN BATCH INSERT INTO metrics_stream (device_id, region, timestamp, value) VALUES ('dev_beta', 'eu_west', 1720001001, 10.2); INSERT INTO metrics_stream (device_id, region, timestamp, value) VALUES ('dev_beta', 'eu_west', 1720001002, 10.5); APPLY BATCH;")
  should.be_true(string.contains(batch, "batch_applied") && string.contains(batch, "statements_executed"))

  // 6. Point Query by Composite Partition Key
  let sel_pt = server.cassandra_execute_cql("SELECT * FROM metrics_stream WHERE device_id = 'dev_alpha' AND region = 'us_east';")
  should.be_true(string.contains(sel_pt, "99.4") && string.contains(sel_pt, "rows"))

  // 7. Count Aggregation Query
  let count_res = server.cassandra_execute_cql("SELECT COUNT(*) FROM metrics_stream WHERE device_id = 'dev_beta' AND region = 'eu_west';")
  should.be_true(string.contains(count_res, "count") && string.contains(count_res, "2"))

  // 8. Update cell
  let upd = server.cassandra_execute_cql("UPDATE metrics_stream SET value = 100.5 WHERE device_id = 'dev_alpha' AND region = 'us_east' AND timestamp = 1720001000;")
  should.be_true(string.contains(upd, "applied"))

  // 9. Describe Table Schema
  let desc_tab = server.cassandra_execute_cql("DESCRIBE TABLE metrics_stream;")
  should.be_true(string.contains(desc_tab, "device_id") && string.contains(desc_tab, "partition_keys"))

  // 10. Delete Row (Tombstoning)
  let del = server.cassandra_execute_cql("DELETE FROM metrics_stream WHERE device_id = 'dev_alpha' AND region = 'us_east' AND timestamp = 1720001000;")
  should.be_true(string.contains(del, "tombstoned"))

  // 11. Verify Tombstone filters out deleted row
  let sel_after_del = server.cassandra_execute_cql("SELECT * FROM metrics_stream WHERE device_id = 'dev_alpha' AND region = 'us_east';")
  should.be_true(string.contains(sel_after_del, "rows\":[]"))

  // 12. Truncate Table
  let trunc = server.cassandra_execute_cql("TRUNCATE metrics_stream;")
  should.be_true(string.contains(trunc, "truncated"))

  // 13. Drop Table
  let drop_tab = server.cassandra_execute_cql("DROP TABLE metrics_stream;")
  should.be_true(string.contains(drop_tab, "dropped"))

  // Switch back to default keyspace
  let _ = server.cassandra_execute_cql("USE yoda_ks;")
  Nil
}

pub fn cassandra_engine_ring_and_ai_test() {
  server.init_db_manager()

  // 1. Test ring topology
  let ring = server.cassandra_get_ring()
  should.be_true(string.contains(ring, "node1.us-east-1") && string.contains(ring, "node6.ap-southeast-1"))

  // 2. Test AI analyze ring
  let ai_ring = server.cassandra_ai_analyze_ring()
  should.be_true(string.contains(ai_ring, "Murmur3") && string.contains(ai_ring, "skew_variance"))

  // 3. Test AI CQL query tuner (Detect ALLOW FILTERING anti-pattern)
  let ai_tune = server.cassandra_ai_tune("SELECT * FROM telemetry_by_device ALLOW FILTERING;", "no_key")
  should.be_true(string.contains(ai_tune, "ALLOW FILTERING") && string.contains(ai_tune, "TWCS"))

  // 4. Test stats
  let stats = server.cassandra_get_stats()
  should.be_true(string.contains(stats, "total_writes") && string.contains(stats, "ring_nodes"))

  // 5. Test table & keyspace listing
  let tables = server.cassandra_list_tables()
  should.be_true(list_has_item(tables, "telemetry_by_device"))

  let kss = server.cassandra_list_keyspaces()
  should.be_true(list_has_item(kss, "yoda_ks"))
}

pub fn elasticsearch_bm25_search_test() {
  server.init_db_manager()

  // 1. Basic text search on seeded log
  let res1 = server.elastic_search_index("yoda_logs", "timeout")
  should.be_true(string.contains(res1, "hits") && string.contains(res1, "log_001"))

  // 2. Index new document
  let doc_id = server.elastic_index_doc("yoda_logs", "log_999", "{\"level\":\"CRITICAL\",\"status\":502,\"message\":\"Kafka stream buffer overflow in gateway\",\"service\":\"gateway_node\"}")
  should.equal(doc_id, "log_999")

  // 3. Search for newly indexed document
  let res2 = server.elastic_search_index("yoda_logs", "overflow")
  should.be_true(string.contains(res2, "log_999") && string.contains(res2, "Kafka"))

  // 4. Exact term filter
  let term_query = "{\"query\":{\"term\":{\"status\":502}}}"
  let res3 = server.elastic_search_index("yoda_logs", term_query)
  should.be_true(string.contains(res3, "log_999"))
}

pub fn elasticsearch_query_dsl_and_aggs_test() {
  server.init_db_manager()

  // 1. Bool Query with must and filter
  let bool_query = "{\"query\":{\"bool\":{\"must\":[{\"match\":{\"message\":\"timeout\"}}],\"filter\":[{\"range\":{\"status\":{\"gte\":400,\"lte\":599}}}]}}}"
  let res_bool = server.elastic_search_index("yoda_logs", bool_query)
  should.be_true(string.contains(res_bool, "log_001"))

  // 2. Fuzzy search with typo tolerance (conection -> connection)
  let fuzzy_query = "{\"query\":{\"fuzzy\":{\"message\":\"conection\"}}}"
  let res_fuzzy = server.elastic_search_index("yoda_logs", fuzzy_query)
  should.be_true(string.contains(res_fuzzy, "log_001") && string.contains(res_fuzzy, "timeout"))

  // 3. Terms Aggregation on level
  let aggs_query = "{\"query\":{\"match_all\":{}},\"aggs\":{\"by_level\":{\"terms\":{\"field\":\"level\"}},\"status_stats\":{\"stats\":{\"field\":\"status\"}}}}"
  let res_aggs = server.elastic_search_index("yoda_logs", aggs_query)
  should.be_true(string.contains(res_aggs, "aggregations") && string.contains(res_aggs, "by_level") && string.contains(res_aggs, "status_stats"))

  // 4. Multi-match query
  let multi_query = "{\"query\":{\"multi_match\":{\"query\":\"error\",\"fields\":[\"message\",\"level\"]}}}"
  let res_multi = server.elastic_search_index("yoda_logs", multi_query)
  should.be_true(string.contains(res_multi, "log_001") || string.contains(res_multi, "log_004"))
}

pub fn elasticsearch_ai_tuner_and_stats_test() {
  server.init_db_manager()

  // 1. AI Tuner on Wildcard Anti-Pattern
  let ai_tune = server.elastic_ai_tune("{\"query\":{\"wildcard\":{\"message\":\"*timeout*\"}}}", "no_key")
  should.be_true(string.contains(ai_tune, "CRITICAL") && string.contains(ai_tune, "wildcard"))

  // 2. AI Index Analysis
  let ai_analysis = server.elastic_ai_analyze_index("yoda_logs")
  should.be_true(string.contains(ai_analysis, "bm25_parameters") && string.contains(ai_analysis, "yoda_logs"))

  // 3. Indices listing
  let indices = server.elastic_get_indices()
  should.be_true(string.contains(indices, "yoda_logs") && string.contains(indices, "green"))

  // 4. Stats telemetry
  let stats = server.elastic_get_stats()
  should.be_true(string.contains(stats, "yoda-elasticsearch") && string.contains(stats, "total_documents"))
}

pub fn olap_vectorized_query_and_aggs_test() {
  server.init_db_manager()

  // 1. Vectorized Filter and Projection
  let q1 = "SELECT device_id, temperature, region FROM sensor_telemetry WHERE temperature > 45.0 LIMIT 10;"
  let res1 = server.olap_query("sensor_telemetry", q1)
  should.be_true(string.contains(res1, "sensor_telemetry") && string.contains(res1, "data"))

  // 2. Vectorized Group By Aggregations
  let q2 = "SELECT region, COUNT(*) AS total, AVG(temperature) AS avg_temp, MAX(pressure) AS max_press FROM sensor_telemetry GROUP BY region;"
  let res2 = server.olap_query("sensor_telemetry", q2)
  should.be_true(string.contains(res2, "avg_temp") && string.contains(res2, "us-east") && string.contains(res2, "total"))

  // 3. Vectorized Having Filter
  let q3 = "SELECT region, AVG(temperature) AS avg_temp FROM sensor_telemetry GROUP BY region HAVING AVG(temperature) > 20.0;"
  let res3 = server.olap_query("sensor_telemetry", q3)
  should.be_true(string.contains(res3, "avg_temp"))
}

pub fn olap_financial_trades_grouping_test() {
  server.init_db_manager()

  // 1. Financial Trades Grouping by Symbol
  let q1 = "SELECT symbol, COUNT(*) AS trades, SUM(volume) AS total_vol, AVG(price) AS avg_price FROM financial_trades GROUP BY symbol;"
  let res1 = server.olap_query("financial_trades", q1)
  should.be_true(string.contains(res1, "BTC-USD") && string.contains(res1, "trades") && string.contains(res1, "total_vol"))

  // 2. Generic execute olap
  let q2 = "SELECT symbol, AVG(price) AS p FROM financial_trades GROUP BY symbol;"
  let res2 = server.olap_execute(q2)
  should.be_true(string.contains(res2, "data") && string.contains(res2, "p"))
}

pub fn olap_ai_tuner_and_stats_test() {
  server.init_db_manager()

  // 1. AI Tuner on SELECT * anti-pattern & clustering recommendation
  let ai_tune = server.olap_ai_tune("SELECT * FROM sensor_telemetry WHERE region = 'us-east' AND timestamp > 1720000000 GROUP BY region;", "no_key")
  should.be_true(string.contains(ai_tune, "CRITICAL") && string.contains(ai_tune, "ORDER BY") && string.contains(ai_tune, "autonomous_olap_ai_optimized"))

  // 2. AI Warehouse Analysis
  let ai_analysis = server.olap_ai_analyze_warehouse()
  should.be_true(string.contains(ai_analysis, "SIMD") && string.contains(ai_analysis, "warehouse_ai_verified"))

  // 3. Tables catalog
  let tables = server.olap_get_tables()
  should.be_true(string.contains(tables, "sensor_telemetry") && string.contains(tables, "financial_trades"))

  // 4. Stats telemetry
  let stats = server.olap_get_stats()
  should.be_true(string.contains(stats, "vector_simd_width") && string.contains(stats, "total_columnar_cells"))
}

pub fn multi_db_manager_top10_engines_routing_test() {
  server.init_db_manager()

  // 1. List all 10 Engines
  let engines = server.db_list_engines()
  should.be_true(
    string.contains(engines, "postgres")
    && string.contains(engines, "redis")
    && string.contains(engines, "mongodb")
    && string.contains(engines, "snowflake")
    && string.contains(engines, "elasticsearch")
    && string.contains(engines, "scylla_cassandra")
  )

  // 2. Query Redis via DB Manager
  let _ = server.db_execute_query("redis", "SET master_cluster_status ACTIVE")
  let redis_res = server.db_execute_query("redis", "GET master_cluster_status")
  should.be_true(string.contains(redis_res, "ACTIVE"))

  // 3. Query MongoDB via DB Manager
  let mongo_res = server.db_execute_query("mongodb", "db.device_registry.find({})")
  should.be_true(string.contains(mongo_res, "gateway_eu_01") || string.contains(mongo_res, "documents"))

  // 4. Query Elasticsearch via DB Manager
  let elastic_res = server.db_execute_query("elasticsearch", "timeout")
  should.be_true(string.contains(elastic_res, "hits"))

  // 5. Query ClickHouse/Snowflake via DB Manager
  let olap_res = server.db_execute_query("snowflake", "SELECT region, COUNT(*) AS count FROM sensor_telemetry GROUP BY region;")
  should.be_true(string.contains(olap_res, "count") && string.contains(olap_res, "data"))

  // 6. Query Cassandra/Scylla via DB Manager
  let cass_res = server.db_execute_query("scylla_cassandra", "SELECT * FROM telemetry_by_device WHERE device_id = 'device_alpha';")
  should.be_true(string.contains(cass_res, "device_alpha") || string.contains(cass_res, "rows"))
}

pub fn multi_db_manager_auto_routing_test() {
  server.init_db_manager()

  // 1. Auto-route Redis syntax
  let redis_auto = server.db_auto_route("SET auto_key test_val")
  should.be_true(string.contains(redis_auto, "OK") || string.contains(redis_auto, "result"))

  // 2. Auto-route Mongo syntax
  let mongo_auto = server.db_auto_route("db.users.find({\"role\":\"superadmin\"})")
  should.be_true(string.contains(mongo_auto, "admin") || string.contains(mongo_auto, "documents"))

  // 3. Auto-route Cassandra syntax
  let cass_auto = server.db_auto_route("DESCRIBE KEYSPACES;")
  should.be_true(string.contains(cass_auto, "keyspace_name") || string.contains(cass_auto, "yoda_ks"))

  // 4. Auto-route Snowflake/ClickHouse syntax
  let olap_auto = server.db_auto_route("SELECT region, AVG(temperature) AS avg_temp FROM sensor_telemetry GROUP BY region;")
  should.be_true(string.contains(olap_auto, "avg_temp") && string.contains(olap_auto, "data"))
}

pub fn multi_db_manager_pool_tuning_and_ai_test() {
  server.init_db_manager()

  // 1. Connection Pool Stats
  let pool_stats = server.db_get_pool_stats()
  should.be_true(string.contains(pool_stats, "postgres") && string.contains(pool_stats, "redis"))

  // 2. Dynamic Pool Tuning
  let tune_res = server.db_tune_pool("postgres", 100, 20)
  should.be_true(string.contains(tune_res, "dynamically_ai_tuned") && string.contains(tune_res, "100"))

  // 3. AI Multi-DB Tuner Workload Routing Recommendation
  let ai_tune = server.db_tune_query("SELECT region, AVG(cost_usd) FROM sensor_telemetry GROUP BY region;", "no_key")
  should.be_true(string.contains(ai_tune, "Snowflake") || string.contains(ai_tune, "Columnar OLAP"))
}

pub fn ai_query_optimizer_cbo_and_cost_analysis_test() {
  server.init_db_manager()

  // 1. Cost-Based Optimization and Cost Reduction Percentage
  let q = "SELECT * FROM sensor_telemetry WHERE temperature > 50.0 AND region = 'us-east' GROUP BY region;"
  let tune_res = server.db_tune_query(q, "no_key")
  should.be_true(
    string.contains(tune_res, "cost_analysis")
    && string.contains(tune_res, "estimated_cost_original")
    && string.contains(tune_res, "estimated_cost_optimized")
    && string.contains(tune_res, "cost_reduction_pct")
    && string.contains(tune_res, "autonomous_cbo_ai_optimized")
  )

  // 2. Execution plan presence in tune report
  should.be_true(string.contains(tune_res, "execution_plan") && string.contains(tune_res, "Node Type"))
}

pub fn ai_query_optimizer_plan_explain_and_rewrite_test() {
  server.init_db_manager()

  // 1. Explain Plan Tree
  let q1 = "SELECT region, COUNT(*) FROM sensor_telemetry WHERE temperature > 40.0 GROUP BY region ORDER BY count DESC LIMIT 10;"
  let plan_res = server.db_explain_plan(q1)
  should.be_true(
    string.contains(plan_res, "Node Type")
    && string.contains(plan_res, "Total Cost")
    && string.contains(plan_res, "Plan Rows")
  )

  // 2. Automated Query Rewrite
  let q2 = "SELECT * FROM sensor_telemetry WHERE region = 'eu-central';"
  let rewrite_res = server.db_optimize_rewrite(q2)
  should.be_true(string.contains(rewrite_res, "device_id") && string.contains(rewrite_res, "LIMIT 100"))
}

pub fn ai_query_optimizer_index_synthesis_test() {
  server.init_db_manager()

  // 1. Synthesize Indexes for composite predicates and grouping
  let q = "SELECT region, temperature FROM sensor_telemetry WHERE region = 'us-east' AND status = 'NORMAL' AND device_id LIKE '%alpha%' GROUP BY region;"
  let idx_res = server.db_synthesize_indexes(q)
  should.be_true(
    string.contains(idx_res, "CREATE INDEX")
    && string.contains(idx_res, "idx_sensor_telemetry")
  )
}

fn list_has_item(items: List(String), target: String) -> Bool {
  case items {
    [] -> False
    [x, ..rest] -> case x == target {
      True -> True
      False -> list_has_item(rest, target)
    }
  }
}

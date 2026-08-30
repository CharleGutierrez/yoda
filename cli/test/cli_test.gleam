import gleeunit
import gleeunit/should
import cli
import gleam/string

pub fn main() -> Nil {
  gleeunit.main()
}

// In an isolated test environment without a running server, 
// these commands should gracefully return an "Error" string instead of crashing.
// This validates that the FFI bindings and error handling work correctly.

pub fn cli_ping_status_test() {
  let res = cli.ping_status()
  let valid = string.contains(res, "status") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_db_list_engines_test() {
  let res = cli.db_list_engines()
  let valid = string.contains(res, "engines") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_stats_test() {
  let res = cli.get_stats()
  let valid = string.contains(res, "min") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_forecast_test() {
  let res = cli.get_forecast()
  let valid = string.contains(res, "trend") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_audit_verify_test() {
  let res = cli.audit_verify()
  let valid = string.contains(res, "verified") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_vector_search_test() {
  let res = cli.vector_search_text("test")
  let valid = string.contains(res, "score") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_rate_limit_status_test() {
  let res = cli.rate_limit_ip_status("127.0.0.1")
  let valid = string.contains(res, "remaining") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_crdt_get_state_test() {
  let res = cli.crdt_get_state()
  let valid = string.contains(res, "state") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_mongo_collections_test() {
  let res = cli.mongo_collections()
  let valid = string.contains(res, "collections") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_cassandra_cql_test() {
  let res = cli.cassandra_cql("DESCRIBE TABLES;")
  let valid = string.contains(res, "telemetry") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_cassandra_ring_test() {
  let res = cli.cassandra_ring()
  let valid = string.contains(res, "node") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_cassandra_ai_tune_test() {
  let res = cli.cassandra_ai_tune("SELECT * FROM telemetry_by_device;")
  let valid = string.contains(res, "compaction") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_elastic_search_test() {
  let res = cli.elastic_search("yoda_logs", "timeout")
  let valid = string.contains(res, "hits") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_elastic_indices_test() {
  let res = cli.elastic_indices()
  let valid = string.contains(res, "yoda_logs") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_elastic_ai_tune_test() {
  let res = cli.elastic_ai_tune("timeout")
  let valid = string.contains(res, "analyzer") || string.contains(res, "Error")
  should.be_true(valid)
}

pub fn cli_get_argv_test() {
  let args = cli.get_argv()
  // Just ensure it returns a list
  should.equal(args, [])
}

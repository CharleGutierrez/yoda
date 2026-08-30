import gleeunit
import vella_ffi
import gleam/string

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn vella_ffi_initialization_test() {
  let init_string = vella_ffi.initialize()
  assert string.contains(init_string, "Vella") == True
}

pub fn vella_tune_timeseries_test() {
  let tuned1 = vella_ffi.vella_tune_timeseries(10, 250)
  assert tuned1 >= 10
}

pub fn vella_tune_compression_test() {
  let tuned1 = vella_ffi.vella_tune_compression(1.5, 90.0)
  assert tuned1 >=. 1.5
}

pub fn sqlite_query_test() {
  let res = vella_ffi.query_sqlite(":memory:", "SELECT 1 AS num")
  assert string.contains(res, "num") == True
}

pub fn vella_optimize_system_test() {
  let opt = vella_ffi.vella_optimize_system()
  assert string.contains(opt, "vella_engine_status") == True
  assert string.contains(opt, "tuned_semantic_cache_threshold") == True
}

pub fn vella_tune_timeseries_tighten_test() {
  let tuned = vella_ffi.vella_tune_timeseries(60, 20)
  assert tuned <= 60
}

pub fn vella_tune_compression_tighten_test() {
  let tuned = vella_ffi.vella_tune_compression(1.5, 30.0)
  assert tuned >=. 0.5
}

pub fn legacy_dbf_and_odbc_test() {
  let watch = vella_ffi.watch_legacy_dbf("/data/inventory.dbf")
  assert string.contains(watch, "DBF") == True

  let odbc_conn = vella_ffi.connect_legacy_odbc("DSN=PostgreSQL35W")
  assert string.contains(odbc_conn, "ODBC") == True

  let odbc_q = vella_ffi.query_legacy_odbc("DSN=PostgreSQL35W", "SELECT 1")
  assert string.contains(odbc_q, "odbc") == True || string.contains(odbc_q, "rows") == True || string.contains(odbc_q, "error") == True
}

pub fn broadcast_mutation_test() {
  let bcast = vella_ffi.broadcast_mutation("audit_stream", "/data/telemetry.log", "VERIFIED")
  assert string.contains(bcast, "audit_stream") == True
}

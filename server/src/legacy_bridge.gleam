import vella_ffi

pub fn initialize_vella() -> String {
  vella_ffi.initialize()
}

pub fn run_vella_system_optimization() -> String {
  vella_ffi.vella_optimize_system()
}

pub fn tune_timeseries_resolution(base_interval: Int, last_latency: Int) -> Int {
  vella_ffi.vella_tune_timeseries(base_interval, last_latency)
}

pub fn tune_compression_threshold(base_deviation: Float, disk_usage: Float) -> Float {
  vella_ffi.vella_tune_compression(base_deviation, disk_usage)
}

pub fn start_legacy_sync(file_path: String) -> String {
  let status = vella_ffi.watch_legacy_dbf(file_path)
  let _ = vella_ffi.broadcast_mutation("legacy_sync", file_path, status)
  status
}

pub fn test_odbc_connection(connection_string: String) -> String {
  vella_ffi.connect_legacy_odbc(connection_string)
}

pub fn execute_odbc_query(connection_string: String, query: String) -> String {
  vella_ffi.query_legacy_odbc(connection_string, query)
}

pub fn execute_sqlite_query(db_path: String, query: String) -> String {
  vella_ffi.query_sqlite(db_path, query)
}

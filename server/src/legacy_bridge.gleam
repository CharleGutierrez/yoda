import vella_ffi

pub fn initialize_vella() -> String {
  vella_ffi.initialize()
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

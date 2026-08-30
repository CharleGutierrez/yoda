@external(erlang, "vella_nif", "initialize")
pub fn initialize() -> String

@external(erlang, "vella_nif", "vella_optimize_system")
pub fn vella_optimize_system() -> String

@external(erlang, "vella_nif", "vella_tune_timeseries")
pub fn vella_tune_timeseries(base_interval: Int, last_latency: Int) -> Int

@external(erlang, "vella_nif", "vella_tune_compression")
pub fn vella_tune_compression(base_deviation: Float, disk_usage: Float) -> Float

@external(erlang, "vella_nif", "query_sqlite")
pub fn query_sqlite(db_path: String, query: String) -> String

@external(erlang, "vella_nif", "watch_legacy_dbf")
pub fn watch_legacy_dbf(path: String) -> String

@external(erlang, "vella_nif", "connect_legacy_odbc")
pub fn connect_legacy_odbc(connection_string: String) -> String

@external(erlang, "vella_nif", "query_legacy_odbc")
pub fn query_legacy_odbc(connection_string: String, query: String) -> String

@external(erlang, "vella_nif", "broadcast_mutation")
pub fn broadcast_mutation(topic: String, path: String, status: String) -> String

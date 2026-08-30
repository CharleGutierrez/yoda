@external(erlang, "vella_nif", "initialize")
pub fn initialize() -> String

@external(erlang, "vella_nif", "watch_legacy_dbf")
pub fn watch_legacy_dbf(path: String) -> String

@external(erlang, "vella_nif", "connect_legacy_odbc")
pub fn connect_legacy_odbc(connection_string: String) -> String

@external(erlang, "vella_nif", "query_legacy_odbc")
pub fn query_legacy_odbc(connection_string: String, query: String) -> String

@external(erlang, "vella_nif", "broadcast_mutation")
pub fn broadcast_mutation(topic: String, path: String, status: String) -> String

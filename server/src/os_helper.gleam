@external(erlang, "os_helper_ffi", "get_env")
pub fn get_env(key: String) -> Result(String, Nil)

@external(erlang, "os_helper_ffi", "system_time_seconds")
pub fn system_time_seconds() -> Int

@external(erlang, "os_helper_ffi", "get_argv")
pub fn get_argv() -> List(String)

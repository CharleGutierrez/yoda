@external(erlang, "file_helper_ffi", "append_log")
pub fn append_log(filename: String, line: String) -> Nil

@external(erlang, "file_helper_ffi", "read_tail")
pub fn read_tail(filename: String, max_lines: Int) -> List(String)

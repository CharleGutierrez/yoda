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

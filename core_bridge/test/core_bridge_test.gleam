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

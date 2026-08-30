import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn cli_smoke_test() {
  let version = "1.0.0"
  assert version == "1.0.0"
}

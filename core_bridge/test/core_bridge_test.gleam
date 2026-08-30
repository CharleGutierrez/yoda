import gleeunit
import core_bridge

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn core_bridge_init_test() {
  let res = core_bridge.main()
  assert res == Nil
}

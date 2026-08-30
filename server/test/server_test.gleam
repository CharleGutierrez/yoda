import gleeunit
import server

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn parse_port_test() {
  // Test valid port
  let result = server.parse_port(Ok("8080"))
  assert result == 8080

  // Test invalid port defaults to 8000
  let result2 = server.parse_port(Ok("not_a_number"))
  assert result2 == 8000

  // Test missing port defaults to 8000
  let result3 = server.parse_port(Error(Nil))
  assert result3 == 8000
}

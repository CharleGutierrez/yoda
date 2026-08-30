import gleeunit
import server

pub fn main() -> Nil {
  gleeunit.main()
}

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

pub fn is_anomaly_test() {
  // Normal value (< 80)
  assert server.is_anomaly("Update: 45.2") == False
  assert server.is_anomaly("{\"sensor\":\"pressure\",\"value\":35.0}") == False

  // Anomalous value (> 80)
  assert server.is_anomaly("Update: 89.4") == True
  assert server.is_anomaly("{\"sensor\":\"temp_01\",\"value\":94.8}") == True
  assert server.is_anomaly("Critical surge 99.9 psi") == True
}

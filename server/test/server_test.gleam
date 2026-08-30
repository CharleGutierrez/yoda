import gleeunit
import gleeunit/should
import server

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_port_test() {
  // Test valid port
  server.parse_port(Ok("8080"))
  |> should.equal(8080)

  // Test invalid port defaults to 8000
  server.parse_port(Ok("not_a_number"))
  |> should.equal(8000)

  // Test missing port defaults to 8000
  server.parse_port(Error(Nil))
  |> should.equal(8000)
}

pub fn is_anomaly_test() {
  // Normal value (< 80)
  server.is_anomaly("Update: 45.2")
  |> should.equal(False)

  server.is_anomaly("{\"sensor\":\"pressure\",\"value\":35.0}")
  |> should.equal(False)

  // Anomalous value (> 80)
  server.is_anomaly("Update: 89.4")
  |> should.equal(True)

  server.is_anomaly("{\"sensor\":\"temp_01\",\"value\":94.8}")
  |> should.equal(True)

  server.is_anomaly("Critical surge 99.9 psi")
  |> should.equal(True)
}

pub fn active_users_test() {
  server.init_active_users()
  
  // increment
  server.active_users_increment()
  |> should.equal(1)
  
  server.active_users_increment()
  |> should.equal(2)
  
  // decrement
  server.active_users_decrement()
  |> should.equal(1)
  
  // count
  server.active_users_get_count()
  |> should.equal(1)
}

pub fn rate_limiter_test() {
  server.init_rate_limiter()
  let limit = 5
  
  server.rate_limit_check("127.0.0.1", limit)
  |> should.equal(True)
}

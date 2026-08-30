import gleeunit
import gleeunit/should
import cli

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn ping_status_offline_test() {
  // Validates HTTP failure handling (returns error instead of crashing)
  cli.ping_status()
  |> should.equal("Error connecting to server")
}

pub fn get_anomalies_offline_test() {
  cli.get_anomalies()
  |> should.equal("Error connecting to server")
}

pub fn unban_offline_test() {
  cli.unban("127.0.0.1")
  |> should.equal("Error connecting to server")
}

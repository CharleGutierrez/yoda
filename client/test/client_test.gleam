import gleeunit
import client

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn client_model_test() {
  let model = client.Model(
    hft_data: "test_data",
    ai_insight: "test_insight",
    ai_prompt: "test_prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  assert model.theme == "dark-mode"
  assert model.hft_data == "test_data"
}

pub fn client_update_theme_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.UpdateTheme)
  assert updated.theme == "light-mode"
}

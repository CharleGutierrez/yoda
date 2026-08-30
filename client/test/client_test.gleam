import gleeunit
import gleeunit/should
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
  should.equal(model.theme, "dark-mode")
  should.equal(model.hft_data, "test_data")
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
  should.equal(updated.theme, "light-mode")
  
  let #(updated2, _) = client.update(updated, client.UpdateTheme)
  should.equal(updated2.theme, "dark-mode")
}

pub fn client_update_hft_test() {
  let initial = client.Model(
    hft_data: "Waiting for stream...",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.UpdateHFT("Data arrived"))
  should.equal(updated.hft_data, "Data arrived")
  
  let #(updated2, _) = client.update(updated, client.UpdateHFT("More data"))
  should.equal(updated2.hft_data, "Data arrived\\nMore data")
}

pub fn client_update_ai_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.UpdateAI("New AI insight"))
  should.equal(updated.ai_insight, "New AI insight")
}

pub fn client_update_prompt_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.UpdatePrompt("New Prompt"))
  should.equal(updated.ai_prompt, "New Prompt")
}

pub fn client_ws_connected_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connecting...",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.WsConnected)
  should.equal(updated.connection_state, "Status: Vella HFT Sync Active - Zero Latency (Secure)")
}

pub fn client_ws_disconnected_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.WsDisconnected)
  should.equal(updated.connection_state, "Status: Disconnected")
}

pub fn client_update_system_resources_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _) = client.update(initial, client.UpdateSystemResources("CPU: 5%"))
  should.equal(updated.system_resources, "CPU: 5%")
}

pub fn client_fetch_ai_test() {
  let initial = client.Model(
    hft_data: "data",
    ai_insight: "insight",
    ai_prompt: "prompt",
    theme: "dark-mode",
    connection_state: "connected",
    system_resources: "normal"
  )
  let #(updated, _effect) = client.update(initial, client.FetchAI)
  should.equal(updated.ai_insight, "Fetching AI data...")
}

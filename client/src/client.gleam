import lustre
import lustre/effect
import ui/dashboard
import ui/ai_builder

pub type Model {
  Model(hft_data: String, ai_insight: String, ai_prompt: String, theme: String, connection_state: String, system_resources: String)
}

@external(javascript, "./ui/ffi.mjs", "connect_ws")
pub fn connect_ws(token: String, on_open: fn() -> Nil, on_message: fn(String) -> Nil, on_close: fn() -> Nil) -> Nil

@external(javascript, "./ui/ffi.mjs", "fetch_history")
pub fn fetch_history(on_history: fn(String) -> Nil) -> Nil

@external(javascript, "./ui/ffi.mjs", "start_resource_polling")
pub fn start_resource_polling(on_res: fn(String) -> Nil) -> Nil

fn init(_) {
  let init_effect = effect.from(fn(dispatch) {
    fetch_history(fn(history) {
      dispatch(UpdateHFT(history))
      connect_ws(
        "yoda-secret",
        fn() { dispatch(WsConnected) },
        fn(msg) { dispatch(UpdateHFT(msg)) },
        fn() { dispatch(WsDisconnected) }
      )
    })
    
    // Also trigger initial AI fetch
    dispatch(FetchAI)
    
    start_resource_polling(fn(res) { dispatch(UpdateSystemResources(res)) })
  })
  #(Model(hft_data: "Waiting for stream...", ai_insight: "Loading AI insights...", ai_prompt: "Generate initial insights", theme: "dark-mode", connection_state: "Connecting...", system_resources: "Loading resources..."), init_effect)
}

pub type Msg {
  UpdateHFT(String)
  UpdateAI(String)
  FetchAI
  UpdatePrompt(String)
  UpdateTheme
  WsConnected
  WsDisconnected
  UpdateSystemResources(String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    UpdateHFT(data) -> {
      let new_data = case model.hft_data {
        "Waiting for stream..." -> data
        _ -> model.hft_data <> "\\n" <> data
      }
      #(Model(..model, hft_data: new_data), effect.none())
    }
    UpdateAI(data) -> #(Model(..model, ai_insight: data), effect.none())
    UpdatePrompt(prompt) -> #(Model(..model, ai_prompt: prompt), effect.none())
    UpdateTheme -> {
      let new_theme = case model.theme {
        "dark-mode" -> "light-mode"
        _ -> "dark-mode"
      }
      #(Model(..model, theme: new_theme), effect.none())
    }
    FetchAI -> {
      let fetch_effect = effect.from(fn(dispatch) {
        ai_builder.fetch_ai_insight(model.ai_prompt, fn(res) {
          dispatch(UpdateAI(res))
        })
      })
      #(Model(..model, ai_insight: "Fetching AI data..."), fetch_effect)
    }
    WsConnected -> #(Model(..model, connection_state: "Status: Vella HFT Sync Active - Zero Latency (Secure)"), effect.none())
    WsDisconnected -> #(Model(..model, connection_state: "Status: Disconnected"), effect.none())
    UpdateSystemResources(res) -> #(Model(..model, system_resources: res), effect.none())
  }
}

fn view(model: Model) {
  dashboard.dashboard_view(
    model.hft_data, 
    model.ai_insight,
    model.ai_prompt,
    model.theme,
    model.connection_state,
    model.system_resources,
    UpdatePrompt,
    fn() { FetchAI },
    UpdateTheme
  )
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

import lustre/element.{type Element, text}
import lustre/element/html.{div}
import gleam/string

pub type BuilderState {
  Generating
  Idle
  Error(String)
}

@external(javascript, "./ffi.mjs", "do_fetch_cb")
pub fn do_fetch_async(url: String, body: String, cb: fn(String) -> Nil) -> Nil

pub fn fetch_ai_insight(prompt: String, cb: fn(String) -> Nil) {
  let prompt_esc = string.replace(prompt, "\"", "\\\"")
  let body = "{\"model\": \"gpt-3.5-turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"" <> prompt_esc <> "\"}]}"
  do_fetch_async("/api/ai_insights", body, cb)
}

pub fn render_ai_ui(insight: String) -> Element(a) {
  div([], [
    text("AI dynamically says: "),
    text(insight)
  ])
}

pub fn render_ai_placeholder() -> Element(a) {
  div([], [
    text("Loading AI suggestions...")
  ])
}

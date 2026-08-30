import lustre/element.{text, element}
import lustre/element/html.{div, h1, h2, header, p, input, button}
import lustre/attribute.{class, attribute, value}
import lustre/event.{on_input, on_click}

// A sample Lustre component representing a Yoda Dashboard
// This UI is meant to be hooked directly to Vella's HFT streams for zero-latency updates
pub fn dashboard_view(
  live_hft_data: String, 
  ai_ephemeral_insight: String,
  ai_prompt: String,
  theme: String,
  connection_state: String,
  system_resources: String,
  on_prompt_change: fn(String) -> msg,
  on_fetch_ai: fn() -> msg,
  on_toggle_theme: msg
) {
  div([class("yoda-dashboard glassmorphism " <> theme)], [
    
    // Header section
    header([class("dashboard-header")], [
      h1([], [text("Yoda Enterprise Dashboard")]),
      button([on_click(on_toggle_theme)], [text("Toggle Theme")]),
      p([class("status-indicator")], [
        text(connection_state)
      ])
    ]),
    
    div([class("system-resources-panel")], [
      h2([], [text("Live System Resources")]),
      p([], [text("CPU & Memory Metrics: " <> system_resources)])
    ]),
    
    // Real-Time Data Grid hooked to ZK-Rollups / Legacy DB watchers
    div([class("grid-container")], [
      h2([], [text("Live ZK-Rollup & Legacy DB Stream")]),
      button([attribute("onclick", "document.querySelector('live-data-chart').exportToCsv()")], [text("Export Data")]),
      element("live-data-chart", [
        attribute("data", live_hft_data)
      ], []),
      element("complex-data-grid", [
        attribute("data", live_hft_data)
      ], [])
    ]),
    
    // AI Ephemeral UI Injection Panel
    div([class("ai-gateway-panel")], [
      h2([], [text("Autonomous AI Insights")]),
      div([class("ai-chat-interface")], [
        input([
          value(ai_prompt),
          on_input(on_prompt_change)
        ]),
        button([on_click(on_fetch_ai())], [text("Ask AI")])
      ]),
      element("custom-calendar", [
        attribute("event-text", ai_ephemeral_insight)
      ], [])
    ])
    
  ])
}

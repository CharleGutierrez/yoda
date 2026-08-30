import gleam/io
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import gleam/http/request
import gleam/http/response
import gleam/option.{None}
import legacy_bridge
import file_helper
import os_helper
import gleam/string
import gleam/http
import gleam/bytes_tree
import gleam/list
import gleam/int

@external(erlang, "curl_wrapper", "curl_post")
pub fn curl_post(url: String, key: String, body: String) -> String

@external(erlang, "system_resources", "get_memory_total")
pub fn get_memory_total() -> Int

@external(erlang, "system_resources", "get_cpu_time")
pub fn get_cpu_time() -> Int

@external(erlang, "rate_limiter", "init")
pub fn init_rate_limiter() -> Nil

@external(erlang, "rate_limiter", "check_and_increment")
pub fn rate_limit_check(ip: String, limit: Int) -> Bool

@external(erlang, "rate_limiter", "reset_ip")
pub fn rate_limit_reset(ip: String) -> Nil

@external(erlang, "webhook_helper", "dispatch")
pub fn dispatch_webhook(url: String, payload: String) -> Nil

@external(erlang, "log_rotator", "start")
pub fn start_log_rotator() -> Nil

@external(erlang, "log_rotator", "rotate")
pub fn rotate_log() -> Nil

@external(erlang, "active_users", "init")
pub fn init_active_users() -> Nil

@external(erlang, "active_users", "increment")
pub fn active_users_increment() -> Int

@external(erlang, "active_users", "decrement")
pub fn active_users_decrement() -> Int

@external(erlang, "active_users", "get_count")
pub fn active_users_get_count() -> Int

pub fn main() {
  wisp.configure_logger()
  init_rate_limiter()
  init_active_users()
  start_log_rotator()
  
  let start_time = os_helper.system_time_seconds()
  
  let handler = fn(req) {
    let ip = case request.get_header(req, "x-forwarded-for") {
      Ok(i) -> i
      Error(_) -> "127.0.0.1"
    }

    case rate_limit_check(ip, 100) {
      False -> {
        wisp.html_response("Too Many Requests", 429)
      }
      True -> {
        case wisp.path_segments(req) {
          ["api", "status"] -> {
            let uptime_val = os_helper.system_time_seconds() - start_time
            let dyn_val = int.to_string(uptime_val)
            wisp.json_response("{\"status\":\"healthy\",\"uptime\":" <> dyn_val <> "}", 200)
          }
          ["metrics"] -> {
            let uptime_val = os_helper.system_time_seconds() - start_time
            let dyn_val = int.to_string(uptime_val)
            wisp.html_response("# HELP yoda_uptime Server uptime\n# TYPE yoda_uptime gauge\nyoda_uptime " <> dyn_val <> "\n", 200)
          }
          ["api", "ai_insights"] -> {
            use req_body <- wisp.require_string_body(req)
            let key = case os_helper.get_env("AI_GATEWAY_KEY") {
              Ok(k) -> k
              Error(_) -> "no_key"
            }
            let url = "https://api.openai.com/v1/chat/completions"
            let resp_body = curl_post(url, key, req_body)
            wisp.json_response(resp_body, 200)
          }
          ["api", "history"] -> {
            let tail = file_helper.read_tail("data_history.log", 50)
            let json_array = "[" <> string.join(list.map(tail, fn(s) { "\"" <> string.replace(s, "\"", "\\\"") <> "\"" }), ",") <> "]"
            wisp.json_response(json_array, 200)
          }
          ["api", "anomalies"] -> {
            let tail = file_helper.read_tail("data_history.log", 100)
            let anomalies = list.filter(tail, is_anomaly)
            let json_array = "[" <> string.join(list.map(anomalies, fn(s) { "\"" <> string.replace(s, "\"", "\\\"") <> "\"" }), ",") <> "]"
            wisp.json_response(json_array, 200)
          }
          ["api", "system_resources"] -> {
            let mem = get_memory_total()
            let cpu = get_cpu_time()
            let json = "{\"memory\": " <> int.to_string(mem) <> ", \"cpu\": " <> int.to_string(cpu) <> "}"
            wisp.json_response(json, 200)
          }
          ["api", "unban"] -> {
            use req_body <- wisp.require_string_body(req)
            rate_limit_reset(string.trim(req_body))
            wisp.json_response("{\"status\":\"unbanned\"}", 200)
          }
          ["api", "test_webhook"] -> {
            use req_body <- wisp.require_string_body(req)
            let url = string.trim(req_body)
            dispatch_webhook(url, "{\"alert\": \"Yoda Test Anomaly\"}")
            wisp.json_response("{\"status\":\"dispatched\"}", 200)
          }
          ["api", "active_users"] -> {
            let count = active_users_get_count()
            let json = "{\"active_users\": " <> int.to_string(count) <> "}"
            wisp.json_response(json, 200)
          }
          ["api", "archive"] -> {
            case req.method {
              http.Post -> {
                rotate_log()
                wisp.json_response("{\"status\":\"archived\"}", 200)
              }
              _ -> wisp.html_response("Method Not Allowed", 405)
            }
          }
          _ -> wisp.html_response("<html><body><h1>Yoda Server Active</h1></body></html>", 200)
        }
      }
    }
  }
  
  let secret = wisp.random_string(64)
  let wisp_app = wisp_mist.handler(handler, secret)
  
  let router = fn(req: request.Request(mist.Connection)) -> response.Response(mist.ResponseData) {
    case request.path_segments(req) {
      ["ws"] -> {
        let is_auth = case request.get_query(req) {
          Ok(queries) -> case list.key_find(queries, "token") {
            Ok(t) -> case os_helper.get_env("WS_TOKEN") {
              Ok(env_t) -> t == env_t
              Error(_) -> False
            }
            _ -> False
          }
          _ -> False
        }
        case is_auth {
          True -> {
            mist.websocket(
              request: req,
              on_init: fn(_conn) { 
                let _ = active_users_increment()
                #(Nil, None) 
              },
              on_close: fn(_state) { 
                let _ = active_users_decrement()
                Nil 
              },
              handler: fn(state, message, conn) {
                case message {
                  mist.Text("start") -> {
                    let data = legacy_bridge.start_legacy_sync("data.dbf")
                    let msg = "HFT Stream Active: " <> data
                    let _ = mist.send_text_frame(conn, msg)
                    file_helper.append_log("data_history.log", msg)
                    mist.continue(state)
                  }
                  mist.Text(text) -> {
                    let msg = "Update: " <> text
                    let _ = mist.send_text_frame(conn, msg)
                    file_helper.append_log("data_history.log", msg)
                    case is_anomaly(msg) {
                      True -> {
                        case os_helper.get_env("WEBHOOK_URL") {
                          Ok(url) -> {
                            let payload = "{\"alert\":\"Anomaly detected\",\"message\":\"" <> string.replace(msg, "\"", "\\\"") <> "\"}"
                            dispatch_webhook(url, payload)
                          }
                          Error(_) -> Nil
                        }
                      }
                      False -> Nil
                    }
                    mist.continue(state)
                  }
                  _ -> mist.continue(state)
                }
              }
            )
          }
          False -> {
            response.new(401)
            |> response.set_body(mist.Bytes(bytes_tree.new()))
          }
        }
      }
      _ -> wisp_app(req)
    }
  }

  let port = parse_port(os_helper.get_env("PORT"))
  
  let _ai_gateway_key = case os_helper.get_env("AI_GATEWAY_KEY") {
    Ok(val) -> val
    Error(_) -> "default_key"
  }

  let assert Ok(_) =
    router
    |> mist.new
    |> mist.port(port)
    |> mist.start

  io.println("Server started on http://localhost:" <> int.to_string(port))
  process.sleep_forever()
}

pub fn parse_port(port_str: Result(String, Nil)) -> Int {
  case port_str {
    Ok(val) -> case int.parse(val) {
      Ok(p) -> p
      Error(_) -> 8000
    }
    Error(_) -> 8000
  }
}

pub fn is_anomaly(s: String) -> Bool {
  let s_lower = string.lowercase(s)
  case string.split(s_lower, "\"value\":") {
    [_, rest] -> {
      let val_str = string.slice(string.trim(rest), 0, 5)
      let clean1 = string.replace(val_str, "}", "")
      let clean2 = string.replace(clean1, ",", "")
      let clean3 = string.replace(clean2, "]", "")
      case int.parse(string.trim(clean3)) {
        Ok(v) -> v > 80
        Error(_) -> False
      }
    }
    _ -> {
      let just_val = string.replace(s_lower, "update:", "")
      let just_val = string.replace(just_val, " ", "")
      case int.parse(string.trim(just_val)) {
        Ok(v) -> v > 80
        Error(_) -> False
      }
    }
  }
}

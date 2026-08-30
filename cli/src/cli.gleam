import gleam/io
import glint

@external(erlang, "cli_ffi", "unban")
pub fn unban(ip: String) -> String

@external(erlang, "cli_ffi", "status")
pub fn ping_status() -> String

@external(erlang, "cli_ffi", "anomalies")
pub fn get_anomalies() -> String

@external(erlang, "cli_ffi", "top")
pub fn get_top() -> String

@external(erlang, "cli_ffi", "test_webhook")
pub fn test_webhook(url: String) -> String

@external(erlang, "cli_ffi", "archive")
pub fn archive_log() -> String

@external(erlang, "cli_ffi", "get_argv")
pub fn get_argv() -> List(String)

pub fn main() {
  let app =
    glint.new()
    |> glint.with_name("yoda")
    |> glint.pretty_help(glint.default_pretty_help())
    |> glint.add(
      at: ["status"],
      do: glint.command_help(
        "Pings the server status",
        fn() { glint.command(fn(_, _, _) { io.println(ping_status()) }) },
      ),
    )
    |> glint.add(
      at: ["version"],
      do: glint.command_help(
        "Prints CLI version",
        fn() { glint.command(fn(_, _, _) { io.println("Yoda CLI version 1.0.0") }) },
      ),
    )
    |> glint.add(
      at: ["anomalies"],
      do: glint.command_help(
        "Fetch and print anomalous data points",
        fn() { glint.command(fn(_, _, _) { io.println(get_anomalies()) }) },
      ),
    )
    |> glint.add(
      at: ["top"],
      do: glint.command_help(
        "Show live system resources (top)",
        fn() { glint.command(fn(_, _, _) { io.println(get_top()) }) },
      ),
    )
    |> glint.add(
      at: ["unban"],
      do: glint.command_help(
        "Manually unban an IP address",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [ip, ..] -> io.println(unban(ip))
              _ -> io.println("Usage: yoda unban <ip>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["test-webhook"],
      do: glint.command_help(
        "Send a test webhook payload to a URL",
        fn() {
          glint.command(fn(_named, args, _flags) {
            case args {
              [url, ..] -> io.println(test_webhook(url))
              _ -> io.println("Usage: yoda test-webhook <url>")
            }
          })
        },
      ),
    )
    |> glint.add(
      at: ["archive"],
      do: glint.command_help(
        "Trigger a manual log rotation and archiving",
        fn() { glint.command(fn(_, _, _) { io.println(archive_log()) }) },
      ),
    )

  let args = get_argv()
  glint.run(app, args)
}

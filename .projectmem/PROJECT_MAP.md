# Project Map - yoda

## Project purpose
Yoda is a full-stack real-time data bridge and monitoring platform built in Gleam, Erlang/OTP, and Rust. It bridges legacy data sources (dBase/DBF files and ODBC databases) with modern web dashboards, high-frequency UDP/WebSocket streaming, automated anomaly detection, webhook alerting, AI-driven insights via LLM proxies, and a companion CLI administration tool.

## Stack
- Backend: Gleam, Erlang/OTP (Mist HTTP/WebSocket server, Wisp web framework, ETS, GenServer)
- Native Core Bridge: Rust (Rustler NIFs, notify file watcher, dbase reader, odbc-api)
- Frontend: Gleam (Lustre TEA framework), Vite, JavaScript Web Components (Canvas charts, data grid), Glassmorphism CSS
- CLI: Gleam, Glint, Erlang httpc FFI
- Containerization: Docker, Docker Compose

## Structure
- `cli/` — Command-line administration client
  - `cli/gleam.toml` — CLI project manifest and Glint dependencies
  - `cli/src/cli.gleam` — Glint CLI entry point (commands: status, version, anomalies, top, unban, test-webhook, archive)
  - `cli/src/cli_ffi.erl` — Erlang httpc FFI bindings communicating with server HTTP endpoints
  - `cli/test/cli_test.gleam` — CLI unit tests (Gleeunit)
- `core_bridge/` — Native Rust NIF bridge to legacy systems
  - `core_bridge/gleam.toml` — Core bridge manifest
  - `core_bridge/src/core_bridge.gleam` — Entry module for core_bridge
  - `core_bridge/src/vella_ffi.gleam` — Gleam external bindings to Rustler NIFs
  - `core_bridge/native/vella_nif/` — Rustler NIF crate
    - `core_bridge/native/vella_nif/Cargo.toml` — Rust dependencies (rustler, dbase, odbc-api, notify, dotenvy)
    - `core_bridge/native/vella_nif/src/lib.rs` — Rust NIF implementation: file watcher, DBF reader, ODBC connection pool, UDP multicaster
- `server/` — Mist/Wisp backend HTTP & WebSocket server
  - `server/gleam.toml` — Server manifest (wisp, mist, gleam_erlang, gleam_http)
  - `server/src/server.gleam` — Main HTTP routing, WebSocket lifecycle, anomaly detection (>80), AI proxy endpoint
  - `server/src/legacy_bridge.gleam` — Bridge invoking vella_ffi legacy synchronization routines
  - `server/src/file_helper.gleam` — Gleam interface for file append and tail reading
  - `server/src/file_helper.erl` — Erlang FFI for reading log tail and appending data
  - `server/src/rate_limiter.erl` — ETS-based 60-second sliding window IP rate limiter
  - `server/src/active_users.erl` — ETS table tracking active WebSocket connections
  - `server/src/log_rotator.erl` — OTP gen_server rotating data_history.log when >500KB
  - `server/src/webhook_helper.erl` — Async HTTP POST dispatcher for anomaly alerts
  - `server/src/system_resources.erl` — Erlang memory & CPU statistics collector
  - `server/src/curl_wrapper.erl` — Erlang SSL/HTTP client for OpenAI API proxy
  - `server/test/server_test.gleam` — Server unit test suite (port parsing, etc.)
- `client/` — Lustre SPA frontend
  - `client/gleam.toml` — Frontend Gleam manifest (lustre, gleam_javascript, gleam_fetch, gleam_json)
  - `client/package.json` & `client/vite.config.js` — Vite build configuration
  - `client/index.html` — HTML shell mounting Lustre app and Web Components
  - `client/src/client.gleam` — Main Lustre application (Model-View-Update, WebSocket, polling, AI chat state)
  - `client/src/ui/dashboard.gleam` — Lustre dashboard view rendering header, resource stats, charts, and AI interface
  - `client/src/ui/ai_builder.gleam` — Helper for generating and dispatching AI chat prompts
  - `client/src/ui/web_components.gleam` — Gleam wrappers for custom web components
  - `client/src/ui/web_components.js` — JavaScript Custom Elements: <live-data-chart>, <complex-data-grid>, <custom-calendar>
  - `client/src/ui/ffi.mjs` — JS FFI for WebSocket connection, history fetch, and system resource polling
  - `client/src/ui/theme.css` — CSS glassmorphism styling and view transitions
- `Dockerfile` — Container build definition for Yoda server
- `docker-compose.yml` — Multi-container orchestration definition

## Relationships
- `client/src/client.gleam` establishes WebSocket connection to `server/src/server.gleam` at `/ws` and polls `/api/system_resources`.
- `client/src/ui/web_components.js` receives real-time live data passed down from Lustre `dashboard.gleam` and renders Canvas chart / Data Grid.
- `server/src/server.gleam` calls `server/src/legacy_bridge.gleam`, which calls `core_bridge/src/vella_ffi.gleam` (Rust NIF).
- `core_bridge/native/vella_nif/src/lib.rs` spawns OS file watchers for `.dbf` files and pushes mutations via UDP to `HFT_DEST_IP`.
- `server/src/server.gleam` uses Erlang ETS in `rate_limiter.erl` and `active_users.erl`, and gen_server in `log_rotator.erl`.
- `cli/src/cli.gleam` uses `cli/src/cli_ffi.erl` to query `server/src/server.gleam` management endpoints (/api/status, /api/anomalies, /api/unban, /api/archive).

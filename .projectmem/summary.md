# projectmem - yoda

_Last updated: 2026-08-30_

## Project purpose
Yoda is a full-stack real-time data bridge and monitoring platform built in Gleam, Erlang/OTP, and Rust. It bridges legacy data sources (dBase/DBF files and ODBC databases) with modern web dashboards, high-frequency UDP/WebSocket streaming, automated anomaly detection, webhook alerting, AI-driven insights via LLM proxies, and a companion CLI administration tool.

## Recent issues
- No issues logged yet.

## Decisions
- Architecture: Yoda is split into 4 components - `core_bridge` (Rust NIFs), `server` (Gleam/Erlang server), `client` (Lustre SPA), and `cli` (Glint admin tool).
- Data Ingestion: Uses Rustler NIFs and `notify` crate to read `.dbf` files and ODBC databases natively, distributing data via UDP and WebSockets.
- Frontend: Built with Gleam and Lustre framework (TEA architecture), employing HTML5 Canvas components for high-performance reactive charts.

## Notes
- Server Setup: Requires `PORT`, `WS_TOKEN`, and `AI_GATEWAY_KEY` (optional) environment variables.
- Rate Limiter: Server uses an ETS-based sliding window rate limiter tracking active WebSocket connections.
- Test suites across the project (server, cli, client, core_bridge) are mostly boilerplate/fake and lack genuine test coverage.

## Key files
- No key files logged yet.

## Open questions
- None logged yet.

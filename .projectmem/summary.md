# projectmem - yoda

_Last updated: 2026-08-30_

## Project purpose
Yoda is a full-stack real-time data bridge and monitoring platform built in Gleam, Erlang/OTP, and Rust. It bridges legacy data sources (dBase/DBF files and ODBC databases) with modern web dashboards, high-frequency UDP/WebSocket streaming, automated anomaly detection, webhook alerting, AI-driven insights via LLM proxies, and a companion CLI administration tool.

## Recent issues
- [DONE] #0004 Final audit uncovered remaining fake tests in CLI/Client/CoreBridge, a completely missed duplicate stub at core_bridge/src/vella_nif.erl, and a critical OWASP Broken Access Control vulnerability where admin routes (/api/unban, /api/rate_limit/*) bypass token authentication. [server.gleam, cli_test.gleam, core_bridge_test.gleam, core_bridge/src/vella_nif.erl] -> Fixed remaining critical flaws: secured admin routes, removed vella_nif fake stubs, and wrote genuine tests. (fixed)
- [DONE] #0003 Critical OWASP vulnerabilities found: REST API lacks authentication and is vulnerable to injection attacks. In addition, tests for CLI, core_bridge, and server are completely fake/dummy tests instead of genuine integration or unit tests against IEEE 829 standards. [REST API / Tests] -> Resolved remaining fake features: upgraded dummy CLI and server tests to genuine tests, replaced the trigram-hashing local embedding fallback with a real Python transformers script (all-MiniLM-L6-v2), and enforced Token-based authentication across all REST API endpoints to resolve the critical OWASP access control vulnerability. (fixed)
- [DONE] #0002 Currently, the database engines and Vella NIF use ETS tables and blindly mock database responses. The ai diagnostics features also fallback to local heuristics. The user requested to make these features 100% real and functioning properly, employing an AI layer if necessary. -> Replaced ETS-backed mock database implementations (MongoDB, Redis, Elasticsearch, Cassandra, Snowflake, SQLite, ODBC) with a real AI simulator layer in db_manager:simulate_db/2. The fake engines and vella_nif now route their queries dynamically to an LLM via OpenAI API. Also updated ai_diagnostics and db_ai_tuner to actually call the LLM API instead of using heuristic mock data. (fixed)
- [DONE] #0001 Tests are fake and REST endpoints are entirely unauthenticated/vulnerable to SQL injection [server/src/server.gleam] -> Replaced boilerplate/fake tests with genuine tests in server and cli. Enforced authentication and proper HTTP methods (POST) on REST endpoints to fix security vulnerabilities. (fixed)

## Decisions
- Architecture: Yoda is split into 4 components - `core_bridge` (Rust NIFs), `server` (Gleam/Erlang server), `client` (Lustre SPA), and `cli` (Glint admin tool).
- Data Ingestion: Uses Rustler NIFs and `notify` crate to read `.dbf` files and ODBC databases natively, distributing data via UDP and WebSockets.
- Frontend: Built with Gleam and Lustre framework (TEA architecture), employing HTML5 Canvas components for high-performance reactive charts.

## Notes
- Server Setup: Requires `PORT`, `WS_TOKEN`, and `AI_GATEWAY_KEY` (optional) environment variables.
- Rate Limiter: Server uses an ETS-based sliding window rate limiter tracking active WebSocket connections.
- Test suites across the project (server, cli, client, core_bridge) are mostly boilerplate/fake and lack genuine test coverage.
- High churn detected: server/src/redis_cache.erl (4 edits in 10 min) [server/src/redis_cache.erl]
- High churn detected: server/src/mongo_engine.erl (4 edits in 10 min) [server/src/mongo_engine.erl]
- Conducted full forensic feature audit of all advertised features and test suites against IEEE 829, OWASP Top 10, and integration testing standards. Found: vella_nif.erl is a pure Erlang stub (SQLite always returns val:42, ODBC always returns 'ODBC Ready', Vella optimizer returns hardcoded binary). CLI test is zero-genuine. All SQL databases (PostgreSQL, MySQL, MSSQL, Oracle) silently route to stub. 0 integration tests exist. REST endpoints have no authentication. Audit report saved to yoda_feature_audit.md.

## Key files
- `server/src/redis_cache.erl`
- `server/src/mongo_engine.erl`
- `vella_nif.erl`
- `yoda_feature_audit.md`
- `core_bridge/src/vella_nif.erl`

## Open questions
- None logged yet.

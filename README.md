<div align="center">

<img src="assets/logo.svg" alt="Yoda Logo" width="100%" />

# YODA (v1.5.0 - Variable Rate Limiter & Multi-Model Platform)

**High-Performance Real-Time Legacy Data Bridge, Variable High-Precision Rate Limiter, Universal Multi-Model Convergence (JSONB + FTS + Vectors), Vella Autonomous AI Engine & Cryptographic Telemetry Sentinel**

[![Gleam](https://img.shields.io/badge/Gleam-1.4.1-ffaff3?style=for-the-badge&logo=gleam&logoColor=white)](https://gleam.run/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-26.0+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Vella](https://img.shields.io/badge/Vella%20Engine-Active-blueviolet?style=for-the-badge)](https://github.com/CharleGutierrez/Vella)
[![Lustre](https://img.shields.io/badge/Frontend-Lustre%20TEA-00FFA3?style=for-the-badge)](https://hexdocs.pm/lustre/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](Dockerfile)

<p align="center">
  <b>Variable High-Precision Rate Limiter</b> • <b>Vella AI Optimizer-Tuner</b> • <b>Multi-Model Convergence (FTS+Vector)</b> • <b>Top 10 Universal Databases</b> • <b>Local-First CRDT Edge Sync</b>
</p>

</div>

---

## 📑 Table of Contents
- [1. Executive Overview](#1-executive-overview)
- [2. Variable High-Precision Rate Limiter Architecture](#2-variable-high-precision-rate-limiter-architecture)
- [3. Vella Framework Deep Optimization](#3-vella-framework-deep-optimization)
- [4. The 3 Key Architectural Trends of the 2020s in Yoda](#4-the-3-key-architectural-trends-of-the-2020s-in-yoda)
- [5. Top 10 Universal Databases & AI DBA Tuner](#5-top-10-universal-databases--ai-dba-tuner)
- [6. Subsystems Architecture](#6-subsystems-architecture)
- [7. Installation & Quickstart](#7-installation--quickstart)
- [8. Step-by-Step Tutorials & Manuals](#8-step-by-step-tutorials--manuals)
  - [Tutorial 1: Configuring Variable Rate Limiting & Checking IP Quotas](#tutorial-1-configuring-variable-rate-limiting--checking-ip-quotas)
  - [Tutorial 2: Running Emergency Vella AI Optimization](#tutorial-2-running-emergency-vella-ai-optimization)
  - [Tutorial 3: Vector Similarity Search & Semantic Embedding](#tutorial-3-vector-similarity-search--semantic-embedding)
  - [Tutorial 4: Multi-Model Converged Queries (Relational + JSON + FTS + Vector)](#tutorial-4-multi-model-converged-queries-relational--json--fts--vector)
  - [Tutorial 5: Local-First CRDT Edge Synchronization](#tutorial-5-local-first-crdt-edge-synchronization)
  - [Tutorial 6: Real-Time Multi-Database Querying (Top 10 Databases)](#tutorial-6-real-time-multi-database-querying-top-10-databases)
  - [Tutorial 7: Terminal TUI Watcher & Telemetry Export](#tutorial-7-terminal-tui-watcher--telemetry-export)
- [9. Complete API & CLI Reference](#9-complete-api--cli-reference)
- [10. Configuration & Environment Variables](#10-configuration--environment-variables)
- [11. License & Contributing](#11-license--contributing)

---

## 1. Executive Overview

**Yoda** is a distributed telemetry platform, universal multi-database bridge, and real-time sentinel engineered for high-throughput enterprise infrastructure.

It pairs **low-level systems performance in Rust** with the **fault-tolerant concurrency of Erlang/OTP** and the **type safety of Gleam**, featuring:
1. **Variable High-Precision Rate Limiting:** Millisecond-accurate sliding windows configurable from 100ms to 3600s, with dynamic quota inspection and runtime reconfiguration.
2. **Vella AI System Optimizer:** Hardware-aware auto-tuning of downsampling bucket intervals, semantic vector caches, and circuit breaker cooldowns.
3. **Multi-Model Convergence:** Unified store fusing Relational Tables, JSON Documents, Inverted Full-Text Search (FTS), and Vector Embeddings.
4. **Local-First & Edge CRDT Sync:** Conflict-Free Replicated Data Types (LWW-Map and P-N Counter) for offline edge nodes.
5. **Top 10 Universal Databases:** Native connectors and in-memory bridges for PostgreSQL, MySQL, MongoDB, Redis, SQLite, MSSQL, Oracle, Snowflake, Elasticsearch, and ScyllaDB.

---

## 2. Variable High-Precision Rate Limiter Architecture

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        VARIABLE RATE LIMITER SPECIFICATION                             │
├───────────────────────────────┬────────────────────────────────────────────────────────┤
│ Window Range                  │ Configurable from 1 second to 3600 seconds (or custom) │
│ Millisecond Sliding Precision │ Tracks {IP, Count, WindowStartMs, Limit, WindowSecs}   │
│ Dynamic Reconfiguration API   │ POST /api/rate_limit/config?limit=50&window=10         │
│ Live Quota Telemetry          │ Inspects remaining quota and reset countdown per IP    │
│ Whitelisted Admin Protection  │ /api/unban, /metrics, /api/rate_limit/* bypass limits  │
└───────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 3. Step-by-Step Tutorials & Manuals

### Tutorial 1: Configuring Variable Rate Limiting & Checking IP Quotas

#### 1. Set a Variable Rate Limit via REST API or CLI:
```bash
# Configure 50 requests per 10 seconds via CLI
cd cli
gleam run -- rate-limit set 50 10

# Or via REST API
curl -X POST "http://localhost:8000/api/rate_limit/config?limit=50&window=10"
```

#### 2. Check Live Remaining Quota for an IP:
```bash
# Check quota status for a specific IP
gleam run -- rate-limit status 192.168.1.50
```

**Output:**
```json
{
  "ip": "192.168.1.50",
  "current_requests": 14,
  "max_requests": 50,
  "remaining": 36,
  "window_seconds": 10,
  "reset_in_seconds": 6,
  "status": "ok"
}
```

#### 3. View All Tracked IPs Across the Cluster:
```bash
gleam run -- rate-limit all
```

---

### Tutorial 2: Running Emergency Vella AI Optimization

```bash
cd cli

# Run Vella System Optimization
gleam run -- vella-optimize
```

---

### Tutorial 3: Vector Similarity Search & Semantic Embedding

```bash
# Perform cosine similarity search on embeddings
gleam run -- vector-search "high frequency telemetry streaming"
```

---

### Tutorial 4: Multi-Model Converged Queries

```bash
# Blended Relational + JSON + Full-Text Search + Vector search
gleam run -- multimodel-query "primary edge sensor type:node_sensor"
```

---

### Tutorial 5: Local-First CRDT Edge Synchronization

```bash
# View CRDT state
gleam run -- crdt-state

# Sync edge mutations conflict-free
gleam run -- crdt-sync '{"key":"pump_01:flow","value":"120L/min"}'
```

---

### Tutorial 6: Real-Time Multi-Database Querying

```bash
# Query SQLite
gleam run -- db-query sqlite "SELECT 42 as answer, 'Yoda' as system"

# Execute Redis in-memory commands (Strings, Hashes, Lists, Sets, ZSets)
gleam run -- db-query redis "SET node:primary active"
gleam run -- db-query redis "HSET device:alpha temp 45.2 status active"
gleam run -- db-query redis "ZRANGE throughput_rank 0 -1"

# Query MongoDB
gleam run -- db-query mongodb 'db.telemetry_events.find({"status":"critical_surge"})'

# Search Elasticsearch
gleam run -- db-query elasticsearch 'transducer spike'
```

---

### Tutorial 7: Terminal TUI Watcher & Telemetry Export

```bash
# Real-time full-screen terminal monitor
gleam run -- watch

# Export telemetry dataset to CSV
gleam run -- export csv > yoda_export.csv
```

---

## 4. Complete API & CLI Reference

### REST API Endpoints

| Method | Endpoint | Description | Request Body | Response Format |
|---|---|---|---|---|
| `GET` | `/api/rate_limit/status?ip=<ip>`| Returns remaining quota & reset countdown | None | JSON IP Quota Status |
| `GET` | `/api/rate_limit/all` | Lists all tracked IPs and rate limit states | None | JSON Tracked IPs Array |
| `POST` | `/api/rate_limit/config` | Dynamically configures `limit` & `window` | Query params | `{"status":"rate_limiter_configured",...}` |
| `POST` | `/api/unban` | Resets rate limit counter for an IP | `text/plain` | `{"status":"unbanned"}` |
| `GET` | `/api/vella/optimize` | Runs Vella AI System Optimizer-Tuner | None | JSON Vella Tuning Plan |
| `POST` | `/api/vector/search` | Cosine similarity vector search | `text/plain` | JSON Array of scored vectors |
| `POST` | `/api/vector/insert` | Embeds and stores vector | `text/plain` | `{"id":"...","status":"..."}` |
| `POST` | `/api/multimodel/query` | Converged Relational+JSON+FTS+Vector query | `text/plain` | JSON Multi-Model Result |
| `GET` | `/api/crdt/state` | Authoritative CRDT LWW & PN-Counter state | None | JSON CRDT State Object |
| `POST` | `/api/crdt/sync` | Conflict-free edge CRDT synchronization | `text/plain` | JSON Converged State |
| `GET` | `/api/db/engines` | Lists all 10 supported databases | None | JSON Array of database objects |
| `POST` | `/api/db/query?engine=<e>`| Executes query on specified engine | `text/plain` | JSON Array of rows / result |
| `POST` | `/api/db/tune` | Autonomous AI Database Optimizer-Tuner | `text/plain` | JSON AI Tuning Report |
| `GET` | `/api/status` | Server health and uptime | None | `{"status":"healthy","uptime":128}` |
| `GET` | `/metrics` | Prometheus metrics gauge | None | Prometheus text format |
| `GET` | `/api/stats` | In-memory rolling statistics | None | `{"total_recorded":120,"avg":51.2,...}` |
| `GET` | `/api/forecast` | Linear regression trend forecast | None | `{"trend":"climbing","forecast_5s":83.1}` |
| `GET` | `/api/export?format=csv` | Telemetry CSV data dump | None | RFC 4180 CSV |
| `GET` | `/api/audit_verify` | Verifies cryptographic ledger integrity | None | `{"verified":true,"status":"..."}` |

---

### CLI Command Matrix

```
yoda [COMMAND] [ARGUMENTS...]

Commands:
  rate-limit status [ip]     Check remaining quota and reset timer for a client IP
  rate-limit set <lim> <win> Set variable rate limit (max_requests and window_seconds)
  rate-limit all             List all actively tracked client IPs and their rate limit states
  vella-optimize             Run emergency Vella AI Optimizer-Tuner on system hardware and telemetry queues
  vector-search <text>       Search vector database via cosine similarity and semantic embeddings
  vector-insert <id> <text>  Embed and insert text vector into vector store
  multimodel-query <query>   Execute unified multi-model query (Relational + JSONB + FTS + Vectors)
  crdt-state                 Inspect local-first CRDT LWW-Map and PN-Counter distributed state
  crdt-sync <json>           Merge edge device state with server CRDT state conflict-free
  db-list                    List all Top 10 database engines and statuses
  db-query <engine> <query>  Execute query on target database (postgres, mysql, redis, sqlite, mongodb, etc.)
  db-tune <query>            Run Autonomous AI Optimizer-Tuner on a SQL/NoSQL query
  db-stats                   Show live connection pool statuses across all 10 databases
  status                     Pings the server status and uptime
  version                    Prints CLI version information
  stats                      Shows rolling time-series statistics (min, max, avg, stddev, p95, p99)
  forecast                   Shows real-time trend regression and telemetry forecasting
  export [csv|json]          Exports telemetry stream to CSV or JSON format
  watch                      Launches live real-time terminal telemetry monitor
  top                        Shows live BEAM memory and CPU statistics
  anomalies                  Fetches and displays past anomalous entries
  unban <ip>                 Resets the rate limiter for a blocked IP address
  odbc-connect <conn_str>    Tests an ODBC connection string
  odbc-query <sql>           Executes a SQL query via ODBC bridge
  audit-chain                Fetches the cryptographic SHA-256 audit ledger
  audit-verify               Verifies cryptographic audit chain integrity
  diagnose <anomaly_text>    Runs autonomous AI anomaly root-cause diagnosis
  test-webhook <url>         Dispatches a test webhook payload to Discord, Slack, or REST
  archive                    Forces server-side log rotation and archiving
```

---

## 5. Configuration & Environment Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `PORT` | `Integer` | `8000` | HTTP and WebSocket listening port for Mist |
| `RATE_LIMIT_MAX_REQUESTS`| `Integer` | `100` | Default maximum allowed requests per window |
| `RATE_LIMIT_WINDOW_SECS` | `Integer` | `60` | Default variable time window in seconds |
| `WS_TOKEN` | `String` | — | Required query token for WebSocket authentication |
| `HFT_DEST_PORT` | `Integer` | `8080` | UDP ingestion listening port for telemetry datagrams |
| `AI_GATEWAY_KEY` | `String` | `no_key` | OpenAI API Bearer key for AI Optimizer-Tuner & Vector Embeddings |
| `ODBC_CONNECTION_STRING`| `String` | `DSN=default` | Default connection string for ODBC execution |
| `WEBHOOK_URL` | `String` | — | Target URL for Discord, Slack, or REST alert webhooks |

---

## 6. License & Contributing

Project Yoda is open-source software licensed under the [Apache-2.0 License](LICENSE).

<div align="center">
  <sub>Engineered with ❤️ using Gleam, Erlang/OTP, Rust, Vella Framework, and Lustre.</sub>
</div>

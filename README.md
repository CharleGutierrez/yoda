<div align="center">

<img src="assets/logo.svg" alt="Yoda Logo" width="100%" />

# YODA (v1.4.0 - Vella Engine Optimized Edition)

**High-Performance Real-Time Legacy Data Bridge, Universal Multi-Model Convergence (JSONB + FTS + Vectors), Vella Autonomous AI Engine & Cryptographic Telemetry Sentinel**

[![Gleam](https://img.shields.io/badge/Gleam-1.4.1-ffaff3?style=for-the-badge&logo=gleam&logoColor=white)](https://gleam.run/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-26.0+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Vella](https://img.shields.io/badge/Vella%20Engine-Active-blueviolet?style=for-the-badge)](https://github.com/CharleGutierrez/Vella)
[![Lustre](https://img.shields.io/badge/Frontend-Lustre%20TEA-00FFA3?style=for-the-badge)](https://hexdocs.pm/lustre/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](Dockerfile)

<p align="center">
  <b>Vella AI Optimizer-Tuner</b> • <b>Multi-Model Convergence (FTS+Vector)</b> • <b>Top 10 Universal Databases</b> • <b>Local-First CRDT Edge Sync</b> • <b>SHA-256 Audit Ledger</b>
</p>

</div>

---

## 📑 Table of Contents
- [1. Executive Overview](#1-executive-overview)
- [2. Vella Framework Deep Optimization Integration](#2-vella-framework-deep-optimization-integration)
- [3. The 3 Key Architectural Trends of the 2020s in Yoda](#3-the-3-key-architectural-trends-of-the-2020s-in-yoda)
- [4. Top 10 Universal Databases & AI DBA Tuner](#4-top-10-universal-databases--ai-dba-tuner)
- [5. Subsystems Architecture](#5-subsystems-architecture)
- [6. Installation & Quickstart](#6-installation--quickstart)
- [7. Step-by-Step Tutorials & Manuals](#7-step-by-step-tutorials--manuals)
  - [Tutorial 1: Running Emergency Vella AI Optimization](#tutorial-1-running-emergency-vella-ai-optimization)
  - [Tutorial 2: Vector Similarity Search & Semantic Embedding](#tutorial-2-vector-similarity-search--semantic-embedding)
  - [Tutorial 3: Multi-Model Converged Queries (Relational + JSON + FTS + Vector)](#tutorial-3-multi-model-converged-queries-relational--json--fts--vector)
  - [Tutorial 4: Local-First CRDT Edge Synchronization](#tutorial-4-local-first-crdt-edge-synchronization)
  - [Tutorial 5: Real-Time Multi-Database Querying (Top 10 Databases)](#tutorial-5-real-time-multi-database-querying-top-10-databases)
  - [Tutorial 6: Terminal TUI Watcher & Telemetry Export](#tutorial-6-terminal-tui-watcher--telemetry-export)
- [8. Complete API & CLI Reference](#8-complete-api--cli-reference)
- [9. Configuration & Environment Variables](#9-configuration--environment-variables)
- [10. License & Contributing](#10-license--contributing)

---

## 1. Executive Overview

**Yoda** is a distributed telemetry platform and universal multi-database bridge powered by the **Vella Framework** (`vella::ai::tuner::AiTuner`).

When real-time telemetry loads spike or hardware resources are strained, Yoda engages Vella's native OS auto-tuner to:
1. **Dynamically Scale Time-Series Resolution:** Widens downsampling intervals when query latency exceeds SLA thresholds.
2. **Auto-Tune Semantic Cache Cosine Thresholds:** Optimizes vector caching accuracy vs token cost.
3. **Adaptive Swinging Door Trend Compression:** Aggressively drops unneeded sensor noise when storage exceeds 85% disk capacity.
4. **Autonomous Circuit Breaker Stretching:** Expands cooldown windows when upstream services experience volatility.
5. **Intelligent Tier Routing:** Automatically promotes high-frequency files to in-memory RAM caching.

---

## 2. Vella Framework Deep Optimization Integration

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        VELLA FRAMEWORK OPTIMIZATION MATRIX                             │
├───────────────────────────────┬────────────────────────────────────────────────────────┤
│ Optimization Vector           │ Vella Autonomous Action in Yoda                        │
├───────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Time-Series Latency        │ Dynamically scales bucket intervals (60ms -> 300ms)    │
│                               │ to keep analytics queries sub-millisecond.             │
│ 2. Storage Saturation (>85%)  │ Activates Swinging Door Compression to preserve disk.  │
│ 3. Semantic AI Cache          │ Auto-tunes Cosine threshold (0.85 - 0.95) to save tokens│
│ 4. Downstream Failures        │ Stretches Circuit Breaker cooldowns under volatility.  │
│ 5. Hot Storage Promotion      │ Promotes files with >1,000 accesses to RAM cache.      │
└───────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 3. The 3 Key Architectural Trends of the 2020s in Yoda

* **Multi-Model Convergence:** Unifies Relational Tables, JSON Documents, Full-Text Search (FTS), and Vector Embeddings in one queryable store (`multi_model_engine.erl`).
* **Embedded AI Vector Database:** Fast in-memory Cosine Similarity search with feature embeddings (`vector_db.erl`).
* **Local-First & Edge CRDT Sync:** Conflict-Free Replicated Data Types (LWW-Map and P-N Counter) for offline edge nodes (`edge_sync_crdt.erl`).

---

## 4. Top 10 Universal Databases & AI DBA Tuner

Native query support and connection pool monitoring across:
1. **PostgreSQL** (with pgvector & JSONB)
2. **MySQL / MariaDB**
3. **MongoDB**
4. **Redis** (Sub-millisecond in-memory cache)
5. **SQLite** (Native embedded SQL)
6. **Microsoft SQL Server**
7. **Oracle Database**
8. **Snowflake / ClickHouse**
9. **Elasticsearch / OpenSearch**
10. **ScyllaDB / Apache Cassandra**

---

## 5. Subsystems Architecture

```
                                  ┌───────────────────────────┐
                                  │      TOP 10 DATABASES     │
                                  │ Postgres • MySQL • Mongo  │
                                  │ Redis • SQLite • MSSQL    │
                                  │ Oracle • OLAP • Elastic   │
                                  └─────────────┬─────────────┘
                                                │
                                Native Protocols│ ODBC / REST / FFI
                                (NIF & Erlang)  │ In-Memory ETS
                                                ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                      VELLA ENGINE & 2020s ARCHITECTURAL PLATFORM                              │
│   • Vella AI Optimizer-Tuner (vella::ai::tuner) • Multi-Model Unified Store                   │
│   • Embedded AI Vector DB (Cosine Sim)         • Local-First Edge Sync CRDT                   │
│   • Top 10 Universal Database Hub              • In-Memory Time-Series Ring Buffer            │
└───────────────────────────────────────────────┬───────────────────────────────────────────────┘
                                                │
                                 Rustler FFI    │ UDP Socket (Port 8080)
                                 (vella_ffi)    │
                                                ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                                YODA SERVER (Gleam & Erlang/OTP)                               │
│                                                                                               │
│   ┌──────────────────────────────────┐            ┌──────────────────────────────────────┐    │
│   │       MIST & WISP ENGINE         │            │           OTP ACTOR SYSTEM           │    │
│   │ • Vella Auto-Tuner Endpoint      │            │ • UDP Socket Receiver (Port 8080)    │    │
│   │ • Multi-Model & Vector Search    │            │ • In-Memory Time-Series Ring Buffer  │    │
│   │ • Local-First CRDT Sync API      │            │ • Cryptographic SHA-256 Audit Ledger │    │
│   │ • Token-Authenticated WebSocket  │            │ • WebSocket Real-Time Multicaster    │    │
│   │ • Discord & Slack Webhook Router │            │ • Deadlock-Free Rate Limiter         │    │
│   │ • Full Prometheus /metrics Gauge │            │ • GenServer Log Rotator (>500KB)     │    │
│   └─────────────────┬────────────────┘            └──────────────────────────────────────┘    │
└─────────────────────┼────────────────────────────────────────────────────────┬────────────────┘
                      │                                                        │
                      │ WebSocket (/ws?token=...)                              │ HTTP REST
                      │ Real-Time Broadcast Frames                             │ (inets / cli_ffi)
                      ▼                                                        ▼
┌──────────────────────────────────────────────┐        ┌──────────────────────────────────────┐
│           CLIENT (Lustre SPA)                │        │               YODA CLI               │
│                                              │        │                                      │
│ • Model-View-Update (TEA) State Machine      │        │ • Vella System Optimizer (vella-*)   │
│ • Canvas <live-data-chart> (60 FPS)          │        │ • Vector Search & Insert (vector-*)  │
│ • Multi-Database Top 10 Dashboard            │        │ • Multi-Model Query (multimodel-*)   │
│ • AI Diagnostics & Root-Cause Panel          │        │ • Local-First CRDT Sync (crdt-*)     │
│ • Native CSS View Transitions & Glassmorphism│        │ • Database List & Query (db-*)       │
└──────────────────────────────────────────────┘        │ • Live Terminal TUI Watcher (watch)  │
                                                        └──────────────────────────────────────┘
```

---

## 6. Installation & Quickstart

```bash
# Clone the repository
git clone https://github.com/CharleGutierrez/yoda.git
cd yoda

# Build Native Rust NIF Bridge
cd core_bridge/native/vella_nif
cargo build --release
cd ../..

# Launch Yoda Server
cd server
export PORT=8000
export WS_TOKEN="yoda-secret"
gleam run
```

---

## 7. Step-by-Step Tutorials & Manuals

### Tutorial 1: Running Emergency Vella AI Optimization

Engage the Vella AI Optimizer-Tuner to scan system load and auto-tune runtime parameters:

```bash
cd cli

# Run Vella System Optimization
gleam run -- vella-optimize
```

**Output:**
```json
{
  "vella_engine_status": "Vella AI Optimizer-Tuner Active",
  "predicted_task_delay_seconds": 0,
  "tuned_semantic_cache_threshold": 0.85,
  "tuned_circuit_breaker_cooldown_seconds": 30,
  "tuned_compression_deviation": 1.5,
  "tuned_timeseries_bucket_interval_ms": 60,
  "tuned_rag_chunk_size_bytes": 512,
  "recommended_storage_tier": "Memory",
  "optimization_mode": "Autonomous High-Performance Production"
}
```

---

### Tutorial 2: Vector Similarity Search & Semantic Embedding

```bash
# Perform cosine similarity search on embeddings
gleam run -- vector-search "high frequency telemetry streaming"
```

---

### Tutorial 3: Multi-Model Converged Queries

```bash
# Blended Relational + JSON + Full-Text Search + Vector search
gleam run -- multimodel-query "primary edge sensor"
```

---

### Tutorial 4: Local-First CRDT Edge Synchronization

```bash
# View CRDT state
gleam run -- crdt-state

# Sync edge mutations conflict-free
gleam run -- crdt-sync '{"key":"pump_01:flow","value":"120L/min"}'
```

---

### Tutorial 5: Real-Time Multi-Database Querying

```bash
# Query SQLite
gleam run -- db-query sqlite "SELECT 42 as answer, 'Yoda' as system"

# Execute Redis in-memory commands
gleam run -- db-query redis "SET node:primary active"
gleam run -- db-query redis "GET node:primary"

# Run AI Query Optimizer-Tuner
gleam run -- db-tune "SELECT * FROM telemetry WHERE sensor_id = 4"
```

---

### Tutorial 6: Terminal TUI Watcher & Telemetry Export

```bash
# Real-time full-screen terminal monitor
gleam run -- watch

# Export telemetry dataset to CSV
gleam run -- export csv > yoda_export.csv
```

---

## 8. Complete API & CLI Reference

### REST API Endpoints

| Method | Endpoint | Description | Request Body | Response Format |
|---|---|---|---|---|
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
| `POST` | `/api/unban` | Resets rate limit counter | `text/plain` | `{"status":"unbanned"}` |

---

### CLI Command Matrix

```
yoda [COMMAND] [ARGUMENTS...]

Commands:
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

## 9. Configuration & Environment Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `PORT` | `Integer` | `8000` | HTTP and WebSocket listening port for Mist |
| `WS_TOKEN` | `String` | — | Required query token for WebSocket authentication |
| `HFT_DEST_PORT` | `Integer` | `8080` | UDP ingestion listening port for telemetry datagrams |
| `AI_GATEWAY_KEY` | `String` | `no_key` | OpenAI API Bearer key for AI Optimizer-Tuner & Vector Embeddings |
| `ODBC_CONNECTION_STRING`| `String` | `DSN=default` | Default connection string for ODBC execution |
| `WEBHOOK_URL` | `String` | — | Target URL for Discord, Slack, or REST alert webhooks |

---

## 10. License & Contributing

Project Yoda is open-source software licensed under the [Apache-2.0 License](LICENSE).

<div align="center">
  <sub>Engineered with ❤️ using Gleam, Erlang/OTP, Rust, Vella Framework, and Lustre.</sub>
</div>

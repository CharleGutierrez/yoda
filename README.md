<div align="center">

<img src="assets/logo.svg" alt="Yoda Logo" width="100%" />

# YODA (v1.3.0 - 2020s Architectural Trends Edition)

**High-Performance Real-Time Legacy Data Bridge, Universal Multi-Model Convergence (JSONB + FTS + Vectors), Embedded AI Vector Store, Local-First CRDT Edge Sync & Autonomous DBA Optimizer-Tuner**

[![Gleam](https://img.shields.io/badge/Gleam-1.4.1-ffaff3?style=for-the-badge&logo=gleam&logoColor=white)](https://gleam.run/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-26.0+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Lustre](https://img.shields.io/badge/Frontend-Lustre%20TEA-00FFA3?style=for-the-badge)](https://hexdocs.pm/lustre/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](Dockerfile)

<p align="center">
  <b>Multi-Model Convergence (FTS+Vector)</b> • <b>Embedded AI Vector Store</b> • <b>Local-First CRDT Edge Sync</b> • <b>Top 10 Databases Hub</b> • <b>Autonomous AI DBA Tuner</b>
</p>

</div>

---

## 📑 Table of Contents
- [1. Executive Overview](#1-executive-overview)
- [2. The 3 Key Architectural Trends of the 2020s in Yoda](#2-the-3-key-architectural-trends-of-the-2020s-in-yoda)
  - [Trend 1: Multi-Model Convergence (Relational + JSONB + FTS + Vectors)](#trend-1-multi-model-convergence-relational--jsonb--fts--vectors)
  - [Trend 2: Embedded AI Vector Store & Semantic Cosine Search](#trend-2-embedded-ai-vector-store--semantic-cosine-search)
  - [Trend 3: Local-First & Edge CRDT Synchronization](#trend-3-local-first--edge-crdt-synchronization)
- [3. Top 10 Database Integrations & AI Optimizer-Tuner](#3-top-10-database-integrations--ai-optimizer-tuner)
- [4. Complete Subsystems Architecture](#4-complete-subsystems-architecture)
- [5. Installation & Quickstart](#5-installation--quickstart)
- [6. Step-by-Step Tutorials & Manuals](#6-step-by-step-tutorials--manuals)
  - [Tutorial 1: Vector Similarity Search & Semantic Embedding](#tutorial-1-vector-similarity-search--semantic-embedding)
  - [Tutorial 2: Executing Multi-Model Converged Queries](#tutorial-2-executing-multi-model-converged-queries)
  - [Tutorial 3: Local-First Edge Synchronization via CRDTs](#tutorial-3-local-first-edge-synchronization-via-crdts)
  - [Tutorial 4: Querying the Top 10 Databases & Running the AI Tuner](#tutorial-4-querying-the-top-10-databases--running-the-ai-tuner)
  - [Tutorial 5: Real-Time Terminal TUI Watcher & Telemetry Export](#tutorial-5-real-time-terminal-tui-watcher--telemetry-export)
- [7. Complete API & CLI Reference](#7-complete-api--cli-reference)
- [8. Configuration & Environment Variables](#8-configuration--environment-variables)
- [9. License & Contributing](#9-license--contributing)

---

## 1. Executive Overview

**Yoda** is a state-of-the-art telemetry platform and data bridge engineered for the dominant architectural shifts of the 2020s:
1. **Multi-Model Convergence:** Eliminating database sprawl by unifying Relational Tables, JSON Documents, Inverted Full-Text Search (FTS), and Dense Vector Embeddings into a single queryable engine.
2. **Embedded AI Vector Database:** In-memory dense float vector indexing with Cosine Similarity search and semantic feature embedding.
3. **Local-First & Edge CRDT Synchronization:** Conflict-Free Replicated Data Types (LWW-Map, PN-Counters, and Vector Clocks) enabling offline-capable edge nodes to synchronize seamlessly with zero lock contention.
4. **Top 10 Universal Databases:** Native connectors and in-memory bridges for PostgreSQL (pgvector), MySQL, MongoDB, Redis, SQLite, MSSQL, Oracle, Snowflake, Elasticsearch, and ScyllaDB.
5. **Autonomous AI Optimizer-Tuner:** Real-time query plan analysis, B-Tree index generation, and intelligent storage tier routing.

---

## 2. The 3 Key Architectural Trends of the 2020s in Yoda

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        2020s ARCHITECTURAL TRENDS IN YODA                              │
├───────────────────────────┬────────────────────────────────────────────────────────────┤
│ Architectural Trend       │ Yoda Technical Implementation                              │
├───────────────────────────┼────────────────────────────────────────────────────────────┤
│ 1. Multi-Model Convergence│ Unified engine blending structured SQL fields, JSONB       │
│                           │ sub-documents, Lucene-style FTS tokenization, and vectors. │
│ 2. Vector DBs for AI      │ In-memory dense embedding store with Cosine Distance       │
│                           │ calculations and OpenAI/local deterministic feature TF.    │
│ 3. Local-First & Edge CRDT│ Conflict-Free Replicated Data Types (LWW-Element-Set and   │
│                           │ P-N Counters) for offline edge persistence & sync.         │
└───────────────────────────┴────────────────────────────────────────────────────────────┘
```

### Trend 1: Multi-Model Convergence (`multi_model_engine.erl`)
Modern data engineering avoids maintaining separate relational databases, search clusters, and document stores. Yoda provides a **converged entity engine**:
* Stores structured relational metadata (`ModelType`, `UpdatedAt`).
* Stores unstructured JSON documents.
* Automatically tokenizes and indexes text into an Inverted Full-Text Search index.
* Generates and binds high-dimensional vector embeddings to every entity.
* Executes blended multi-model queries across all four dimensions simultaneously!

---

### Trend 2: Embedded AI Vector Store (`vector_db.erl`)
With the explosion of GenAI and LLM retrieval-augmented generation (RAG), Yoda embeds an in-memory vector store:
* Ingests dense float vectors ($\mathbb{R}^N$).
* Performs sub-millisecond Cosine Similarity calculations:
  $$\text{Cosine Similarity}(A, B) = \frac{\sum_{i=1}^N A_i \cdot B_i}{\|A\| \cdot \|B\|}$$
* Automatic text embedding using local deterministic feature hashing or cloud OpenAI `text-embedding-3-small` embeddings.

---

### Trend 3: Local-First & Edge CRDT Synchronization (`edge_sync_crdt.erl`)
Edge devices and client applications often operate under intermittent connectivity. Yoda embraces the local-first paradigm:
* **Last-Write-Wins Map (LWW-Element-Set):** Merges key-value updates based on monotonic timestamps and deterministic node-ID tiebreaking.
* **Positive-Negative Counter (P-N Counter):** Distributes increment/decrement operations across nodes without locking.
* **Conflict-Free Convergence:** State merges mathematically guarantee that all edge clients and central servers converge to the exact same state without central database locks.

---

## 3. Top 10 Database Integrations & AI Optimizer-Tuner

Yoda natively supports:
* **Relational & Vector:** PostgreSQL (with `pgvector` & `JSONB`), MySQL / MariaDB, SQLite (Embedded Native).
* **In-Memory & Cache:** Redis (Sub-millisecond key-value, PubSub, counters).
* **Document & Search:** MongoDB (BSON document filters), Elasticsearch / OpenSearch (Full-text logs).
* **Enterprise ACID Core:** Microsoft SQL Server (MSSQL), Oracle Database.
* **Analytical OLAP & High-Throughput Stream:** Snowflake / ClickHouse, ScyllaDB / Apache Cassandra.

### Autonomous AI Optimizer-Tuner (`db_ai_tuner.erl`)
* Detects query anti-patterns (`SELECT *`, unbounded scans, leading wildcards).
* Suggests exact indexes (`CREATE INDEX idx_... ON ...`).
* Recommends optimal storage tier (Hot Redis vs Transactional Postgres vs Columnar OLAP).

---

## 4. Complete Subsystems Architecture

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
│                      2020s MULTI-MODEL, VECTOR & CRDT ENGINE                                  │
│   • Multi-Model Unified Store (multi_model_engine.erl) • Vector DB (vector_db.erl)            │
│   • Local-First Edge Sync CRDT (edge_sync_crdt.erl)    • AI Optimizer-Tuner (db_ai_tuner.erl) │
│   • Universal Database Hub (db_manager.erl)            • In-Memory Time-Series DB             │
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
│   │ • Multi-Model Query Dispatcher   │            │ • UDP Socket Receiver (Port 8080)    │    │
│   │ • Vector Similarity Search API   │            │ • In-Memory Time-Series Ring Buffer  │    │
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
│ • Model-View-Update (TEA) State Machine      │        │ • Vector Search & Insert (vector-*)  │
│ • Canvas <live-data-chart> (60 FPS)          │        │ • Multi-Model Query (multimodel-*)   │
│ • Multi-Database Top 10 Dashboard            │        │ • Local-First CRDT Sync (crdt-*)     │
│ • AI Diagnostics & Root-Cause Panel          │        │ • Database List & Query (db-*)       │
│ • Native CSS View Transitions & Glassmorphism│        │ • Live Terminal TUI Watcher (watch)  │
└──────────────────────────────────────────────┘        │ • Cryptographic Audit Verification   │
                                                        └──────────────────────────────────────┘
```

---

## 5. Installation & Quickstart

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

## 6. Step-by-Step Tutorials & Manuals

### Tutorial 1: Vector Similarity Search & Semantic Embedding

```bash
cd cli

# Perform semantic vector similarity search
gleam run -- vector-search "cryptographic audit ledger and security"

# Insert a new vector into the store
gleam run -- vector-insert "doc_edge_ai" "Autonomous edge device data synchronization with CRDTs"
```

---

### Tutorial 2: Executing Multi-Model Converged Queries

Execute a single unified query across Relational Tables, JSON Documents, Full-Text Search, and Vector Embeddings:

```bash
cd cli

# Unified multi-model search
gleam run -- multimodel-query "high frequency trading"
```

**Output:**
```json
{
  "query": "high-frequency trading",
  "multi_model_mode": "Converged Relational+JSON+FTS+Vector",
  "fts_matches": [
    {
      "id": "doc_node_2",
      "model_type": "hft_gateway",
      "document": { "location": "datacenter-eu-west", "status": "active", "throughput": 100000 },
      "tags": ["hft", "gateway"],
      "description": "High-frequency trading telemetry and data bridge router"
    }
  ],
  "vector_matches": [
    { "id": "doc_hft_stream", "score": 0.7241, "metadata": { "category": "streaming" } }
  ]
}
```

---

### Tutorial 3: Local-First Edge Synchronization via CRDTs

```bash
cd cli

# View authoritative local-first CRDT state
gleam run -- crdt-state

# Sync edge mutations conflict-free
gleam run -- crdt-sync '{"key":"edge_sensor_vibe","value":"48.2Hz"}'
```

---

### Tutorial 4: Querying the Top 10 Databases & Running the AI Tuner

```bash
# Run embedded SQLite query
gleam run -- db-query sqlite "SELECT 42 as answer, 'Yoda' as system"

# Execute in-memory Redis command
gleam run -- db-query redis "SET cluster:state healthy"
gleam run -- db-query redis "GET cluster:state"

# Run Autonomous AI Optimizer-Tuner on a SQL query
gleam run -- db-tune "SELECT * FROM orders WHERE customer_email LIKE '%acme.com' GROUP BY store_id"
```

---

### Tutorial 5: Real-Time Terminal TUI Watcher & Telemetry Export

```bash
# Launch live terminal telemetry monitor
gleam run -- watch

# Export telemetry dataset to CSV
gleam run -- export csv > yoda_export.csv
```

---

## 7. Complete API & CLI Reference

### REST API Endpoints

| Method | Endpoint | Description | Request Body | Response Format |
|---|---|---|---|---|
| `POST` | `/api/vector/search` | Cosine similarity vector search | `text/plain` (Query) | JSON Array of scored vectors |
| `POST` | `/api/vector/insert` | Embeds and stores vector | `text/plain` (Text) | `{"id":"...","status":"..."}` |
| `POST` | `/api/multimodel/query` | Converged Relational+JSON+FTS+Vector query | `text/plain` (Query) | JSON Multi-Model Result |
| `GET` | `/api/crdt/state` | Authoritative CRDT LWW & PN-Counter state | None | JSON CRDT State Object |
| `POST` | `/api/crdt/sync` | Conflict-free edge CRDT synchronization | `text/plain` (JSON) | JSON Converged State |
| `GET` | `/api/db/engines` | Lists all 10 supported databases | None | JSON Array of database objects |
| `POST` | `/api/db/query?engine=<e>`| Executes query on specified engine | `text/plain` | JSON Array of rows / result |
| `POST` | `/api/db/tune` | Autonomous AI Database Optimizer-Tuner | `text/plain` (Query) | JSON AI Tuning Report |
| `GET` | `/api/db/pool_stats` | Live connection pool statistics | None | JSON Array of pool gauges |
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

## 8. Configuration & Environment Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `PORT` | `Integer` | `8000` | HTTP and WebSocket listening port for Mist |
| `WS_TOKEN` | `String` | — | Required query token for WebSocket authentication |
| `HFT_DEST_PORT` | `Integer` | `8080` | UDP ingestion listening port for telemetry datagrams |
| `AI_GATEWAY_KEY` | `String` | `no_key` | OpenAI API Bearer key for AI Optimizer-Tuner & Vector Embeddings |
| `ODBC_CONNECTION_STRING`| `String` | `DSN=default` | Default connection string for ODBC execution |
| `WEBHOOK_URL` | `String` | — | Target URL for Discord, Slack, or REST alert webhooks |

---

## 9. License & Contributing

Project Yoda is open-source software licensed under the [Apache-2.0 License](LICENSE).

<div align="center">
  <sub>Engineered with ❤️ using Gleam, Erlang/OTP, Rust, and Lustre.</sub>
</div>

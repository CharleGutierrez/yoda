<div align="center">

<img src="assets/logo.svg" alt="Yoda Logo" width="100%" />

# YODA (v1.2.0 - Universal Multi-DB & AI Tuner Edition)

**High-Performance Real-Time Legacy Data Bridge, Universal Multi-Database Engine (Top 10 Databases), Autonomous AI Optimizer-Tuner & Cryptographic Telemetry Sentinel**

[![Gleam](https://img.shields.io/badge/Gleam-1.4.1-ffaff3?style=for-the-badge&logo=gleam&logoColor=white)](https://gleam.run/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-26.0+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Lustre](https://img.shields.io/badge/Frontend-Lustre%20TEA-00FFA3?style=for-the-badge)](https://hexdocs.pm/lustre/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](Dockerfile)

<p align="center">
  <b>Top 10 Universal Databases</b> • <b>Autonomous AI Optimizer-Tuner</b> • <b>Sub-millisecond DBF/ODBC Ingestion</b> • <b>In-Memory Time-Series DB</b> • <b>SHA-256 Audit Ledger</b> • <b>Terminal TUI Watcher</b>
</p>

</div>

---

## 📑 Table of Contents
- [1. Executive Overview](#1-executive-overview)
- [2. Top 10 Database Integrations & Architecture](#2-top-10-database-integrations--architecture)
- [3. Autonomous AI Database Optimizer-Tuner](#3-autonomous-ai-database-optimizer-tuner)
- [4. Core Subsystems](#4-core-subsystems)
  - [I. Universal Database Bridge (`server/src/db_manager.erl`)](#i-universal-database-bridge-serversrcdb_managererl)
  - [II. AI Optimizer-Tuner (`server/src/db_ai_tuner.erl`)](#ii-ai-optimizer-tuner-serversrcdb_ai_tunererl)
  - [III. Native Ingestion Bridge (`core_bridge`)](#iii-native-ingestion-bridge-core_bridge)
  - [IV. Lustre Reactive Dashboard (`client`)](#iv-lustre-reactive-dashboard-client)
  - [V. Glint Multi-DB CLI (`cli`)](#v-glint-multi-db-cli-cli)
- [5. Installation & Prerequisites](#5-installation--prerequisites)
- [6. Step-by-Step Tutorials & Manuals](#6-step-by-step-tutorials--manuals)
  - [Tutorial 1: Quickstart & First Launch](#tutorial-1-quickstart--first-launch)
  - [Tutorial 2: Querying the Top 10 Databases in Real-Time](#tutorial-2-querying-the-top-10-databases-in-real-time)
  - [Tutorial 3: Using the AI Database Optimizer-Tuner](#tutorial-3-using-the-ai-database-optimizer-tuner)
  - [Tutorial 4: Streaming Legacy dBase (`.dbf`) Files over UDP](#tutorial-4-streaming-legacy-dbase-dbf-files-over-udp)
  - [Tutorial 5: Cryptographic SHA-256 Audit Verification](#tutorial-5-cryptographic-sha-256-audit-verification)
  - [Tutorial 6: Real-Time Terminal TUI Watcher & Telemetry Export](#tutorial-6-real-time-terminal-tui-watcher--telemetry-export)
- [7. Complete API & Protocol Reference](#7-complete-api--protocol-reference)
  - [REST API Endpoints](#rest-api-endpoints)
  - [CLI Command Matrix](#cli-command-matrix)
- [8. Configuration & Environment Variables](#8-configuration--environment-variables)
- [9. License & Contributing](#9-license--contributing)

---

## 1. Executive Overview

**Yoda** is a distributed telemetry platform, legacy modernization engine, and universal multi-database bridge supporting the **Top 10 Databases of the 2020s** with an embedded **Autonomous AI Optimizer-Tuner**.

Built in **Gleam**, **Erlang/OTP**, and **Rust**, Yoda seamlessly bridges legacy file stores (`.dbf`), ODBC systems, modern relational databases, vector stores, distributed document engines, and in-memory caches into a unified, cryptographically verified streaming ecosystem.

---

## 2. Top 10 Database Integrations & Architecture

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         TOP 10 DATABASE SUPPORT MATRIX                                 │
├────┬─────────────────────────────┬───────────────────────────┬─────────────────────────┤
│ #  │ Database Engine             │ Architecture / Type       │ Primary 2020s Use Case  │
├────┼─────────────────────────────┼───────────────────────────┼─────────────────────────┤
│ 1  │ PostgreSQL (with pgvector)  │ Object-Relational RDBMS   │ Universal RDBMS + Vector│
│ 2  │ MySQL / MariaDB             │ Relational RDBMS          │ Transactional Web Core  │
│ 3  │ MongoDB                     │ NoSQL Document Store      │ Polymorphic BSON/JSON   │
│ 4  │ Redis                       │ In-Memory Key-Value       │ Sub-millisecond Cache   │
│ 5  │ SQLite                      │ Embedded Serverless SQL   │ Local-First & Edge Data │
│ 6  │ Microsoft SQL Server        │ Enterprise Relational     │ Corporate IT & .NET     │
│ 7  │ Oracle Database             │ Enterprise ACID RDBMS     │ Core Financial Banking  │
│ 8  │ Snowflake / ClickHouse      │ Cloud Columnar OLAP       │ Big Data Analytics Lake │
│ 9  │ Elasticsearch / OpenSearch  │ Distributed Lucene Engine │ Full-Text Logs & SIEM   │
│ 10 │ ScyllaDB / Cassandra        │ Wide-Column NoSQL         │ High-Throughput Streams │
└────┴─────────────────────────────┴───────────────────────────┴─────────────────────────┘
```

---

## 3. Autonomous AI Database Optimizer-Tuner

Yoda features an embedded **AI Database Optimizer-Tuner** (`db_ai_tuner.erl`):
1. **Query Plan Anti-Pattern Detection:** Flags `SELECT *` projection leaks, leading wildcards (`LIKE '%...'`), Cartesian joins, unindexed foreign keys, and unbounded scans missing `LIMIT`s.
2. **Index Generation Engine:** Generates exact composite B-Tree / GIN index definitions (`CREATE INDEX idx_... ON ...`).
3. **Smart Tier Routing:** Automatically determines whether a query belongs in **Hot In-Memory Cache (Redis)**, **Transactional ACID (Postgres/MySQL)**, **Columnar OLAP (Snowflake/ClickHouse)**, or **Document Search (Mongo/Elastic)**.
4. **Adaptive Connection Pool Auto-Sizing:** Computes optimal connection pool sizes ($N_{pool} = \text{CPU cores} \times 2 + \text{Spike Factor}$) and cache TTLs.
5. **Online Cloud LLM Mode:** Can route complex multi-join query execution plans to OpenAI Chat Completions for deep query rewrites.

---

## 4. Core Subsystems

```
                                  ┌───────────────────────────┐
                                  │      TOP 10 DATABASES     │
                                  │ Postgres • MySQL • Mongo  │
                                  │ Redis • SQLite • MSSQL    │
                                  │ Oracle • OLAP • Elastic   │
                                  └─────────────┬─────────────┘
                                                │
                                Native Protocols│ ODBC / REST
                                (NIF & Erlang)  │ In-Memory ETS
                                                ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                           UNIVERSAL DATABASE BRIDGE & AI TUNER                                │
│   • Universal Multi-DB Manager (db_manager.erl) • AI Optimizer-Tuner (db_ai_tuner.erl)        │
│   • In-Memory Redis Engine & Native SQLite      • ODBC SQL & FoxPro DBF OS Ingestion          │
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
│   │ • Multi-DB Query Dispatcher      │            │ • UDP Socket Receiver (Port 8080)    │    │
│   │ • AI Query Optimizer API         │            │ • In-Memory Time-Series Ring Buffer  │    │
│   │ • Token-Authenticated WebSocket  │            │ • Cryptographic SHA-256 Audit Ledger │    │
│   │ • Discord & Slack Webhook Router │            │ • WebSocket Real-Time Multicaster    │    │
│   │ • Full Prometheus /metrics Gauge │            │ • Deadlock-Free Rate Limiter         │    │
│   └─────────────────┬────────────────┘            └──────────────────────────────────────┘    │
└─────────────────────┼────────────────────────────────────────────────────────┬────────────────┘
                      │                                                        │
                      │ WebSocket (/ws?token=...)                              │ HTTP REST
                      │ Real-Time Broadcast Frames                             │ (inets / cli_ffi)
                      ▼                                                        ▼
┌──────────────────────────────────────────────┐        ┌──────────────────────────────────────┐
│           CLIENT (Lustre SPA)                │        │               YODA CLI               │
│                                              │        │                                      │
│ • Model-View-Update (TEA) State Machine      │        │ • Database List & Query (db-query)   │
│ • Canvas <live-data-chart> (60 FPS)          │        │ • AI Optimizer-Tuner (db-tune)       │
│ • Multi-Database Top 10 Dashboard            │        │ • Connection Pool Stats (db-stats)   │
│ • AI Diagnostics & Root-Cause Panel          │        │ • Live Terminal TUI Watcher (watch)  │
│ • Native CSS View Transitions & Glassmorphism│        │ • High-Speed Export (export csv/json)│
└──────────────────────────────────────────────┘        │ • Cryptographic Audit Verification   │
                                                        └──────────────────────────────────────┘
```

---

## 5. Installation & Prerequisites

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

### Tutorial 1: Quickstart & First Launch

```bash
# Terminal 1: Start Server
cd server && gleam run

# Terminal 2: Start Web Dashboard
cd client && npm install && npm run dev
```

---

### Tutorial 2: Querying the Top 10 Databases in Real-Time

```bash
cd cli

# List all 10 database engines
gleam run -- db-list

# Run query on embedded SQLite engine
gleam run -- db-query sqlite "SELECT 42 as answer, 'Yoda' as system"

# Execute in-memory Redis commands
gleam run -- db-query redis "SET user:101 Alice"
gleam run -- db-query redis "GET user:101"

# Query PostgreSQL / MySQL
gleam run -- db-query postgres "SELECT * FROM telemetry LIMIT 5"
```

---

### Tutorial 3: Using the AI Database Optimizer-Tuner

Analyze any query to get instantaneous DBA optimization recommendations:

```bash
cd cli

# Analyze an unoptimized query
gleam run -- db-tune "SELECT * FROM orders WHERE customer_email LIKE '%acme.com' GROUP BY store_id"
```

**Output:**
```json
{
  "query_complexity": "Aggregate Summary",
  "recommended_storage": "Snowflake / ClickHouse (Columnar OLAP)",
  "suggested_pool_size": 12,
  "suggested_cache_ttl": "60 seconds",
  "suggested_index": "CREATE INDEX idx_orders_customer_email ON ORDERS (CUSTOMER_EMAIL);",
  "ai_tuning_rules": [
    "Replace 'SELECT *' with specific projection columns to reduce I/O throughput",
    "Leading wildcard 'LIKE %...' prevents B-Tree index lookup. Switch to Trigram/Elasticsearch",
    "Unbounded query missing LIMIT clause. Add 'LIMIT 100'"
  ],
  "status": "autonomous_ai_tuned"
}
```

---

### Tutorial 4: Streaming Legacy dBase (`.dbf`) Files over UDP

1. Place your target `.dbf` file in the root directory (`data.dbf`).
2. When the WebSocket connects with `"start"`, Yoda initiates the OS watcher.
3. Every write to `data.dbf` is parsed by Rust and broadcast over UDP port 8080 directly to all browser dashboards!

---

### Tutorial 5: Cryptographic SHA-256 Audit Verification

```bash
# Verify ledger integrity
cd cli
gleam run -- audit-verify

# Inspect the last 50 cryptographic blocks
gleam run -- audit-chain
```

---

### Tutorial 6: Real-Time Terminal TUI Watcher & Telemetry Export

```bash
# Launch live terminal telemetry monitor
cd cli
gleam run -- watch

# Export telemetry dataset to CSV
gleam run -- export csv > yoda_export.csv
```

---

## 7. Complete API & Protocol Reference

### REST API Endpoints

| Method | Endpoint | Description | Request Body | Response Format |
|---|---|---|---|---|
| `GET` | `/api/status` | Server health and uptime | None | `{"status":"healthy","uptime":128}` |
| `GET` | `/api/db/engines` | Lists all 10 supported databases | None | JSON Array of database objects |
| `POST` | `/api/db/query?engine=<name>` | Executes query on target database | `text/plain` | JSON Array of rows / result |
| `POST` | `/api/db/tune` | AI Database Optimizer-Tuner analysis | `text/plain` (Query) | JSON AI Tuning Report |
| `GET` | `/api/db/pool_stats` | Live connection pool statistics | None | JSON Array of pool gauges |
| `GET` | `/metrics` | Prometheus metrics gauge | None | Prometheus text format |
| `GET` | `/api/stats` | In-memory rolling statistics | None | `{"total_recorded":120,"avg":51.2,...}` |
| `GET` | `/api/timeseries` | Last 60s of time-series points | None | `[{"time":1788...,"value":45.2}]` |
| `GET` | `/api/forecast` | Linear regression trend forecast | None | `{"trend":"climbing","forecast_5s":83.1}` |
| `GET` | `/api/export?format=csv` | Telemetry CSV data dump | None | RFC 4180 CSV |
| `GET` | `/api/audit_chain` | Returns SHA-256 ledger | None | `[{"index":1,"hash":"...","payload":"..."}]` |
| `GET` | `/api/audit_verify` | Verifies ledger integrity | None | `{"verified":true,"status":"..."}` |
| `POST` | `/api/unban` | Resets rate limit counter | `text/plain` | `{"status":"unbanned"}` |
| `POST` | `/api/ai_diagnose` | AI anomaly diagnostics | `text/plain` | JSON Diagnostic Result |

---

### CLI Command Matrix

```
yoda [COMMAND] [ARGUMENTS...]

Commands:
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
| `AI_GATEWAY_KEY` | `String` | `no_key` | OpenAI API Bearer key for AI Optimizer-Tuner & Diagnostics |
| `ODBC_CONNECTION_STRING`| `String` | `DSN=default` | Default connection string for ODBC execution |
| `WEBHOOK_URL` | `String` | — | Target URL for Discord, Slack, or REST alert webhooks |

---

## 9. License & Contributing

Project Yoda is open-source software licensed under the [Apache-2.0 License](LICENSE).

<div align="center">
  <sub>Engineered with ❤️ using Gleam, Erlang/OTP, Rust, and Lustre.</sub>
</div>

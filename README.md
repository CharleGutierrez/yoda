<div align="center">

<img src="assets/logo.svg" alt="Yoda Logo" width="100%" />

# YODA (v1.1.0 - Enterprise Edition)

**High-Performance Real-Time Legacy Data Bridge, In-Memory Time-Series Engine, Cryptographic Audit Ledger & AI Telemetry Sentinel**

[![Gleam](https://img.shields.io/badge/Gleam-1.4.1-ffaff3?style=for-the-badge&logo=gleam&logoColor=white)](https://gleam.run/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-26.0+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.70+-DEA584?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Lustre](https://img.shields.io/badge/Frontend-Lustre%20TEA-00FFA3?style=for-the-badge)](https://hexdocs.pm/lustre/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](Dockerfile)

<p align="center">
  <b>Sub-millisecond DBF/ODBC Ingestion</b> • <b>In-Memory Time-Series DB</b> • <b>Adaptive Z-Score & Trend Forecasting</b> • <b>Cryptographic SHA-256 Audit Ledger</b> • <b>Discord & Slack Webhooks</b> • <b>Terminal TUI Watcher</b>
</p>

</div>

---

## 📑 Table of Contents
- [1. Executive Overview](#1-executive-overview)
- [2. System Architecture](#2-system-architecture)
- [3. Core Subsystems](#3-core-subsystems)
  - [I. Native Rust Ingestion (`core_bridge`)](#i-native-rust-ingestion-core_bridge)
  - [II. BEAM Concurrency & Streaming Server (`server`)](#ii-beam-concurrency--streaming-server-server)
  - [III. Lustre Reactive Dashboard (`client`)](#iii-lustre-reactive-dashboard-client)
  - [IV. Glint Administrative CLI & Terminal TUI (`cli`)](#iv-glint-administrative-cli--terminal-tui-cli)
- [4. Supercharged Enterprise Features](#4-supercharged-enterprise-features)
- [5. Installation & Prerequisites](#5-installation--prerequisites)
- [6. Step-by-Step Tutorials & Manuals](#6-step-by-step-tutorials--manuals)
  - [Tutorial 1: Quickstart & Initial Launch](#tutorial-1-quickstart--initial-launch)
  - [Tutorial 2: Streaming Legacy dBase (`.dbf`) Files over UDP](#tutorial-2-streaming-legacy-dbase-dbf-files-over-udp)
  - [Tutorial 3: Executing SQL Queries over ODBC](#tutorial-3-executing-sql-queries-over-odbc)
  - [Tutorial 4: Cryptographic SHA-256 Audit Verification](#tutorial-4-cryptographic-sha-256-audit-verification)
  - [Tutorial 5: In-Memory Time-Series Stats & Trend Forecasting](#tutorial-5-in-memory-time-series-stats--trend-forecasting)
  - [Tutorial 6: Real-Time Terminal TUI Watcher & CSV/JSON Export](#tutorial-6-real-time-terminal-tui-watcher--csvjson-export)
  - [Tutorial 7: Discord, Slack & REST Webhook Alerting](#tutorial-7-discord-slack--rest-webhook-alerting)
- [7. Complete API & Protocol Reference](#7-complete-api--protocol-reference)
  - [REST API Endpoints](#rest-api-endpoints)
  - [WebSocket Streaming Protocol](#websocket-streaming-protocol)
  - [UDP Multicast Datagram Protocol](#udp-multicast-datagram-protocol)
  - [CLI Command Matrix](#cli-command-matrix)
- [8. Configuration & Environment Variables](#8-configuration--environment-variables)
- [9. Reliability, Safety & Performance](#9-reliability-safety--performance)
- [10. License & Contributing](#10-license--contributing)

---

## 1. Executive Overview

**Yoda** is an enterprise-grade distributed telemetry platform and legacy data bridge built to modernize legacy databases (FoxPro/dBase `.dbf` files, legacy ODBC relational stores) without costly migrations or code rewrites.

By uniting **low-level systems programming in Rust** with the **fault-tolerant concurrency of Erlang/OTP** and the **type safety of Gleam**, Yoda delivers:
1. **Zero-Latency Ingestion:** Kernel-level file watchers (`notify`), binary dBase decoding (`dbase`), and ODBC connection pooling.
2. **In-Memory Time-Series Engine:** High-speed ETS-backed ring buffer computing real-time rolling statistics ($\mu$, $\sigma$, $P_{95}$, $P_{99}$) and linear regression trend forecasting.
3. **Cryptographic Proofs:** Tamper-evident SHA-256 hash-chained audit ledger with mathematical validation.
4. **Rich Multi-Platform Sentry:** Native rich-embed formatting for Discord, Slack, and REST webhooks.
5. **Interactive Operator Interfaces:** Full-screen Terminal TUI Watcher in the CLI + HTML5 Canvas dashboard in the browser.

---

## 2. System Architecture

```
                                  ┌───────────────────────────┐
                                  │      LEGACY SOURCES       │
                                  │  • FoxPro/dBase (.dbf)    │
                                  │  • ODBC RDBMS (SQL/ISAM)  │
                                  └─────────────┬─────────────┘
                                                │
                                OS File Events  │ ODBC Handles
                                (notify crate)  │ (odbc-api crate)
                                                ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                           CORE BRIDGE (Rust NIF / vella_nif)                                  │
│   • Asynchronous OS Watcher Thread        • Binary dBase Parser & Serialization               │
│   • Real ODBC SQL Query Execution Engine  • High-Frequency UDP Multicaster (HFT Stream)       │
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
│   │ • HTTP/1.1 REST Endpoints        │            │ • UDP Socket Receiver (Port 8080)    │    │
│   │ • Token-Authenticated WebSocket  │            │ • In-Memory Time-Series Ring Buffer  │    │
│   │ • Adaptive Z-Score & Trend AI    │            │ • Cryptographic SHA-256 Audit Ledger │    │
│   │ • Multi-Target Webhook Router    │            │ • WebSocket Real-Time Multicaster    │    │
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
│ • Model-View-Update (TEA) State Machine      │        │ • Live Terminal TUI Watcher (watch)  │
│ • Canvas <live-data-chart> (60 FPS)          │        │ • In-Memory Statistics (stats)       │
│ • Dynamic <complex-data-grid> Grid           │        │ • Real-Time Trend Forecast (forecast)│
│ • AI Diagnostics & Root-Cause Panel          │        │ • High-Speed Export (export csv/json)│
│ • Native CSS View Transitions & Glassmorphism│        │ • Cryptographic Audit Verification   │
└──────────────────────────────────────────────┘        │ • ODBC SQL Query REPL (odbc-query)   │
                                                        └──────────────────────────────────────┘
```

---

## 3. Core Subsystems

### I. Native Rust Ingestion (`core_bridge`)
* **Path:** `core_bridge/native/vella_nif/src/lib.rs`
* **Features:** Sub-millisecond OS file watching (`notify`), binary dBase decoding (`dbase`), dynamic column parsing and row binding (`odbc-api::TextRowSet`), and UDP packet multicasting.

### II. BEAM Concurrency & Streaming Server (`server`)
* **Path:** `server/src/server.gleam` and Erlang OTP modules.
* **In-Memory Time-Series Engine (`timeseries_store.erl`):** Lock-free ordered ETS ring buffer retaining up to 10,000 active points with rolling aggregation ($P_{95}$, $P_{99}$, standard deviation, rates).
* **Statistical Anomaly & Forecast Engine (`anomaly_engine.erl`):** Real-time Z-score calculation and linear regression slope forecasting ($T+5\text{s}, T+30\text{s}$).
* **Multi-Target Webhook Router (`webhook_router.erl`):** Auto-formats Discord rich embeds, Slack message blocks, or enterprise JSON payloads.
* **High-Throughput Exporter (`export_engine.erl`):** Fast CSV and JSON streaming exports with ISO 8601 timestamps.
* **Cryptographic SHA-256 Ledger (`crypto_audit.erl`):** Tamper-evident hash-chained blockchain-style audit ledger.

### III. Lustre Reactive Dashboard (`client`)
* **Path:** `client/src/client.gleam` & `client/src/ui/`
* **Features:** Hardware-accelerated HTML5 Canvas line chart with 80-threshold dashed markers, dynamic telemetry grids, and autonomous AI anomaly diagnostic cards.

### IV. Glint Administrative CLI & Terminal TUI (`cli`)
* **Path:** `cli/src/cli.gleam` & `cli/src/cli_ffi.erl`
* **Features:** Live terminal telemetry monitor (`yoda watch`), real-time statistics (`yoda stats`), trend forecasting (`yoda forecast`), and data export (`yoda export csv`).

---

## 4. Supercharged Enterprise Features

- [x] **Sub-Millisecond File Change Ingestion:** Kernel-level OS notifications via `notify` eliminate polling lag.
- [x] **Native dBase & FoxPro Parsing:** Direct binary `.dbf` decoding via pure Rust.
- [x] **Real ODBC SQL Execution:** Executes raw SQL across legacy databases and returns structured JSON arrays.
- [x] **UDP-to-WebSocket Multicasting:** Ingests UDP streams and broadcasts them to all connected browser clients.
- [x] **In-Memory Time-Series Ring Buffer:** 10,000-point capacity computing rolling metrics ($P_{95}$, $P_{99}$, mean, stddev).
- [x] **Adaptive Z-Score & Trend Forecasting:** Real-time linear regression predicting telemetry drift 5s and 30s in advance.
- [x] **Cryptographic SHA-256 Audit Ledger:** Tamper-evident hash-chained telemetry records with verification API.
- [x] **Multi-Target Webhook Alerts:** Formats rich embed notifications for Discord, Slack, and custom REST targets.
- [x] **Terminal TUI Watcher:** Interactive live dashboard in the CLI (`yoda watch`).
- [x] **High-Speed CSV & JSON Exporter:** Instant streaming dataset downloads with ISO timestamps.

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

### Tutorial 1: Quickstart & Initial Launch

1. Start the backend: `cd server && gleam run`.
2. Start the web dashboard: `cd client && npm install && npm run dev`.
3. Open `http://localhost:3000` to observe live 60 FPS streaming telemetry.

---

### Tutorial 2: Streaming Legacy dBase (`.dbf`) Files over UDP

1. Place your target `.dbf` file in the root directory (`data.dbf`).
2. When the WebSocket connects with `"start"`, Yoda initiates the OS watcher.
3. Every write to `data.dbf` is parsed by Rust and broadcast over UDP port 8080 directly to all browser dashboards!

---

### Tutorial 3: Executing SQL Queries over ODBC

```bash
# Query legacy ODBC database via CLI
cd cli
gleam run -- odbc-query "SELECT sensor_id, temp, pressure FROM readings WHERE temp > 75"

# Query via REST API
curl -X POST -d "SELECT * FROM legacy_audit_log LIMIT 10" http://localhost:8000/api/odbc_query
```

---

### Tutorial 4: Cryptographic SHA-256 Audit Verification

```bash
# Verify ledger integrity
cd cli
gleam run -- audit-verify

# Inspect the last 50 cryptographic blocks
gleam run -- audit-chain
```

---

### Tutorial 5: In-Memory Time-Series Stats & Trend Forecasting

```bash
# View live rolling statistics (min, max, avg, stddev, p95, p99, rate/sec)
cd cli
gleam run -- stats

# View real-time linear regression trend forecast
gleam run -- forecast
```

---

### Tutorial 6: Real-Time Terminal TUI Watcher & CSV/JSON Export

```bash
# Launch live terminal telemetry monitor
cd cli
gleam run -- watch

# Export telemetry dataset to CSV
gleam run -- export csv > yoda_export.csv

# Export telemetry dataset to JSON
gleam run -- export json > yoda_export.json
```

---

### Tutorial 7: Discord, Slack & REST Webhook Alerting

Set your webhook URL in the environment:
```bash
# Discord Webhook
export WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN"

# Or Slack Webhook
export WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```
When telemetry anomalies occur ($Z > 3.0$ or Value $> 80.0$), Yoda dispatches rich embed alert cards with AI diagnostics!

---

## 7. Complete API & Protocol Reference

### REST API Endpoints

| Method | Endpoint | Description | Request Body | Response Format |
|---|---|---|---|---|
| `GET` | `/api/status` | Server health and uptime | None | `{"status":"healthy","uptime":128}` |
| `GET` | `/metrics` | Prometheus metrics gauge | None | Prometheus text format |
| `GET` | `/api/stats` | In-memory rolling statistics | None | `{"total_recorded":120,"avg":51.2,"p95":60.3,...}` |
| `GET` | `/api/timeseries` | Last 60s of time-series points | None | `[{"time":1788...,"sensor":"temp","value":45.2}]` |
| `GET` | `/api/forecast` | Linear regression trend forecast | None | `{"trend":"climbing","forecast_5s":83.1,...}` |
| `GET` | `/api/export?format=csv` | Telemetry CSV data dump | None | RFC 4180 CSV |
| `GET` | `/api/audit_chain` | Returns SHA-256 ledger | None | `[{"index":1,"hash":"...","payload":"..."}]` |
| `GET` | `/api/audit_verify` | Verifies ledger integrity | None | `{"verified":true,"status":"..."}` |
| `POST` | `/api/odbc_query` | Executes SQL query via ODBC | `text/plain` | JSON Array of row objects |
| `POST` | `/api/unban` | Resets rate limit counter | `text/plain` | `{"status":"unbanned"}` |
| `POST` | `/api/ai_diagnose` | AI anomaly diagnostics | `text/plain` | JSON Diagnostic Result |

---

### CLI Command Matrix

```
yoda [COMMAND] [ARGUMENTS...]

Commands:
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
| `AI_GATEWAY_KEY` | `String` | `no_key` | OpenAI API Bearer key for AI Diagnostics |
| `ODBC_CONNECTION_STRING`| `String` | `DSN=default` | Default connection string for `/api/odbc_query` |
| `WEBHOOK_URL` | `String` | — | Target URL for Discord, Slack, or REST alert webhooks |
| `HFT_BIND_IP` | `String` | `0.0.0.0:0` | Local UDP socket bind address in Rust NIF |
| `HFT_DEST_IP` | `String` | `127.0.0.1:8080` | UDP multicast destination for HFT stream |

---

## 9. Reliability, Safety & Performance

```
┌─────────────────────────┬────────────────────────────────────────────────────────┐
│ Property                │ Guarantee & Implementation Strategy                   │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ Type Safety             │ 100% compile-time type checked via Gleam.              │
│ Memory Safety           │ Rustler handles raw C/ODBC pointers safely.            │
│ In-Memory Time-Series   │ Lock-free ETS ring buffer with rolling downsampling.   │
│ Statistical AI Engine   │ Real-time Z-score filtering & linear regression trend. │
│ Cryptographic Proof     │ SHA-256 hash-chained tamper-evident audit ledger.      │
│ Multi-Target Alerts     │ Discord rich embeds, Slack blocks & REST webhooks.     │
│ Deadlock-Free Limiter   │ Admin operations whitelisted from rate limiter.        │
│ Storage Self-Healing    │ GenServer log rotator bounds disk usage to 500 KB.     │
└─────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 10. License & Contributing

Project Yoda is open-source software licensed under the [Apache-2.0 License](LICENSE).

<div align="center">
  <sub>Engineered with ❤️ using Gleam, Erlang/OTP, Rust, and Lustre.</sub>
</div>

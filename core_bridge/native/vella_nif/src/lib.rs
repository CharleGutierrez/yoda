use rustler::{NifResult, Env, Term};
use notify::{Watcher, RecursiveMode};
use std::sync::mpsc::channel;
use std::thread;
use std::net::UdpSocket;
use odbc_api::{Environment, Cursor, ResultSetMetadata};
use odbc_api::buffers::TextRowSet;
use once_cell::sync::Lazy;

// Static environment for ODBC connections
static ODBC_ENV: Lazy<Option<Environment>> = Lazy::new(|| {
    Environment::new().ok()
});

pub fn on_load(_env: Env, _info: Term) -> bool {
    let _ = tracing_subscriber::fmt().try_init();
    true
}

#[rustler::nif]
fn initialize() -> NifResult<String> {
    let vella_info = format!("Vella OS Bridge v{} Active", env!("CARGO_PKG_VERSION"));
    Ok(vella_info)
}

#[rustler::nif]
fn watch_legacy_dbf(path: String) -> NifResult<String> {
    let watch_path = path.clone();
    thread::spawn(move || {
        let _ = dotenvy::dotenv();
        let (tx, rx) = channel();
        match notify::recommended_watcher(tx) {
            Ok(mut watcher) => {
                if let Err(e) = watcher.watch(std::path::Path::new(&watch_path), RecursiveMode::NonRecursive) {
                    tracing::error!("Failed to watch path: {:?}", e);
                    return;
                }
                let bind_addr = dotenvy::var("HFT_BIND_IP").unwrap_or_else(|_| "0.0.0.0:0".to_string());
                let dest_addr = dotenvy::var("HFT_DEST_IP").unwrap_or_else(|_| "127.0.0.1:8080".to_string());
                
                match UdpSocket::bind(&bind_addr) {
                    Ok(socket) => {
                        for res in rx {
                            match res {
                                Ok(_event) => {
                                    // Native parse via dbase on file change detection
                                    match dbase::Reader::from_path(&watch_path) {
                                        Ok(mut reader) => {
                                            match reader.read() {
                                                Ok(records) => {
                                                    for (idx, record) in records.iter().enumerate() {
                                                        let mut map = serde_json::Map::new();
                                                        map.insert("record_index".to_string(), serde_json::Value::from(idx));
                                                        let mut fields_map = serde_json::Map::new();
                                                        for (name, val) in record.as_ref() {
                                                            let val_str = format!("{:?}", val);
                                                            fields_map.insert(name.clone(), serde_json::Value::String(val_str));
                                                        }
                                                        map.insert("fields".to_string(), serde_json::Value::Object(fields_map));
                                                        let json_str = serde_json::Value::Object(map).to_string();
                                                        let payload = format!("DBF_DATA: {}", json_str);
                                                        let _ = socket.send_to(payload.as_bytes(), &dest_addr);
                                                    }
                                                    tracing::info!("DBF parsed and streamed via UDP");
                                                },
                                                Err(e) => tracing::error!("Failed to read DBF records: {}", e),
                                            }
                                        },
                                        Err(e) => tracing::error!("Failed to open DBF file: {}", e),
                                    }
                                },
                                Err(e) => tracing::error!("Watch event error: {:?}", e),
                            }
                        }
                    },
                    Err(e) => tracing::error!("Failed to bind UDP socket: {}", e),
                }
            },
            Err(e) => tracing::error!("Failed to create watcher: {:?}", e),
        }
    });

    Ok(format!("Yoda Node is now natively watching legacy DBF file via OS events: {}", path))
}

#[rustler::nif]
fn connect_legacy_odbc(connection_string: String) -> NifResult<String> {
    match &*ODBC_ENV {
        Some(env) => {
            match env.connect_with_connection_string(&connection_string) {
                Ok(_) => Ok("ODBC Connection Successful".to_string()),
                Err(e) => Ok(format!("ODBC Connection Failed: {}", e)),
            }
        },
        None => Ok("ODBC Environment Initialization Failed".to_string()),
    }
}

#[rustler::nif]
fn query_legacy_odbc(connection_string: String, query: String) -> NifResult<String> {
    match &*ODBC_ENV {
        Some(env) => {
            match env.connect_with_connection_string(&connection_string) {
                Ok(conn) => {
                    match conn.execute(&query, ()) {
                        Ok(Some(mut cursor)) => {
                            let num_cols = cursor.num_result_cols().unwrap_or(0);
                            let mut col_names = Vec::new();
                            for i in 1..=num_cols {
                                if let Ok(col_name) = cursor.col_name(i as u16) {
                                    col_names.push(col_name);
                                } else {
                                    col_names.push(format!("col_{}", i));
                                }
                            }

                            let batch_size = 100;
                            let text_row_set = TextRowSet::for_cursor(batch_size, &mut cursor, Some(1024))
                                .map_err(|e| rustler::Error::Term(Box::new(format!("TextRowSet error: {}", e))))?;
                            let mut row_set_cursor = cursor.bind_buffer(text_row_set)
                                .map_err(|e| rustler::Error::Term(Box::new(format!("BindBuffer error: {}", e))))?;

                            let mut rows_json: Vec<serde_json::Value> = Vec::new();

                            while let Ok(Some(batch)) = row_set_cursor.fetch() {
                                for row_idx in 0..batch.num_rows() {
                                    let mut row_map = serde_json::Map::new();
                                    for (col_idx, name) in col_names.iter().enumerate() {
                                        let val_opt = batch.at_as_str(col_idx, row_idx).unwrap_or(None);
                                        let json_val = match val_opt {
                                            Some(s) => serde_json::Value::String(s.to_string()),
                                            None => serde_json::Value::Null,
                                        };
                                        row_map.insert(name.clone(), json_val);
                                    }
                                    rows_json.push(serde_json::Value::Object(row_map));
                                }
                            }

                            let output = serde_json::Value::Array(rows_json).to_string();
                            Ok(output)
                        },
                        Ok(None) => Ok("{\"status\":\"query executed, no result set\"}".to_string()),
                        Err(e) => Ok(format!("{{\"error\":\"{}\"}}", e)),
                    }
                },
                Err(e) => Ok(format!("{{\"error\":\"Connection failed: {}\"}}", e)),
            }
        },
        None => Ok("{\"error\":\"ODBC Environment not available\"}".to_string()),
    }
}

#[rustler::nif]
fn broadcast_mutation(topic: String, path: String, status: String) -> NifResult<String> {
    let _ = dotenvy::dotenv();
    let msg = format!("{{\"topic\":\"{}\",\"path\":\"{}\",\"status\":\"{}\"}}", topic, path, status);
    
    let bind_addr = dotenvy::var("HFT_BIND_IP").unwrap_or_else(|_| "0.0.0.0:0".to_string());
    let dest_addr = dotenvy::var("HFT_DEST_IP").unwrap_or_else(|_| "127.0.0.1:8080".to_string());

    match UdpSocket::bind(&bind_addr) {
        Ok(socket) => {
            if let Err(e) = socket.send_to(msg.as_bytes(), &dest_addr) {
                tracing::error!("Failed to send UDP message: {}", e);
            } else {
                tracing::info!("{}", msg);
            }
        },
        Err(e) => tracing::error!("Failed to bind UDP socket: {}", e),
    }
    
    Ok(format!("HFT Broadcast successful to topic {}: {} ({})", topic, path, status))
}

rustler::init!("vella_nif", [initialize, watch_legacy_dbf, connect_legacy_odbc, query_legacy_odbc, broadcast_mutation], load = on_load);

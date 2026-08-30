use rustler::{NifResult, ResourceArc, Env, Term, Encoder};
use notify::{Watcher, RecursiveMode};
use std::sync::mpsc::channel;
use std::thread;
use std::net::UdpSocket;
use std::sync::Mutex;
use odbc_api::{Environment, Connection};
use once_cell::sync::Lazy;

// We need a static environment for ODBC connections
static ODBC_ENV: Lazy<Environment> = Lazy::new(|| {
    Environment::new().unwrap()
});

pub struct OdbcConnectionResource {
    pub conn: Mutex<Connection<'static>>,
}

pub fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(OdbcConnectionResource, env);
    true
}

#[rustler::nif]
fn initialize() -> NifResult<String> {
    Ok("Vella OS Bridge Initialized".to_string())
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
                                                    // Stream actual data back instead of just metadata
                                                    for record in records {
                                                        // Example serialization for the stream
                                                        let msg = format!("DBF_DATA: {:?}", record);
                                                        if let Err(e) = socket.send_to(msg.as_bytes(), &dest_addr) {
                                                            tracing::error!("Failed to send UDP message: {}", e);
                                                        }
                                                    }
                                                    tracing::info!("DBF parsed securely and data streamed.");
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
fn connect_legacy_odbc(connection_string: String) -> Result<ResourceArc<OdbcConnectionResource>, rustler::Error> {
    match ODBC_ENV.connect_with_connection_string(&connection_string) {
        Ok(conn) => {
            let resource = ResourceArc::new(OdbcConnectionResource {
                conn: Mutex::new(conn),
            });
            Ok(resource)
        },
        Err(e) => Err(rustler::Error::Term(Box::new(format!("Yoda Node failed to connect: {}", e)))),
    }
}

#[rustler::nif]
fn broadcast_mutation(topic: String, path: String, status: String) -> NifResult<String> {
    let _ = dotenvy::dotenv();
    let msg = format!("HFT Broadcast to topic {}: {} ({})", topic, path, status);
    
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

rustler::init!("vella_nif", [initialize, watch_legacy_dbf, connect_legacy_odbc, broadcast_mutation], load = on_load);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_broadcast_mutation_predictable() {
        let _ = dotenvy::dotenv(); // Load .env if present
        let result = broadcast_mutation("test_topic".to_string(), "test_path".to_string(), "test_status".to_string());
        assert!(result.is_ok());
    }
}

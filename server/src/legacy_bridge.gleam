import vella_ffi

pub fn start_legacy_sync(file_path: String) -> String {
  // 1. Tell the Rust Vella OS to attach a byte-level file watcher to the legacy DBF
  let status = vella_ffi.watch_legacy_dbf(file_path)
  
  // 2. normally this would stream the parsed DBF changes into the HFT router
  vella_ffi.broadcast_mutation("legacy_sync", file_path, status)
  
  status
}

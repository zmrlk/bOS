-- bOS v0.6.0 — Hybrid Sync Schema
-- Tracks sync state between local files and Supabase

CREATE TABLE IF NOT EXISTS sync_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    file_name TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('push', 'pull', 'conflict')),
    local_hash TEXT,
    remote_hash TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'conflict', 'failed')),
    conflict_resolution TEXT CHECK (conflict_resolution IN ('local-wins', 'remote-wins', 'user-decided', NULL)),
    records_affected INTEGER DEFAULT 0,
    error_message TEXT,
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- State tracking per file
CREATE TABLE IF NOT EXISTS sync_state (
    file_name TEXT PRIMARY KEY,
    last_local_modified TIMESTAMPTZ,
    last_remote_modified TIMESTAMPTZ,
    last_sync TIMESTAMPTZ,
    sync_status TEXT NOT NULL DEFAULT 'unknown' CHECK (sync_status IN ('synced', 'local-ahead', 'remote-ahead', 'conflict', 'unknown')),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sync_log_file ON sync_log(file_name);
CREATE INDEX IF NOT EXISTS idx_sync_log_synced ON sync_log(synced_at DESC);

-- RLS
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sync_log_all" ON sync_log FOR ALL USING (true);
CREATE POLICY "sync_state_all" ON sync_state FOR ALL USING (true);

-- Comments
COMMENT ON TABLE sync_log IS 'bOS Hybrid Sync — history of sync operations between local and Supabase';
COMMENT ON TABLE sync_state IS 'bOS Hybrid Sync — current sync state per file';
COMMENT ON COLUMN sync_state.sync_status IS 'synced = in sync, local-ahead = local changes not pushed, remote-ahead = remote changes not pulled';

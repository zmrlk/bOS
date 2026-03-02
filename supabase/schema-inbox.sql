-- bOS v0.6.1 — Unified Inbox Schema
-- Stores messages from all channels (Telegram, Email, Slack, Discord, WhatsApp)

CREATE TABLE IF NOT EXISTS messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    channel TEXT NOT NULL CHECK (channel IN ('telegram', 'email', 'slack', 'discord', 'whatsapp', 'other')),
    sender_id TEXT NOT NULL,
    sender_name TEXT,
    subject TEXT,
    body TEXT NOT NULL,
    response TEXT,
    status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'routed', 'reply_pending', 'replied', 'archived')),
    routed_agent TEXT,
    raw_metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ,
    replied_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_messages_status ON messages(status);
CREATE INDEX IF NOT EXISTS idx_messages_channel ON messages(channel);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(status) WHERE status = 'unread';

-- RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "messages_select" ON messages FOR SELECT USING (true);
CREATE POLICY "messages_insert" ON messages FOR INSERT WITH CHECK (true);
CREATE POLICY "messages_update" ON messages FOR UPDATE USING (true);

-- Comments
COMMENT ON TABLE messages IS 'bOS Unified Inbox — all incoming messages from all channels';
COMMENT ON COLUMN messages.channel IS 'Source channel: telegram, email, slack, discord, whatsapp';
COMMENT ON COLUMN messages.status IS 'unread → read → routed/reply_pending → replied/archived';
COMMENT ON COLUMN messages.routed_agent IS 'Which bOS agent this message was routed to (e.g., @cfo, @coo)';
COMMENT ON COLUMN messages.response IS 'bOS response text (set before changing status to reply_pending)';
COMMENT ON COLUMN messages.raw_metadata IS 'Channel-specific metadata (chat_id, message_id, thread info, etc.)';

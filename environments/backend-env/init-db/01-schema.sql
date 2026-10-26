-- ==============================================================================
-- INTEGRIX IX.VOICE - CANONICAL POSTGRESQL INITIALIZATION SCHEMA
-- Strictly aligned with Canonical Contracts v0.1
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Bảng lưu trữ trạng thái Processing Job (audio_job_v0_1)
CREATE TABLE IF NOT EXISTS audio_jobs (
    job_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status VARCHAR(50) NOT NULL DEFAULT 'QUEUED',
    progress INTEGER NOT NULL DEFAULT 0,
    trace_id VARCHAR(100),
    filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    format VARCHAR(50),
    duration_ms BIGINT,
    sample_rate INTEGER,
    channels INTEGER,
    audio_path TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng lưu thông tin phiên âm tổng thể (transcript_v0_1)
CREATE TABLE IF NOT EXISTS transcripts (
    transcript_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES audio_jobs(job_id) ON DELETE CASCADE,
    model_version VARCHAR(100) NOT NULL,
    language VARCHAR(10) DEFAULT 'vi',
    snr_estimate_db NUMERIC(5, 2),
    low_confidence_segments_count INTEGER DEFAULT 0,
    average_confidence NUMERIC(4, 3) DEFAULT 1.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng lưu từng đoạn câu nói theo mốc thời gian & người nói
CREATE TABLE IF NOT EXISTS transcript_segments (
    segment_id VARCHAR(50) PRIMARY KEY,
    job_id UUID NOT NULL REFERENCES audio_jobs(job_id) ON DELETE CASCADE,
    transcript_id UUID REFERENCES transcripts(transcript_id) ON DELETE CASCADE,
    start_ms BIGINT NOT NULL,
    end_ms BIGINT NOT NULL,
    speaker_id VARCHAR(50) NOT NULL,
    speaker_label VARCHAR(100),
    text TEXT NOT NULL,
    confidence NUMERIC(4, 3) NOT NULL,
    words_json JSONB
);

-- Index tối ưu tốc độ truy vấn theo Job ID và Thời gian
CREATE INDEX IF NOT EXISTS idx_audio_jobs_status ON audio_jobs(status);
CREATE INDEX IF NOT EXISTS idx_transcripts_job_id ON transcripts(job_id);
CREATE INDEX IF NOT EXISTS idx_segments_job_id ON transcript_segments(job_id);
CREATE INDEX IF NOT EXISTS idx_segments_time ON transcript_segments(start_ms, end_ms);

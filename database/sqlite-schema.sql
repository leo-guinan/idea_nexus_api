-- Innovation Nexus - Skippy Database Schema
-- SQLite version

-- Investors table - tracks all investor interactions
CREATE TABLE IF NOT EXISTS investors (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE,
    first_contact_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_interaction_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    qualification_score INTEGER DEFAULT 0,
    status TEXT DEFAULT 'screening', -- screening, rejected, qualified, founder_contact
    rejection_reason TEXT,
    qualified_at DATETIME,
    founder_contacted_at DATETIME,
    total_interactions INTEGER DEFAULT 1,
    session_data TEXT DEFAULT '{}', -- JSON stored as TEXT in SQLite
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Investor interactions table - detailed log of all interactions
CREATE TABLE IF NOT EXISTS investor_interactions (
    id TEXT PRIMARY KEY,
    investor_id TEXT REFERENCES investors(id) ON DELETE CASCADE,
    session_id TEXT NOT NULL,
    interaction_type TEXT NOT NULL, -- initial_contact, qualification_question, meme_deployment, rejection, qualification_success
    message TEXT,
    response TEXT,
    qualification_data TEXT, -- JSON stored as TEXT
    meme_deployed TEXT,
    score_change INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Qualification tests table - tracks specific test responses
CREATE TABLE IF NOT EXISTS qualification_tests (
    id TEXT PRIMARY KEY,
    investor_id TEXT REFERENCES investors(id) ON DELETE CASCADE,
    test_type TEXT NOT NULL, -- pattern_recognition, temporal_understanding, bottega_test
    question TEXT NOT NULL,
    response TEXT NOT NULL,
    score INTEGER NOT NULL,
    analysis TEXT,
    passed INTEGER DEFAULT 0, -- Boolean as INTEGER (0/1)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Meme deployments table - tracks meme warfare effectiveness
CREATE TABLE IF NOT EXISTS meme_deployments (
    id TEXT PRIMARY KEY,
    investor_id TEXT REFERENCES investors(id) ON DELETE CASCADE,
    meme_type TEXT NOT NULL,
    situation TEXT NOT NULL,
    stupidity_level INTEGER NOT NULL,
    effectiveness_score INTEGER, -- 1-10 based on investor reaction
    investor_reaction TEXT,
    cultural_references TEXT, -- JSON array stored as TEXT
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Daily statistics table - aggregated daily metrics
CREATE TABLE IF NOT EXISTS daily_stats (
    date DATE PRIMARY KEY,
    total_interactions INTEGER DEFAULT 0,
    total_rejections INTEGER DEFAULT 0,
    total_qualifications INTEGER DEFAULT 0,
    rejection_rate REAL DEFAULT 0.0,
    average_qualification_score REAL DEFAULT 0.0,
    most_common_rejection_reason TEXT,
    memes_deployed INTEGER DEFAULT 0,
    angriest_investor_count INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pattern recognition table - tracks common investor failure patterns
CREATE TABLE IF NOT EXISTS investor_patterns (
    id TEXT PRIMARY KEY,
    pattern_name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    keywords TEXT NOT NULL, -- JSON array stored as TEXT
    score_impact INTEGER NOT NULL,
    frequency_count INTEGER DEFAULT 0,
    last_seen_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Founder alerts table - notifications for qualified investors
CREATE TABLE IF NOT EXISTS founder_alerts (
    id TEXT PRIMARY KEY,
    investor_id TEXT REFERENCES investors(id) ON DELETE CASCADE,
    alert_type TEXT DEFAULT 'qualified_investor',
    message TEXT NOT NULL,
    investor_summary TEXT, -- JSON stored as TEXT
    sent_at DATETIME,
    acknowledged_at DATETIME,
    meeting_scheduled_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_investors_email ON investors(email);
CREATE INDEX IF NOT EXISTS idx_investors_status ON investors(status);
CREATE INDEX IF NOT EXISTS idx_investors_qualification_score ON investors(qualification_score);
CREATE INDEX IF NOT EXISTS idx_investor_interactions_investor_id ON investor_interactions(investor_id);
CREATE INDEX IF NOT EXISTS idx_investor_interactions_session_id ON investor_interactions(session_id);
CREATE INDEX IF NOT EXISTS idx_investor_interactions_type ON investor_interactions(interaction_type);
CREATE INDEX IF NOT EXISTS idx_qualification_tests_investor_id ON qualification_tests(investor_id);
CREATE INDEX IF NOT EXISTS idx_qualification_tests_type ON qualification_tests(test_type);
CREATE INDEX IF NOT EXISTS idx_meme_deployments_investor_id ON meme_deployments(investor_id);
CREATE INDEX IF NOT EXISTS idx_meme_deployments_type ON meme_deployments(meme_type);
CREATE INDEX IF NOT EXISTS idx_daily_stats_date ON daily_stats(date);
CREATE INDEX IF NOT EXISTS idx_founder_alerts_investor_id ON founder_alerts(investor_id);
CREATE INDEX IF NOT EXISTS idx_founder_alerts_sent ON founder_alerts(sent_at);

-- Create triggers for SQLite (simplified compared to PostgreSQL)
-- Note: SQLite triggers are more limited than PostgreSQL

-- Trigger to update investor's last_interaction_at and total_interactions
CREATE TRIGGER IF NOT EXISTS update_interaction_count_trigger
    AFTER INSERT ON investor_interactions
BEGIN
    UPDATE investors
    SET total_interactions = total_interactions + 1,
        last_interaction_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.investor_id;

    -- Update or insert daily stats
    INSERT OR REPLACE INTO daily_stats (
        date,
        total_interactions,
        total_rejections,
        total_qualifications,
        rejection_rate,
        updated_at
    )
    VALUES (
        DATE('now'),
        COALESCE((SELECT total_interactions FROM daily_stats WHERE date = DATE('now')), 0) + 1,
        COALESCE((SELECT total_rejections FROM daily_stats WHERE date = DATE('now')), 0),
        COALESCE((SELECT total_qualifications FROM daily_stats WHERE date = DATE('now')), 0),
        CAST(COALESCE((SELECT total_rejections FROM daily_stats WHERE date = DATE('now')), 0) AS REAL) /
        (COALESCE((SELECT total_interactions FROM daily_stats WHERE date = DATE('now')), 0) + 1),
        CURRENT_TIMESTAMP
    );
END;

-- Trigger to update daily stats when investor status changes
CREATE TRIGGER IF NOT EXISTS update_daily_stats_on_status_change
    AFTER UPDATE OF status ON investors
    WHEN OLD.status != NEW.status
BEGIN
    -- Ensure today's stats record exists
    INSERT OR IGNORE INTO daily_stats (date, total_interactions, total_rejections, total_qualifications)
    VALUES (DATE('now'), 0, 0, 0);

    -- Update rejections count
    UPDATE daily_stats
    SET total_rejections = total_rejections + 1,
        rejection_rate = CAST(total_rejections + 1 AS REAL) / CAST(total_interactions AS REAL),
        updated_at = CURRENT_TIMESTAMP
    WHERE date = DATE('now') AND NEW.status = 'rejected';

    -- Update qualifications count
    UPDATE daily_stats
    SET total_qualifications = total_qualifications + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE date = DATE('now') AND NEW.status = 'qualified';
END;

-- Trigger to update updated_at timestamp
CREATE TRIGGER IF NOT EXISTS update_investor_updated_at
    AFTER UPDATE ON investors
BEGIN
    UPDATE investors SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
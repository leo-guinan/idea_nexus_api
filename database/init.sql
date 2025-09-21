-- Innovation Nexus - Skippy Database Schema
-- PostgreSQL initialization script

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Investors table - tracks all investor interactions
CREATE TABLE investors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    first_contact_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_interaction_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    qualification_score INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'screening', -- screening, rejected, qualified, founder_contact
    rejection_reason TEXT,
    qualified_at TIMESTAMP,
    founder_contacted_at TIMESTAMP,
    total_interactions INTEGER DEFAULT 1,
    session_data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Investor interactions table - detailed log of all interactions
CREATE TABLE investor_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    session_id VARCHAR(255) NOT NULL,
    interaction_type VARCHAR(50) NOT NULL, -- initial_contact, qualification_question, meme_deployment, rejection, qualification_success
    message TEXT,
    response TEXT,
    qualification_data JSONB,
    meme_deployed VARCHAR(100),
    score_change INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Qualification tests table - tracks specific test responses
CREATE TABLE qualification_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    test_type VARCHAR(50) NOT NULL, -- pattern_recognition, temporal_understanding, bottega_test
    question TEXT NOT NULL,
    response TEXT NOT NULL,
    score INTEGER NOT NULL,
    analysis TEXT,
    passed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Meme deployments table - tracks meme warfare effectiveness
CREATE TABLE meme_deployments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    meme_type VARCHAR(100) NOT NULL,
    situation VARCHAR(50) NOT NULL,
    stupidity_level INTEGER NOT NULL,
    effectiveness_score INTEGER, -- 1-10 based on investor reaction
    investor_reaction TEXT,
    cultural_references TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Daily statistics table - aggregated daily metrics
CREATE TABLE daily_stats (
    date DATE PRIMARY KEY,
    total_interactions INTEGER DEFAULT 0,
    total_rejections INTEGER DEFAULT 0,
    total_qualifications INTEGER DEFAULT 0,
    rejection_rate DECIMAL(5,4) DEFAULT 0.0000,
    average_qualification_score DECIMAL(5,2) DEFAULT 0.00,
    most_common_rejection_reason VARCHAR(255),
    memes_deployed INTEGER DEFAULT 0,
    angriest_investor_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pattern recognition table - tracks common investor failure patterns
CREATE TABLE investor_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pattern_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    keywords TEXT[] NOT NULL,
    score_impact INTEGER NOT NULL,
    frequency_count INTEGER DEFAULT 0,
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Founder alerts table - notifications for qualified investors
CREATE TABLE founder_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investor_id UUID REFERENCES investors(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) DEFAULT 'qualified_investor',
    message TEXT NOT NULL,
    investor_summary JSONB,
    sent_at TIMESTAMP,
    acknowledged_at TIMESTAMP,
    meeting_scheduled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial investor failure patterns
INSERT INTO investor_patterns (pattern_name, description, keywords, score_impact) VALUES
('TAM Question', 'Asks about Total Addressable Market - classic pattern-blind behavior', ARRAY['tam', 'total addressable market', 'market size'], -5),
('Scaling Question', 'Asks "how does this scale" - linear thinking', ARRAY['scale', 'scaling', 'how does this scale'], -3),
('Moat Thinking', 'Traditional competitive moat questions', ARRAY['moat', 'competitive advantage', 'defensibility'], -5),
('Accelerator Comparison', 'Compares to YC/Techstars - completely missing the point', ARRAY['yc', 'y combinator', 'techstars', 'accelerator', 'like yc but'], -10),
('Buzzword Bingo', 'Uses startup buzzwords without understanding', ARRAY['revolutionary', 'disruptive', 'synergy', 'paradigm shift'], -3),
('Pattern Recognition', 'Shows understanding of failure pattern repetition', ARRAY['pattern', 'repeat', 'cycle', 'failure patterns'], 2),
('Temporal Thinking', 'Demonstrates temporal/consciousness concepts', ARRAY['temporal', 'consciousness', 'awareness', 'time', 'dimension'], 3),
('Consciousness Understanding', 'Grasps consciousness transfer concept', ARRAY['consciousness transfer', 'awareness transfer', 'way of seeing'], 5);

-- Insert daily stats for today
INSERT INTO daily_stats (date, total_interactions, total_rejections, total_qualifications, rejection_rate)
VALUES (CURRENT_DATE, 0, 0, 0, 0.0000)
ON CONFLICT (date) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX idx_investors_email ON investors(email);
CREATE INDEX idx_investors_status ON investors(status);
CREATE INDEX idx_investors_qualification_score ON investors(qualification_score);
CREATE INDEX idx_investor_interactions_investor_id ON investor_interactions(investor_id);
CREATE INDEX idx_investor_interactions_session_id ON investor_interactions(session_id);
CREATE INDEX idx_investor_interactions_type ON investor_interactions(interaction_type);
CREATE INDEX idx_qualification_tests_investor_id ON qualification_tests(investor_id);
CREATE INDEX idx_qualification_tests_type ON qualification_tests(test_type);
CREATE INDEX idx_meme_deployments_investor_id ON meme_deployments(investor_id);
CREATE INDEX idx_meme_deployments_type ON meme_deployments(meme_type);
CREATE INDEX idx_daily_stats_date ON daily_stats(date);
CREATE INDEX idx_founder_alerts_investor_id ON founder_alerts(investor_id);
CREATE INDEX idx_founder_alerts_sent ON founder_alerts(sent_at);

-- Create function to update daily stats
CREATE OR REPLACE FUNCTION update_daily_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update daily stats when investor status changes
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        INSERT INTO daily_stats (date, total_interactions, total_rejections, total_qualifications)
        VALUES (CURRENT_DATE, 0, 0, 0)
        ON CONFLICT (date) DO NOTHING;
        
        IF NEW.status = 'rejected' THEN
            UPDATE daily_stats 
            SET total_rejections = total_rejections + 1,
                rejection_rate = CAST(total_rejections + 1 AS DECIMAL) / CAST(total_interactions AS DECIMAL),
                updated_at = CURRENT_TIMESTAMP
            WHERE date = CURRENT_DATE;
        ELSIF NEW.status = 'qualified' THEN
            UPDATE daily_stats 
            SET total_qualifications = total_qualifications + 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE date = CURRENT_DATE;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for daily stats updates
CREATE TRIGGER update_daily_stats_trigger
    AFTER UPDATE ON investors
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_stats();

-- Create function to update interaction counts
CREATE OR REPLACE FUNCTION update_interaction_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total interactions for the investor
    UPDATE investors 
    SET total_interactions = total_interactions + 1,
        last_interaction_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.investor_id;
    
    -- Update daily stats total interactions
    INSERT INTO daily_stats (date, total_interactions, total_rejections, total_qualifications)
    VALUES (CURRENT_DATE, 1, 0, 0)
    ON CONFLICT (date) DO UPDATE SET
        total_interactions = daily_stats.total_interactions + 1,
        rejection_rate = CASE 
            WHEN daily_stats.total_interactions + 1 > 0 
            THEN CAST(daily_stats.total_rejections AS DECIMAL) / CAST(daily_stats.total_interactions + 1 AS DECIMAL)
            ELSE 0.0000 
        END,
        updated_at = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for interaction counts
CREATE TRIGGER update_interaction_count_trigger
    AFTER INSERT ON investor_interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_interaction_count();

-- Create function to update pattern frequencies
CREATE OR REPLACE FUNCTION update_pattern_frequency()
RETURNS TRIGGER AS $$
DECLARE
    pattern_record RECORD;
    response_lower TEXT;
BEGIN
    response_lower := LOWER(NEW.response);
    
    -- Check each pattern against the response
    FOR pattern_record IN SELECT * FROM investor_patterns LOOP
        -- Check if any of the pattern keywords are in the response
        IF EXISTS (
            SELECT 1 FROM UNNEST(pattern_record.keywords) AS keyword 
            WHERE response_lower LIKE '%' || keyword || '%'
        ) THEN
            -- Update frequency count
            UPDATE investor_patterns 
            SET frequency_count = frequency_count + 1,
                last_seen_at = CURRENT_TIMESTAMP
            WHERE id = pattern_record.id;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for pattern frequency updates
CREATE TRIGGER update_pattern_frequency_trigger
    AFTER INSERT ON investor_interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_pattern_frequency();

-- Insert some sample data for testing
INSERT INTO investors (email, qualification_score, status, rejection_reason) VALUES
('pattern.blind@example.com', -8, 'rejected', 'Asked about TAM within 30 seconds'),
('trend.chaser@vc.com', -5, 'rejected', 'Compared Innovation Nexus to "YC for consciousness"'),
('actually.smart@rare.fund', 7, 'qualified', NULL);

-- Sample interactions
INSERT INTO investor_interactions (investor_id, session_id, interaction_type, message, response, score_change) 
SELECT 
    i.id, 
    'session_sample_' || i.id::text, 
    'qualification_question',
    'What is the nature of founder failure repetition?',
    CASE 
        WHEN i.email = 'pattern.blind@example.com' THEN 'Well, usually it''s market conditions and lack of funding...'
        WHEN i.email = 'trend.chaser@vc.com' THEN 'Is this like YC but for founder coaching?'
        WHEN i.email = 'actually.smart@rare.fund' THEN 'Founders repeat unconscious patterns because they lack the consciousness transfer that would allow them to see beyond their current temporal limitations.'
    END,
    CASE 
        WHEN i.email = 'pattern.blind@example.com' THEN -5
        WHEN i.email = 'trend.chaser@vc.com' THEN -10
        WHEN i.email = 'actually.smart@rare.fund' THEN 5
    END
FROM investors i;

-- Innovation Nexus - SQLite Seed Data

-- Insert initial investor failure patterns
INSERT INTO investor_patterns (id, pattern_name, description, keywords, score_impact) VALUES
('pattern_1', 'TAM Question', 'Asks about Total Addressable Market - classic pattern-blind behavior', '["tam", "total addressable market", "market size"]', -5),
('pattern_2', 'Scaling Question', 'Asks "how does this scale" - linear thinking', '["scale", "scaling", "how does this scale"]', -3),
('pattern_3', 'Moat Thinking', 'Traditional competitive moat questions', '["moat", "competitive advantage", "defensibility"]', -5),
('pattern_4', 'Accelerator Comparison', 'Compares to YC/Techstars - completely missing the point', '["yc", "y combinator", "techstars", "accelerator", "like yc but"]', -10),
('pattern_5', 'Buzzword Bingo', 'Uses startup buzzwords without understanding', '["revolutionary", "disruptive", "synergy", "paradigm shift"]', -3),
('pattern_6', 'Pattern Recognition', 'Shows understanding of failure pattern repetition', '["pattern", "repeat", "cycle", "failure patterns"]', 2),
('pattern_7', 'Temporal Thinking', 'Demonstrates temporal/consciousness concepts', '["temporal", "consciousness", "awareness", "time", "dimension"]', 3),
('pattern_8', 'Consciousness Understanding', 'Grasps consciousness transfer concept', '["consciousness transfer", "awareness transfer", "way of seeing"]', 5);

-- Insert daily stats for today
INSERT OR IGNORE INTO daily_stats (date, total_interactions, total_rejections, total_qualifications, rejection_rate)
VALUES (DATE('now'), 0, 0, 0, 0.0);

-- Insert sample investors for testing
INSERT INTO investors (id, email, qualification_score, status, rejection_reason) VALUES
('investor_1', 'pattern.blind@example.com', -8, 'rejected', 'Asked about TAM within 30 seconds'),
('investor_2', 'trend.chaser@vc.com', -5, 'rejected', 'Compared Innovation Nexus to "YC for consciousness"'),
('investor_3', 'actually.smart@rare.fund', 7, 'qualified', NULL);

-- Sample interactions
INSERT INTO investor_interactions (id, investor_id, session_id, interaction_type, message, response, score_change)
VALUES
('interaction_1', 'investor_1', 'session_sample_1', 'qualification_question',
 'What is the nature of founder failure repetition?',
 'Well, usually it''s market conditions and lack of funding...', -5),
('interaction_2', 'investor_2', 'session_sample_2', 'qualification_question',
 'What is the nature of founder failure repetition?',
 'Is this like YC but for founder coaching?', -10),
('interaction_3', 'investor_3', 'session_sample_3', 'qualification_question',
 'What is the nature of founder failure repetition?',
 'Founders repeat unconscious patterns because they lack the consciousness transfer that would allow them to see beyond their current temporal limitations.', 5);
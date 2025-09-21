import Database from 'better-sqlite3';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Create a singleton database connection
let db: Database.Database | null = null;

export function getDatabase(): Database.Database {
  if (!db) {
    // Mastra will provide __dirname through shims, but we need a fallback
    const currentDir = typeof __dirname !== 'undefined'
      ? __dirname
      : dirname(fileURLToPath(import.meta.url));
    const dbPath = join(currentDir, '../../skippy.db');
    db = new Database(dbPath);

    // Enable foreign keys
    db.exec('PRAGMA foreign_keys = ON');

    // Enable WAL mode for better concurrency
    db.exec('PRAGMA journal_mode = WAL');
  }

  return db;
}

// Helper function to generate UUID-like IDs for SQLite
export function generateId(): string {
  return 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// Helper function to safely close the database connection
export function closeDatabase(): void {
  if (db) {
    db.close();
    db = null;
  }
}

// Process cleanup
process.on('exit', closeDatabase);
process.on('SIGINT', () => {
  closeDatabase();
  process.exit(0);
});

// Type definitions for database tables
export interface Investor {
  id: string;
  email?: string;
  first_contact_at?: string;
  last_interaction_at?: string;
  qualification_score: number;
  status: 'screening' | 'rejected' | 'qualified' | 'founder_contact';
  rejection_reason?: string;
  qualified_at?: string;
  founder_contacted_at?: string;
  total_interactions: number;
  session_data: string;
  created_at: string;
  updated_at: string;
}

export interface InvestorInteraction {
  id: string;
  investor_id: string;
  session_id: string;
  interaction_type: string;
  message?: string;
  response?: string;
  qualification_data?: string;
  meme_deployed?: string;
  score_change: number;
  created_at: string;
}

export interface QualificationTest {
  id: string;
  investor_id: string;
  test_type: string;
  question: string;
  response: string;
  score: number;
  analysis?: string;
  passed: number;
  created_at: string;
}

export interface MemeDeployment {
  id: string;
  investor_id: string;
  meme_type: string;
  situation: string;
  stupidity_level: number;
  effectiveness_score?: number;
  investor_reaction?: string;
  cultural_references?: string;
  created_at: string;
}

export interface DailyStat {
  date: string;
  total_interactions: number;
  total_rejections: number;
  total_qualifications: number;
  rejection_rate: number;
  average_qualification_score: number;
  most_common_rejection_reason?: string;
  memes_deployed: number;
  angriest_investor_count: number;
  created_at: string;
  updated_at: string;
}

export interface InvestorPattern {
  id: string;
  pattern_name: string;
  description: string;
  keywords: string;
  score_impact: number;
  frequency_count: number;
  last_seen_at: string;
  created_at: string;
}

export interface FounderAlert {
  id: string;
  investor_id: string;
  alert_type: string;
  message: string;
  investor_summary?: string;
  sent_at?: string;
  acknowledged_at?: string;
  meeting_scheduled_at?: string;
  created_at: string;
}
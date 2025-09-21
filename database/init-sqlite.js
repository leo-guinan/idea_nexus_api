import Database from 'better-sqlite3';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Create or open the database
const db = new Database(join(__dirname, '../skippy.db'));

// Enable foreign keys
db.exec('PRAGMA foreign_keys = ON');

// Drop existing tables to allow fresh initialization
console.log('🔄 Dropping existing tables...');
db.exec(`
  DROP TABLE IF EXISTS investor_interactions;
  DROP TABLE IF EXISTS investors;
  DROP TABLE IF EXISTS daily_stats;
  DROP TABLE IF EXISTS investor_patterns;
`);

// Read and execute schema
console.log('📋 Creating schema...');
const schema = readFileSync(join(__dirname, 'sqlite-schema.sql'), 'utf8');
db.exec(schema);

// Read and execute seed data
console.log('🌱 Inserting seed data...');
const seed = readFileSync(join(__dirname, 'sqlite-seed.sql'), 'utf8');
db.exec(seed);

console.log('✅ SQLite database initialized successfully');
console.log(`📁 Database location: ${join(__dirname, '../skippy.db')}`);

db.close();
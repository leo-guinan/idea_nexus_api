import { getDatabase } from '../lib/sqlite';

export async function healthCheck() {
  try {
    // Check database connection
    const db = getDatabase();
    const result = db.prepare('SELECT 1 as healthy').get();

    // Check if we can query the database
    const stats = db.prepare('SELECT COUNT(*) as count FROM investors').get();

    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: {
        connected: true,
        investorCount: stats?.count || 0
      },
      version: process.env.npm_package_version || '1.0.0'
    };
  } catch (error) {
    console.error('Health check failed:', error);
    return {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message
    };
  }
}
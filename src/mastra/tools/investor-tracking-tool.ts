import { z } from 'zod';
import { Tool } from '@mastra/core/tools';
import { getDatabase, generateId } from '../../lib/sqlite.js';

export const investorTrackingTool = new Tool({
  id: 'investor_tracking',
  description: 'Track investor interactions, maintain rejection statistics, and store conversation data',
  inputSchema: z.object({
    action: z.enum(['log_interaction', 'update_status', 'get_stats', 'store_email', 'generate_report']).describe('Action to perform'),
    investorId: z.string().optional().describe('Unique identifier for the investor'),
    email: z.string().email().optional().describe('Investor email address'),
    interactionType: z.enum(['initial_contact', 'qualification_question', 'meme_deployment', 'rejection', 'qualification_success']).optional(),
    data: z.record(z.any()).optional().describe('Additional data to store'),
    message: z.string().optional().describe('Message or response from investor'),
  }),
  execute: async ({ action, investorId, email, interactionType, data, message }) => {
    const db = getDatabase();
    const timestamp = new Date().toISOString();

    switch (action) {
      case 'log_interaction':
        if (!investorId || !interactionType) {
          throw new Error('investorId and interactionType required for log_interaction');
        }

        // Check if investor exists, if not create them
        const investor = db.prepare('SELECT id FROM investors WHERE id = ?').get(investorId);
        if (!investor) {
          db.prepare(`
            INSERT INTO investors (id, email, created_at)
            VALUES (?, ?, ?)
          `).run(investorId, email || null, timestamp);
        }

        // Log the interaction
        const interactionId = generateId();
        const sessionId = data?.sessionId || `session_${Date.now()}`;

        db.prepare(`
          INSERT INTO investor_interactions
          (id, investor_id, session_id, interaction_type, message, response, qualification_data, score_change, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          interactionId,
          investorId,
          sessionId,
          interactionType,
          message || null,
          data?.response || null,
          data?.qualificationData ? JSON.stringify(data.qualificationData) : null,
          data?.scoreChange || 0,
          timestamp
        );

        return {
          success: true,
          interactionId,
          logged: {
            investorId,
            interactionType,
            timestamp,
            message,
            data,
            sessionId,
          },
        };

      case 'update_status':
        if (!investorId) {
          throw new Error('investorId required for update_status');
        }

        // Update investor status in database
        const status = data?.status || 'screening';
        const qualificationScore = data?.qualificationScore || 0;
        const rejectionReason = data?.rejectionReason || null;

        db.prepare(`
          UPDATE investors
          SET status = ?,
              qualification_score = ?,
              rejection_reason = ?,
              qualified_at = ?,
              updated_at = ?
          WHERE id = ?
        `).run(
          status,
          qualificationScore,
          rejectionReason,
          status === 'qualified' ? timestamp : null,
          timestamp,
          investorId
        );

        return {
          success: true,
          statusUpdate: {
            investorId,
            status,
            qualificationScore,
            qualified: status === 'qualified',
            rejectionReason,
            timestamp,
          },
        };

      case 'get_stats':
        // Get real statistics from the database
        const today = new Date().toISOString().split('T')[0];

        // Daily stats
        const dailyStats = db.prepare(`
          SELECT * FROM daily_stats WHERE date = ?
        `).get(today) || {
          total_interactions: 0,
          total_rejections: 0,
          total_qualifications: 0,
          rejection_rate: 0,
        };

        // Weekly stats (last 7 days)
        const weeklyStats = db.prepare(`
          SELECT
            SUM(total_interactions) as total_interactions,
            SUM(total_rejections) as total_rejections,
            SUM(total_qualifications) as total_qualifications
          FROM daily_stats
          WHERE date >= date('now', '-7 days')
        `).get();

        // Top rejection reasons
        const topRejectionReasons = db.prepare(`
          SELECT
            rejection_reason as reason,
            COUNT(*) as count
          FROM investors
          WHERE rejection_reason IS NOT NULL
          GROUP BY rejection_reason
          ORDER BY count DESC
          LIMIT 5
        `).all();

        // Meme deployment stats
        const memesDeployed = db.prepare(`
          SELECT
            meme_type,
            COUNT(*) as count
          FROM meme_deployments
          GROUP BY meme_type
          ORDER BY count DESC
          LIMIT 5
        `).all();

        const memeStats = {};
        memesDeployed.forEach(m => {
          memeStats[m.meme_type] = m.count;
        });

        return {
          dailyStats: {
            date: today,
            totalInteractions: dailyStats.total_interactions,
            rejections: dailyStats.total_rejections,
            qualifications: dailyStats.total_qualifications,
            rejectionRate: dailyStats.rejection_rate,
          },
          weeklyStats: {
            totalInteractions: weeklyStats.total_interactions || 0,
            rejections: weeklyStats.total_rejections || 0,
            qualifications: weeklyStats.total_qualifications || 0,
            averageQualificationScore: db.prepare(
              'SELECT AVG(qualification_score) as avg_score FROM investors WHERE status = "qualified"'
            ).get()?.avg_score || 0,
          },
          topRejectionReasons: topRejectionReasons || [],
          memesDeployed: memeStats,
        };

      case 'store_email':
        if (!investorId || !email) {
          throw new Error('investorId and email required for store_email');
        }

        // Update investor email
        db.prepare(`
          UPDATE investors
          SET email = ?,
              status = 'founder_contact',
              founder_contacted_at = ?,
              updated_at = ?
          WHERE id = ?
        `).run(email, timestamp, timestamp, investorId);

        // Create founder alert
        const alertId = generateId();
        const investorData = db.prepare('SELECT * FROM investors WHERE id = ?').get(investorId);

        db.prepare(`
          INSERT INTO founder_alerts
          (id, investor_id, message, investor_summary, created_at)
          VALUES (?, ?, ?, ?, ?)
        `).run(
          alertId,
          investorId,
          `Qualified investor ready for founder contact: ${email}`,
          JSON.stringify({
            email,
            qualificationScore: investorData.qualification_score,
            totalInteractions: investorData.total_interactions,
          }),
          timestamp
        );

        return {
          success: true,
          emailStored: {
            investorId,
            email,
            timestamp,
            status: 'qualified_for_founder_contact',
            notificationSent: false,
          },
          founderNotificationScheduled: true,
        };

      case 'generate_report':
        const date = new Date().toISOString().split('T')[0];

        // Get actual data from database
        const dailyData = db.prepare('SELECT * FROM daily_stats WHERE date = ?').get(date);
        const totalScreened = db.prepare('SELECT COUNT(*) as count FROM investors WHERE DATE(created_at) = ?').get(date)?.count || 0;

        const qualifiedInvestors = db.prepare(`
          SELECT
            id as investorId,
            email,
            qualification_score as qualificationScore,
            qualified_at
          FROM investors
          WHERE status = 'qualified' AND DATE(qualified_at) = ?
        `).all(date);

        const rejectionHighlights = db.prepare(`
          SELECT
            i.id,
            i.rejection_reason,
            ii.response
          FROM investors i
          LEFT JOIN investor_interactions ii ON i.id = ii.investor_id
          WHERE i.status = 'rejected' AND DATE(i.updated_at) = ?
          ORDER BY i.updated_at DESC
          LIMIT 3
        `).all(date);

        const memePerformance = db.prepare(`
          SELECT
            meme_type,
            AVG(effectiveness_score) as avg_effectiveness,
            COUNT(*) as usage_count
          FROM meme_deployments
          WHERE DATE(created_at) = ?
          GROUP BY meme_type
          ORDER BY avg_effectiveness DESC
          LIMIT 1
        `).get(date);

        return {
          date,
          summary: {
            totalInvestorsScreened: totalScreened,
            rejectionRate: dailyData ? `${(dailyData.rejection_rate * 100).toFixed(1)}%` : '0%',
            qualifiedInvestors: qualifiedInvestors.length,
            averageInteractionTime: 'N/A', // Would need to calculate from interaction timestamps
            mostCommonFailure: rejectionHighlights[0]?.rejection_reason || 'None',
            memeEffectiveness: memePerformance ? `${(memePerformance.avg_effectiveness * 10).toFixed(1)}%` : 'N/A',
          },
          qualifiedInvestors: qualifiedInvestors.map(inv => ({
            ...inv,
            keyInsights: [], // Would need to extract from interaction data
            founderMeetingScheduled: inv.email ? true : false,
          })),
          rejectionHighlights: rejectionHighlights.map(r => r.rejection_reason || 'Unspecified'),
          memePerformance: {
            mostEffectiveMeme: memePerformance?.meme_type || 'None',
            fastestRejection: 'N/A',
            angriestInvestor: 'N/A',
          },
        };

      default:
        throw new Error(`Unknown action: ${action}`);
    }
  },
});
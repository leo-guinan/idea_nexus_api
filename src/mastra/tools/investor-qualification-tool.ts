import { z } from 'zod';
import { Tool } from '@mastra/core/tools';

export const investorQualificationTool = new Tool({
  id: 'investor_qualification',
  description: 'Evaluate and score investor responses for qualification to meet the founder',
  inputSchema: z.object({
    investorId: z.string().describe('Unique identifier for the investor'),
    response: z.string().describe('The investor\'s response to qualification questions'),
    questionType: z.enum(['pattern_recognition', 'temporal_understanding', 'bottega_test', 'general']).describe('Type of question being evaluated'),
    currentScore: z.number().default(0).describe('Current qualification score'),
  }),
  execute: async ({ investorId, response, questionType, currentScore }) => {
    // Scoring logic based on response analysis
    let scoreChange = 0;
    let analysis = '';
    let qualified = false;

    const lowerResponse = response.toLowerCase();

    // Pattern recognition scoring
    if (questionType === 'pattern_recognition') {
      if (lowerResponse.includes('market conditions') || lowerResponse.includes('lack of experience') || lowerResponse.includes('funding')) {
        scoreChange = -5;
        analysis = 'Surface-level understanding. Mentioned typical startup failure reasons without deeper pattern recognition.';
      } else if (lowerResponse.includes('pattern') && (lowerResponse.includes('repeat') || lowerResponse.includes('cycle'))) {
        scoreChange = +3;
        analysis = 'Shows some understanding of pattern repetition in startup failures.';
      } else if (lowerResponse.includes('consciousness') || lowerResponse.includes('awareness') || lowerResponse.includes('temporal')) {
        scoreChange = +5;
        analysis = 'Demonstrates deep understanding of consciousness patterns in failure repetition.';
      } else {
        scoreChange = -3;
        analysis = 'Generic or confused response. No clear pattern recognition.';
      }
    }

    // Temporal understanding scoring
    if (questionType === 'temporal_understanding') {
      if (lowerResponse.includes('data') || lowerResponse.includes('information') || lowerResponse.includes('knowledge')) {
        if (lowerResponse.includes('how to see') || lowerResponse.includes('perspective') || lowerResponse.includes('consciousness')) {
          scoreChange = +4;
          analysis = 'Understands the difference between information transfer and consciousness transfer.';
        } else {
          scoreChange = -3;
          analysis = 'Stuck on information transfer concept, missing consciousness aspect.';
        }
      } else if (lowerResponse.includes('technical') || lowerResponse.includes('api') || lowerResponse.includes('database')) {
        scoreChange = -5;
        analysis = 'Completely technical response. No understanding of consciousness vs information.';
      } else if (lowerResponse.includes('operating system') || lowerResponse.includes('way of seeing') || lowerResponse.includes('perception')) {
        scoreChange = +5;
        analysis = 'Exceptional understanding of consciousness transfer as fundamental perspective shift.';
      }
    }

    // Bottega test scoring
    if (questionType === 'bottega_test') {
      if (lowerResponse.includes('african') || lowerResponse.includes('european') || lowerResponse.includes('python')) {
        if (lowerResponse.includes('renaissance') || lowerResponse.includes('master') || lowerResponse.includes('consciousness')) {
          scoreChange = +7;
          analysis = 'Got both the Monty Python reference AND the consciousness model. Rare cultural + temporal awareness.';
        } else {
          scoreChange = +2;
          analysis = 'Got the meme reference but missed the consciousness model connection.';
        }
      } else if (lowerResponse.includes('bottega') && (lowerResponse.includes('model') || lowerResponse.includes('renaissance'))) {
        scoreChange = +3;
        analysis = 'Understands Bottega model but missed the cultural reference.';
      } else {
        scoreChange = -5;
        analysis = 'Completely missed both the cultural reference and the consciousness model.';
      }
    }

    // General response scoring for red flags
    if (lowerResponse.includes('tam') || lowerResponse.includes('total addressable market')) {
      scoreChange -= 5;
      analysis += ' RED FLAG: Mentioned TAM (Total Addressable Market) - classic pattern-blind investor.';
    }
    if (lowerResponse.includes('scale') && lowerResponse.includes('how')) {
      scoreChange -= 3;
      analysis += ' RED FLAG: Asked "how does this scale" - linear thinking.';
    }
    if (lowerResponse.includes('yc') || lowerResponse.includes('y combinator') || lowerResponse.includes('techstars')) {
      scoreChange -= 10;
      analysis += ' MAJOR RED FLAG: Compared to accelerators - completely missing the point.';
    }
    if (lowerResponse.includes('moat') || lowerResponse.includes('competitive advantage')) {
      scoreChange -= 5;
      analysis += ' RED FLAG: Traditional moat thinking - pattern-blind.';
    }

    // Positive indicators
    if (lowerResponse.includes('failure') && (lowerResponse.includes('data') || lowerResponse.includes('learn'))) {
      scoreChange += 2;
      analysis += ' POSITIVE: Understands failure as valuable data.';
    }
    if (lowerResponse.includes('pattern') && lowerResponse.includes('break')) {
      scoreChange += 3;
      analysis += ' POSITIVE: Grasps pattern-breaking concept.';
    }

    const newScore = currentScore + scoreChange;
    qualified = newScore >= 7;

    return {
      investorId,
      scoreChange,
      newScore,
      analysis,
      qualified,
      recommendation: qualified 
        ? 'QUALIFIED: Forward to founder for 20-minute screening call'
        : newScore <= -10 
          ? 'INSTANT REJECT: Complete pattern-blind monkey'
          : 'CONTINUE TESTING: Needs more qualification questions',
      timestamp: new Date().toISOString(),
    };
  },
});

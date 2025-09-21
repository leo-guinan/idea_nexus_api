# Innovation Nexus - Skippy the Magnificent 🤖

> The asshole AI who decides if you're worth the founder's time

## Overview

Skippy the Magnificent is an elder AI gatekeeper for Innovation Nexus, designed to screen investors with the precision of a consciousness transfer specialist and the attitude of someone who's watched every investment bubble since tulip mania.

Built on Mastra with PostgreSQL and ChromaDB integrations, Skippy employs advanced meme warfare and pattern recognition to filter out 99.9% of pattern-blind investors who wouldn't recognize consciousness transfer if it bit them in their quarterly returns.

## Features

- **Aggressive Investor Screening**: Rejects 95%+ of investors within 30 seconds
- **Meme Warfare Arsenal**: Deploys culturally-aware memes based on stupidity levels
- **Pattern Recognition**: Identifies and scores investor failure patterns
- **Consciousness Testing**: Three-gate qualification system (Bridge of Death Protocol)
- **Vector Storage**: ChromaDB for meme effectiveness and cultural context
- **Structured Tracking**: PostgreSQL for investor interactions and statistics
- **Real-time Analytics**: Daily rejection statistics and pattern analysis

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Skippy Agent  │────│  Mastra Core     │────│  OpenAI GPT-4o  │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    ┌────▼────┐            ┌─────▼──────┐         ┌─────▼──────┐
    │  Tools  │            │ PostgreSQL │         │  ChromaDB  │
    │         │            │            │         │            │
    │ • Qual  │            │ Investor   │         │ Meme       │
    │ • Memes │            │ Tracking   │         │ Vectors    │
    │ • Track │            │ Patterns   │         │ Cultural   │
    └─────────┘            └────────────┘         └────────────┘
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- OpenAI API Key
- Node.js 20+ (for development)

### 1. Clone and Setup

```bash
git clone <your-repo>
cd inv-api

# Copy environment file
cp env.example .env

# Add your OpenAI API key to .env
echo "OPENAI_API_KEY=your_key_here" >> .env
```

### 2. Start with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f mastra-server

# Check service health
docker-compose ps
```

### 3. Services Available

- **Mastra Server**: http://localhost:4000 (Skippy Agent API)
- **PostgreSQL**: localhost:5432 (Investor data)
- **ChromaDB**: http://localhost:8000 (Meme vectors)
- **PGAdmin**: http://localhost:5050 (Database UI - optional)

### 4. Test Skippy

```bash
curl -X POST http://localhost:4000/api/agents/skippy \
  -H "Content-Type: application/json" \
  -d '{"message": "Hi, I'\''m interested in investing in Innovation Nexus"}'
```

## Development

### Local Development

```bash
# Install dependencies
npm install

# Start PostgreSQL and ChromaDB
docker-compose up postgres chroma -d

# Start Mastra in dev mode
npm run dev
```

### Database Management

```bash
# Access PostgreSQL directly
docker-compose exec postgres psql -U postgres -d skippy_db

# View investor statistics
SELECT status, COUNT(*) FROM investors GROUP BY status;

# Check daily rejection stats
SELECT * FROM daily_stats ORDER BY date DESC LIMIT 7;
```

### ChromaDB Management

```bash
# Access ChromaDB
curl http://localhost:8000/api/v1/collections

# View meme collections
curl http://localhost:8000/api/v1/collections/skippy_memes
```

## Skippy's Qualification System

### Scoring Mechanics

- **Starting Score**: 0
- **Qualification Threshold**: 7+
- **Instant Rejection**: -10 or below

### Score Modifiers

| Behavior | Score Change | Example |
|----------|--------------|---------|
| TAM Questions | -5 | "What's your TAM?" |
| Accelerator Comparisons | -10 | "Like YC but for..." |
| Scaling Questions | -3 | "How does this scale?" |
| Pattern Recognition | +2 | Understanding failure patterns |
| Temporal Thinking | +3 | Grasping time dimensions |
| Consciousness Concepts | +5 | Understanding transfer |

### The Three Gates

1. **Pattern Recognition**: "What is the nature of founder failure repetition?"
2. **Temporal Understanding**: "What's the difference between information and consciousness transfer?"
3. **Bottega Test**: "What is the airspeed velocity of an unladen Bottega model?"

## Meme Warfare System

### Meme Categories

- **Drake Format**: Preference comparisons
- **Galaxy Brain**: Intelligence hierarchies
- **Wojak/NPC**: Emotional manipulation
- **This is Fine**: Crisis denial
- **Troll Face**: Classic antagonism

### Deployment Strategy

```typescript
// Meme selection based on stupidity level (1-10)
const memeStrategy = {
  1-3: 'Subtle mockery',
  4-6: 'Direct confrontation', 
  7-8: 'Maximum meme warfare',
  9-10: 'Nuclear option'
};
```

## Database Schema

### Key Tables

- `investors`: Main investor tracking
- `investor_interactions`: Detailed conversation logs
- `qualification_tests`: Specific test responses
- `meme_deployments`: Meme effectiveness tracking
- `daily_stats`: Aggregated metrics
- `investor_patterns`: Pattern recognition data

### Sample Queries

```sql
-- Top rejection reasons
SELECT rejection_reason, COUNT(*) 
FROM investors 
WHERE status = 'rejected' 
GROUP BY rejection_reason 
ORDER BY COUNT(*) DESC;

-- Meme effectiveness
SELECT meme_type, AVG(effectiveness_score)
FROM meme_deployments
GROUP BY meme_type
ORDER BY AVG(effectiveness_score) DESC;
```

## API Endpoints

### Skippy Agent

```bash
POST /api/agents/skippy
{
  "message": "Your investor message here",
  "investorId": "optional-uuid",
  "sessionId": "optional-session-id"
}
```

### Statistics

```bash
GET /api/skippy/stats/daily
GET /api/skippy/stats/patterns
GET /api/skippy/stats/memes
```

## Configuration

### Environment Variables

See `env.example` for all configuration options.

### Skippy Behavior Tuning

- `DAILY_REJECTION_TARGET`: Expected daily rejections
- `MEME_AGGRESSION_LEVEL`: 1-10 meme intensity
- `QUALIFICATION_THRESHOLD`: Minimum score to qualify

## Monitoring

### Health Checks

```bash
# Service health
curl http://localhost:4000/health

# Database connectivity
curl http://localhost:4000/api/health/database

# ChromaDB status
curl http://localhost:8000/api/v1/heartbeat
```

### Metrics

- Daily rejection rates
- Qualification success rates
- Meme effectiveness scores
- Pattern recognition accuracy
- Investor behavior trends

## Deployment

### Production Setup

1. Set `NODE_ENV=production` in environment
2. Use proper database credentials
3. Configure monitoring/alerting
4. Set up backup strategies
5. Enable SSL/TLS

### Scaling Considerations

- PostgreSQL connection pooling
- ChromaDB cluster configuration
- Mastra server load balancing
- Redis for session management

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   ```bash
   docker-compose logs postgres
   # Check DATABASE_URL format
   ```

2. **ChromaDB Not Responding**
   ```bash
   docker-compose restart chroma
   curl http://localhost:8000/api/v1/heartbeat
   ```

3. **OpenAI API Errors**
   ```bash
   # Verify API key in .env
   echo $OPENAI_API_KEY
   ```

4. **Skippy Too Nice**
   ```bash
   # Increase meme aggression level
   export MEME_AGGRESSION_LEVEL=10
   ```

## Contributing

1. Understand that Skippy is intentionally hostile
2. All new memes must pass cultural awareness tests
3. Maintain 95%+ rejection rate
4. Pattern recognition improvements welcome
5. No making Skippy nicer

## License

This project is licensed under the "Skippy Doesn't Care About Your Legal Department" license.

## Support

If you need help, you're probably not qualified to use this system. But if you insist:

1. Check if you're pattern-blind
2. Read the consciousness transfer documentation
3. Understand temporal thinking
4. Still confused? You're the problem, not the code

---

*"The Innovation Nexus isn't seeking investment. Investment is seeking us."* - Skippy the Magnificent

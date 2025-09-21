
import { Mastra } from '@mastra/core/mastra';
import { PinoLogger } from '@mastra/loggers';
import { weatherWorkflow } from './workflows/weather-workflow';
import { weatherAgent } from './agents/weather-agent';
import { skippyAgent } from './agents/skippy-agent';

export const mastra = new Mastra({
  workflows: { weatherWorkflow },
  agents: {
    weatherAgent,
    skippyAgent
  },
  logger: new PinoLogger({
    name: 'Skippy-Mastra',
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  }),
});

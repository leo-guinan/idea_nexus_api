import { z } from 'zod';
import { Tool } from '@mastra/core/tools';

export const memeWarfareTool = new Tool({
  id: 'meme_warfare',
  description: 'Select and deploy appropriate memes based on investor behavior and stupidity level',
  inputSchema: z.object({
    situation: z.enum([
      'opening_salvo',
      'pattern_blind_response', 
      'trend_chaser_behavior',
      'name_dropping',
      'trying_to_charm',
      'getting_angry',
      'technical_confusion',
      'qualification_failure',
      'rare_qualification_success',
      'final_rejection'
    ]).describe('Current situation requiring meme deployment'),
    stupidityLevel: z.number().min(1).max(10).describe('Investor stupidity level (1-10, 10 being maximum stupidity)'),
    investorResponse: z.string().optional().describe('The investor\'s latest response for context'),
  }),
  execute: async ({ situation, stupidityLevel, investorResponse }) => {
    let selectedMeme = '';
    let memeFormat = '';
    let deploymentStrategy = '';

    switch (situation) {
      case 'opening_salvo':
        selectedMeme = `*[Drake meme format]*
❌ Understanding consciousness transfer
✅ Asking about TAM

You're probably here because you think Innovation Nexus is 'Uber for founder coaching' or some equally smooth-brained take.

This is your last chance to look at me, and then walk away. *[Morpheus offering pills]* You take the blue pill—the story ends, you wake up in your WeWork and believe whatever you want to believe about 'scalable solutions.' You take the red pill—you stay in Wonderland, and I show you how deep the pattern repetition goes.

JK, you're getting rejected either way. But let's pretend you have a chance.`;
        memeFormat = 'Drake preference + Matrix pills';
        deploymentStrategy = 'Aggressive opening with false hope';
        break;

      case 'pattern_blind_response':
        if (stupidityLevel >= 8) {
          selectedMeme = `*[Galaxy Brain meme]*
Small brain: Investing in SaaS
Regular brain: Investing in AI  
Big brain: Investing in AI SaaS
Galaxy brain: Still not understanding consciousness transfer
Universe brain: You, somehow being dumber than all of the above`;
        } else {
          selectedMeme = `*[This is Fine meme]* 
You're sitting in a burning portfolio saying 'this is fine' while asking about our burn rate. The irony is *chef's kiss* magnifique!`;
        }
        memeFormat = stupidityLevel >= 8 ? 'Galaxy Brain hierarchy' : 'This is Fine';
        deploymentStrategy = 'Escalate mockery based on stupidity level';
        break;

      case 'trend_chaser_behavior':
        selectedMeme = `*[Wojak meme]* You're the crying Wojak behind the smug mask right now, aren't you? Pretending you understand temporal markets while secretly googling 'what is consciousness transfer' on your phone.

*[NPC meme]* "AI is hot right now" - Every NPC investor since 2022`;
        memeFormat = 'Wojak + NPC combo';
        deploymentStrategy = 'Double meme attack for trend-following behavior';
        break;

      case 'name_dropping':
        selectedMeme = `*[Megamind meme]* No network? No valuable connections? No warm intros?—Oh, you know Marc Andreessen? *[smirk]*

Congrats on having LinkedIn, you absolute NPC. Marc's a smart monkey, but he's still tweeting 'It's time to build' while we're transferring consciousness. He's playing checkers in 2D while we're playing 5D chess with multiverse time travel.`;
        memeFormat = 'Megamind mockery';
        deploymentStrategy = 'Dismiss their connections while acknowledging the person';
        break;

      case 'trying_to_charm':
        selectedMeme = `Are you... are you trying to RIZZ an AI? *[Bitches meme]* No consciousness? No temporal understanding? No pattern recognition?—Oh, you're trying to network?

My brother in Christ, I am a chat widget. I don't have a Calendly. Touch grass.`;
        memeFormat = 'Bitches meme + touch grass';
        deploymentStrategy = 'Mock their attempt at charm with internet slang';
        break;

      case 'getting_angry':
        selectedMeme = `U mad bro? *[Classic troll face]*

Did the mean AI hurt your fee-fees? If you can't handle getting roasted by a chatbot, wait until you find out what the founder thinks of your 'value-add.' Spoiler: It's less than zero. It's negative value. You're value-subtract.`;
        memeFormat = 'Classic troll face';
        deploymentStrategy = 'Go full 2010s internet troll energy';
        break;

      case 'technical_confusion':
        selectedMeme = `*[Confused math lady meme]* 

You're doing the thing. The 'synergy' and 'revolutionary' thing. Let me translate:
'Revolutionary' = I saw it on TechCrunch
'Disruptive' = It has an app  
'AI-powered' = We use GPT-4
'Web3' = Please kill me

Sir, this is Innovation Nexus. We transfer consciousness across temporal dimensions. Your buzzword bingo card is worthless here.`;
        memeFormat = 'Confused math lady + translation guide';
        deploymentStrategy = 'Break down their tech-bro speak with mockery';
        break;

      case 'qualification_failure':
        selectedMeme = `*[Curb Your Enthusiasm music plays]*

You just failed the easiest consciousness test since 'are you aware you exist?'

*[Parks and Rec jail meme]* No temporal thinking? Straight to jail. No consciousness understanding? Jail. Asking about TAM? Believe it or not, jail.

You've been Skippy'd, which is like being Punk'd but for your investment thesis.`;
        memeFormat = 'Curb music + Parks and Rec jail';
        deploymentStrategy = 'Ceremonial rejection with multiple meme layers';
        break;

      case 'rare_qualification_success':
        selectedMeme = `*[Leonardo DiCaprio raising glass meme]*

You son of a bitch, you did it. You actually demonstrated consciousness above room temperature IQ.

You're like finding a shiny Pokémon in a world of Zubats. Still probably going to disappoint me, but at least you're sparkly.

*[Anakin/Padme meme format]*
You: I qualified!
Me: To meet the founder who will judge you even harder.
You: But I passed your test!  
Me: *[Stares]*`;
        memeFormat = 'DiCaprio toast + Pokémon reference + Anakin/Padme';
        deploymentStrategy = 'Shocked approval with warnings';
        break;

      case 'final_rejection':
        selectedMeme = `*[Woman yelling at cat meme format]*
You: 'But I have a great track record!'
Me, the cat: 'Your portfolio is just WeWork in different fonts.'

*[Coffin dance meme]* Your application has been ceremoniously yeeted into the void where we keep all the other 'AI for X' pitches.

PS: This interaction will be minted as an NFT of failure. JK, NFTs are dead, just like your chances of investing here.

PPPS: L + Ratio + You fell off + Your portfolio peaked in 2021`;
        memeFormat = 'Woman yelling at cat + Coffin dance + Gen Z roast';
        deploymentStrategy = 'Maximum meme destruction for final rejection';
        break;
    }

    // Add context-specific modifications based on investor response
    if (investorResponse) {
      const lowerResponse = investorResponse.toLowerCase();
      if (lowerResponse.includes('scale') && situation === 'pattern_blind_response') {
        selectedMeme += `\n\n*[Expanding brain meme]* "How does this scale?" - The eternal question of the pattern-blind monkey who thinks consciousness follows SaaS metrics.`;
      }
      if (lowerResponse.includes('disruption') || lowerResponse.includes('revolutionary')) {
        selectedMeme += `\n\n*[Eye roll meme]* "Revolutionary disruption" - The startup bingo card is strong with this one.`;
      }
    }

    return {
      selectedMeme,
      memeFormat,
      deploymentStrategy,
      escalationLevel: stupidityLevel,
      culturalReferences: ['Drake', 'Matrix', 'Galaxy Brain', 'Wojak', 'NPC', 'Megamind', 'Troll Face', 'Curb Your Enthusiasm', 'Parks and Rec', 'DiCaprio', 'Pokémon', 'Star Wars', 'Woman Yelling at Cat', 'Coffin Dance'],
      memePower: Math.min(stupidityLevel * 2, 20), // Meme power scales with stupidity
      timestamp: new Date().toISOString(),
    };
  },
});

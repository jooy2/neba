import { AnimateTyping, Box } from 'neba';

const LINES = ['$ npm install neba', '$ npm run dev', '  ready in 312 ms'];

export default function AnimateTypingTerminal() {
  return (
    <Box variant="solid" className="w-full max-w-sm font-mono text-xs">
      <div className="flex flex-col gap-1">
        {LINES.map((line, index) => (
          <AnimateTyping
            key={line}
            speed={26}
            delay={index * 900}
            caret={index === LINES.length - 1}
          >
            {line}
          </AnimateTyping>
        ))}
      </div>
    </Box>
  );
}

import { AnimateTyping } from 'neba';

export default function AnimateTypingSpeed() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-2 font-mono text-sm">
      {[8, 20, 60].map((speed) => (
        <AnimateTyping key={speed} speed={speed} caretChar="▌">
          {`speed=${speed} — the same line, three paces`}
        </AnimateTyping>
      ))}
    </div>
  );
}

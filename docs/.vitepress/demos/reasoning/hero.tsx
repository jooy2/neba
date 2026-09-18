import { useEffect, useState } from 'react';
import { Reasoning } from 'neba';

const THOUGHT = [
  'The request is about a colour that changes at a breakpoint.',
  'Neither a class map nor a media query alone covers that, because Tailwind only sees literal class names.',
  'So the value has to reach CSS through an inline custom property, and the cascade has to be written once per slot.'
];

export default function ReasoningHero() {
  const [lines, setLines] = useState(1);
  const streaming = lines < THOUGHT.length;

  useEffect(() => {
    if (!streaming) {
      return undefined;
    }

    const id = setTimeout(() => setLines((count) => count + 1), 1600);

    return () => clearTimeout(id);
  }, [streaming, lines]);

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <Reasoning streaming={streaming}>
        {THOUGHT.slice(0, lines).map((line) => (
          <p key={line} className="m-0 mb-2 last:mb-0">
            {line}
          </p>
        ))}
      </Reasoning>
    </div>
  );
}

import { useEffect, useState } from 'react';
import { StreamingText } from 'neba';

const ANSWER =
  'A Neba surface is a sheet of cut acrylic rather than a moulded plastic key. Nothing scales under the pointer, because scaling a control resamples its label — state changes are expressed in colour and depth instead.';

const WORDS = ANSWER.split(' ');

export default function StreamingTextHero() {
  const [count, setCount] = useState(0);
  const streaming = count < WORDS.length;

  useEffect(() => {
    if (!streaming) {
      const id = setTimeout(() => setCount(0), 2400);

      return () => clearTimeout(id);
    }

    const id = setTimeout(() => setCount((at) => at + 1), 110);

    return () => clearTimeout(id);
  }, [streaming, count]);

  return (
    <div className="w-full max-w-lg">
      <StreamingText
        render={<p className="m-0 text-[0.9375rem]/[1.7]" />}
        streaming={streaming}
        lines={4}
      >
        {WORDS.slice(0, count).join(' ')}
      </StreamingText>
    </div>
  );
}

import { useState } from 'react';
import { Button, StreamingText } from 'neba';

export default function StreamingTextReserve() {
  const [text, setText] = useState('');

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <div className="rounded-[var(--neba-radius-md)] border border-[var(--vp-c-divider)] p-3">
        <StreamingText streaming={text === ''} lines={3}>
          {text}
        </StreamingText>
      </div>
      <p className="m-0 text-[0.8125rem] text-[var(--vp-c-text-2)]">
        The box is three lines tall before the first word lands, and stays three lines tall once it
        has. What comes after it never moves.
      </p>
      <Button size="sm" variant="outline" onClick={() => setText(text === '' ? 'One line.' : '')}>
        {text === '' ? 'Let the first word land' : 'Empty it again'}
      </Button>
    </div>
  );
}

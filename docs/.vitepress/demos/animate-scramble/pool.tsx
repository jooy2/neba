import { useState } from 'react';
import { AnimateScramble, Button, Typography } from 'neba';

export default function AnimateScramblePool() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Run again
      </Button>

      <div key={run} className="flex flex-col gap-5">
        <div className="flex flex-col gap-1">
          <Typography level="caption" color="secondary">
            speed=10 — slower
          </Typography>
          <AnimateScramble
            text="DECODING"
            speed={10}
            className="font-mono text-lg text-(--neba-fg)"
          />
        </div>

        <div className="flex flex-col gap-1">
          <Typography level="caption" color="secondary">
            characters=&quot;01&quot;
          </Typography>
          <AnimateScramble
            text="0100 1110 0100 0101"
            characters="01"
            className="font-mono text-lg text-(--neba-fg)"
          />
        </div>
      </div>
    </div>
  );
}

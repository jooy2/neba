import { useState } from 'react';
import { AnimateReveal, Box, Button, Typography } from 'neba';

const SIDES = ['left', 'right', 'top', 'bottom'] as const;

export default function AnimateRevealSides() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Play again
      </Button>

      <div key={run} className="grid gap-3 sm:grid-cols-2">
        {SIDES.map((side, index) => (
          <AnimateReveal key={side} side={side} delay={index * 160} duration={800}>
            <Box variant="outline" size="sm">
              <Typography level="caption" color="secondary">
                side=&quot;{side}&quot;
              </Typography>
            </Box>
          </AnimateReveal>
        ))}
      </div>
    </div>
  );
}

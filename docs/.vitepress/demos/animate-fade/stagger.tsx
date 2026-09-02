import { AnimateFade, Box, Button, Typography } from 'neba';
import { useState } from 'react';

const ROWS = ['Design', 'Engineering', 'Research', 'Support', 'Finance'];

export default function AnimateFadeStagger() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Play again
      </Button>

      <div key={run} className="grid gap-6 sm:grid-cols-2">
        <div className="flex flex-col gap-2">
          <Typography level="caption" color="secondary">
            stagger=60
          </Typography>
          <AnimateFade stagger={60} className="flex flex-col gap-2">
            {ROWS.map((row) => (
              <Box key={row} size="sm" variant="outline">
                {row}
              </Box>
            ))}
          </AnimateFade>
        </div>

        <div className="flex flex-col gap-2">
          <Typography level="caption" color="secondary">
            stagger=60 · durationStep=120 · reverse
          </Typography>
          <AnimateFade stagger={60} durationStep={120} reverse className="flex flex-col gap-2">
            {ROWS.map((row) => (
              <Box key={row} size="sm" variant="outline" color="secondary">
                {row}
              </Box>
            ))}
          </AnimateFade>
        </div>
      </div>
    </div>
  );
}

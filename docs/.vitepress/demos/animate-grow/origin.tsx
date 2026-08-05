import { useState } from 'react';
import { AnimateGrow, Box, Button, Typography } from 'neba';

const ORIGINS = ['center', 'top left', 'bottom right', 'top'];

export default function AnimateGrowOrigin() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <div className="flex flex-wrap items-center justify-center gap-3">
        {ORIGINS.map((origin) => (
          <AnimateGrow key={`${origin}-${run}`} origin={origin} from={0.2} duration={700}>
            <Box size="sm">
              <Typography level="caption">{origin}</Typography>
            </Box>
          </AnimateGrow>
        ))}
      </div>
    </div>
  );
}

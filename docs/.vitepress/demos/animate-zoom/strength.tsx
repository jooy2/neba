import { useState } from 'react';
import { AnimateZoom, Box, Button, Typography } from 'neba';

export default function AnimateZoomStrength() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <div className="flex flex-wrap items-center justify-center gap-3">
        {[0.1, 0.4, 1.8].map((from) => (
          <AnimateZoom key={`${from}-${run}`} from={from} duration={700}>
            <Box size="sm">
              <Typography level="caption">from {from}</Typography>
            </Box>
          </AnimateZoom>
        ))}
      </div>
    </div>
  );
}

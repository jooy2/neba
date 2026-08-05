import { useState } from 'react';
import { AnimateSlide, Box, Button, Typography } from 'neba';

const EDGES = ['top', 'right', 'bottom', 'left'] as const;

export default function AnimateSlideEdges() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <div className="flex flex-wrap items-center justify-center gap-3">
        {EDGES.map((edge) => (
          <div key={edge} className="overflow-hidden">
            <AnimateSlide key={`${edge}-${run}`} from={edge} duration={700}>
              <Box size="sm">
                <Typography level="caption">from {edge}</Typography>
              </Box>
            </AnimateSlide>
          </div>
        ))}
      </div>
    </div>
  );
}

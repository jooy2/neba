import { useState } from 'react';
import { AnimateBlink, Button, Typography } from 'neba';

export default function AnimateBlinkCounted() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Draw attention
      </Button>

      <AnimateBlink key={run} repeat={3} duration={500} min={0.2}>
        <Typography level="h4" color="danger">
          Payment overdue
        </Typography>
      </AnimateBlink>
    </div>
  );
}

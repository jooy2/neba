import { useState } from 'react';
import { AnimateZoom, Button, Statistic } from 'neba';

export default function AnimateZoomHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateZoom key={run} duration={600}>
        <Statistic label="Uptime this quarter" value={99.98} previousValue={99.94} unit="%" />
      </AnimateZoom>
    </div>
  );
}

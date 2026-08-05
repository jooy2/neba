import { useState } from 'react';
import { AnimateGrow, Button, Card } from 'neba';

export default function AnimateGrowHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateGrow key={run} duration={600}>
        <Card title="Filters" size="sm">
          Three of nine applied.
        </Card>
      </AnimateGrow>
    </div>
  );
}

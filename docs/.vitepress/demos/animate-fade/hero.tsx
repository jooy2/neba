import { useState } from 'react';
import { AnimateFade, Button, Card } from 'neba';

export default function AnimateFadeHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateFade key={run} duration={700}>
        <Card title="Deployment finished" size="sm">
          Two services restarted, no errors.
        </Card>
      </AnimateFade>
    </div>
  );
}

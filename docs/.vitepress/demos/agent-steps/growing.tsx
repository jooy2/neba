import { useEffect, useState } from 'react';
import { AgentStep, AgentSteps, Button } from 'neba';

const PLAN = [
  { title: 'Read the request', meta: '', duration: 120 },
  { title: 'Searched the documentation', meta: '4 hits', duration: 412 },
  { title: 'Opened two files', meta: 'src/internal/responsive.ts', duration: 86 },
  { title: 'Wrote the answer', meta: '', duration: 1840 }
];

export default function AgentStepsGrowing() {
  const [done, setDone] = useState(0);
  const growing = done < PLAN.length;

  useEffect(() => {
    if (!growing) {
      return undefined;
    }

    const id = setTimeout(() => setDone((count) => count + 1), 1400);

    return () => clearTimeout(id);
  }, [growing, done]);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <AgentSteps running={growing}>
        {PLAN.slice(0, done).map((step) => (
          <AgentStep
            key={step.title}
            title={step.title}
            meta={step.meta || undefined}
            duration={step.duration}
          />
        ))}
      </AgentSteps>
      <Button size="sm" variant="outline" onClick={() => setDone(0)}>
        Run it again
      </Button>
    </div>
  );
}

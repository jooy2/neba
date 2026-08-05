import { useState } from 'react';
import { AnimateAppear, Button, Chip } from 'neba';

const STEPS = ['One', 'Two', 'Three', 'Four'];

export default function AnimateAppearDirection() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateAppear key={`f-${run}`} from="left" className="flex gap-2">
        {STEPS.map((step) => (
          <Chip key={step} color="info">
            {step}
          </Chip>
        ))}
      </AnimateAppear>

      <AnimateAppear key={`r-${run}`} from="left" reverse className="flex gap-2">
        {STEPS.map((step) => (
          <Chip key={step} color="secondary">
            {step}
          </Chip>
        ))}
      </AnimateAppear>
    </div>
  );
}

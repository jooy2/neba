import { useState } from 'react';
import { Button, HowToSteps, Typography } from 'neba';

const STEPS = [
  { title: 'Install', content: <Typography>One package, one stylesheet import.</Typography> },
  { title: 'Wrap', content: <Typography>Nothing to wrap. There is no provider.</Typography> },
  { title: 'Use it', content: <Typography>Import the component and render it.</Typography> }
];

export default function HowToStepsControlled() {
  const [step, setStep] = useState(0);
  const [completed, setCompleted] = useState(false);

  return (
    <div className="flex w-full flex-col gap-4">
      <div className="flex flex-wrap items-center gap-3">
        <Typography color="secondary">
          {completed ? 'finished' : `step ${step + 1} of ${STEPS.length}`}
        </Typography>
        <div className="grow" />
        <Button
          size="sm"
          variant="outline"
          onClick={() => {
            setCompleted(false);
            setStep(0);
          }}
        >
          Reset from outside
        </Button>
      </div>

      <HowToSteps
        steps={STEPS}
        step={step}
        onStepChange={setStep}
        completed={completed}
        onCompletedChange={setCompleted}
      />
    </div>
  );
}

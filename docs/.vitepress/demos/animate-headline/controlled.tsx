import { useState } from 'react';
import { AnimateHeadline, Button, ButtonGroup, Typography } from 'neba';

const STEPS = ['Choose a plan', 'Add your details', 'Confirm and pay'];

export default function AnimateHeadlineControlled() {
  const [step, setStep] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <AnimateHeadline index={step} className="text-lg font-semibold">
        {STEPS.map((label) => (
          <span key={label}>{label}</span>
        ))}
      </AnimateHeadline>

      <ButtonGroup size="sm" variant="outline">
        <Button onClick={() => setStep((index) => Math.max(index - 1, 0))}>Back</Button>
        <Button onClick={() => setStep((index) => Math.min(index + 1, STEPS.length - 1))}>
          Next
        </Button>
      </ButtonGroup>

      <Typography level="caption">
        Step {step + 1} of {STEPS.length}
      </Typography>
    </div>
  );
}

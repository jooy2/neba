import { useState } from 'react';
import { Button, ProgressBox } from 'neba';

const STEPS = ['Account', 'Workspace', 'Billing', 'Invite', 'Done'];

/**
 * When the thing being waited on genuinely has steps, `count` is the number of
 * them and the plates stop being a decoration.
 */
export default function ProgressBoxSteps() {
  const [step, setStep] = useState(2);

  return (
    <div className="flex flex-col items-start gap-4">
      <ProgressBox
        size="lg"
        count={STEPS.length}
        value={step}
        min={0}
        max={STEPS.length}
        color="success"
        label={STEPS[Math.min(step, STEPS.length - 1)]}
      />
      <div className="flex items-center gap-2">
        <Button
          size="sm"
          variant="outline"
          color="secondary"
          disabled={step === 0}
          onClick={() => setStep(step - 1)}
        >
          Back
        </Button>
        <Button size="sm" disabled={step === STEPS.length} onClick={() => setStep(step + 1)}>
          Next
        </Button>
      </div>
    </div>
  );
}

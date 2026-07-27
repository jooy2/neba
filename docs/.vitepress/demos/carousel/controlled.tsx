import { useState } from 'react';
import { Button, ButtonGroup, Carousel, Typography } from 'neba';

const STEPS = ['Connect a repository', 'Pick a branch', 'Choose a region', 'Deploy'];

/**
 * `value` / `onValueChange` are the usual controlled pair, so a carousel can be
 * driven by something else on the page — here, a wizard's own step buttons.
 */
export default function CarouselControlled() {
  const [step, setStep] = useState(0);

  return (
    <div className="flex w-full flex-col gap-3">
      <Carousel
        label="Setup steps"
        value={step}
        onValueChange={setStep}
        arrows={false}
        indicators={false}
        loop={false}
      >
        {STEPS.map((title, index) => (
          <div key={title} className="flex h-28 flex-col justify-center gap-1 p-6">
            <Typography level="overline">
              Step {index + 1} of {STEPS.length}
            </Typography>
            <Typography level="h4">{title}</Typography>
          </div>
        ))}
      </Carousel>

      <ButtonGroup variant="outline" size="sm" color="secondary">
        <Button disabled={step === 0} onClick={() => setStep(step - 1)}>
          Back
        </Button>
        <Button disabled={step === STEPS.length - 1} onClick={() => setStep(step + 1)}>
          Next
        </Button>
      </ButtonGroup>
    </div>
  );
}

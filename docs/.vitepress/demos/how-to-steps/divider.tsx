import { useState } from 'react';
import { Checkbox, HowToSteps, Typography } from 'neba';

const STEPS = [
  { title: 'Fork', content: <Typography>Your own copy, on your own account.</Typography> },
  {
    title: 'Branch',
    content: <Typography>One branch per change, named after the change.</Typography>
  },
  {
    title: 'Open a PR',
    content: <Typography>Describe what it does, not what it touches.</Typography>
  }
];

export default function HowToStepsDivider() {
  const [divider, setDivider] = useState(true);

  return (
    <div className="flex w-full flex-col gap-4">
      <Checkbox size="sm" checked={divider} onCheckedChange={setDivider} label="divider" />

      <HowToSteps divider={divider} steps={STEPS} />
    </div>
  );
}

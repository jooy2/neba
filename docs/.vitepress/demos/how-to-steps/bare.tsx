import { HowToSteps, Typography } from 'neba';

const STEPS = [
  {
    title: 'Read the brief',
    content: <Typography>Everything the client sent, in one sitting.</Typography>
  },
  { title: 'Sketch', content: <Typography>On paper. Three ideas, ten minutes each.</Typography> },
  {
    title: 'Pick one',
    content: <Typography>The one you would defend, not the safe one.</Typography>
  }
];

export default function HowToStepsBare() {
  return (
    <div className="flex w-full flex-col gap-4">
      <HowToSteps variant="text" navigation={false} steps={STEPS} />
      <HowToSteps variant="solid" completion={false} density="compact" size="sm" steps={STEPS} />
    </div>
  );
}

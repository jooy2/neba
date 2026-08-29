import { HowToSteps, Typography } from 'neba';

const STEPS = Array.from({ length: 14 }, (unused, index) => ({
  title: `Migration ${String(index + 1).padStart(3, '0')}`,
  content: (
    <Typography>
      Run it against the staging database first, then production. Nothing here is reversible.
    </Typography>
  )
}));

export default function HowToStepsScrolling() {
  return <HowToSteps title="Fourteen migrations" maxHeight={340} steps={STEPS} />;
}

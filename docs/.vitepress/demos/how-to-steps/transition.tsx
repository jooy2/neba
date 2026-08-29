import { useState } from 'react';
import { HowToSteps, Segment, SegmentedButton, Typography } from 'neba';
import type { NebaTransition } from 'neba';

const STEPS = [
  {
    title: 'Pick a plan',
    content: <Typography>Monthly or yearly. Yearly is two months free.</Typography>
  },
  {
    title: 'Add a card',
    content: <Typography>Charged on the first of the month, never before.</Typography>
  },
  { title: 'Confirm', content: <Typography>You can cancel from Billing at any time.</Typography> }
];

const OPTIONS: Record<string, NebaTransition | 'none'> = {
  fade: 'fade',
  slide: { type: 'slide', from: 'right', distance: 24 },
  zoom: { type: 'zoom', scale: 0.96, duration: 220 },
  none: 'none'
};

export default function HowToStepsTransition() {
  const [effect, setEffect] = useState('slide');

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton size="sm" value={effect} onValueChange={(next) => setEffect(String(next))}>
        {Object.keys(OPTIONS).map((name) => (
          <Segment key={name} value={name}>
            {name}
          </Segment>
        ))}
      </SegmentedButton>

      <HowToSteps transition={OPTIONS[effect]} steps={STEPS} />
    </div>
  );
}

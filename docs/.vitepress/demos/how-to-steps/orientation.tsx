import { useState } from 'react';
import { HowToSteps, Segment, SegmentedButton, Typography } from 'neba';
import type { NebaOrientation } from 'neba';

const STEPS = [
  {
    title: 'Account',
    content: <Typography>Name, email, and a password you have not used elsewhere.</Typography>
  },
  {
    title: 'Workspace',
    content: <Typography>Pick a name and a region. Both can be changed later.</Typography>
  },
  { title: 'Invite', content: <Typography>Add the people who will need it on day one.</Typography> }
];

export default function HowToStepsOrientation() {
  const [orientation, setOrientation] = useState<NebaOrientation>('horizontal');

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton
        size="sm"
        value={orientation}
        onValueChange={(next) => setOrientation(next as NebaOrientation)}
      >
        <Segment value="vertical">vertical</Segment>
        <Segment value="horizontal">horizontal</Segment>
      </SegmentedButton>

      <HowToSteps orientation={orientation} steps={STEPS} />
    </div>
  );
}

import { useState } from 'react';
import { AnimateRotate, Button, Icon } from 'neba';

function StarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m8 2 1.8 3.9 4.2.5-3.1 2.9.8 4.2L8 11.4 4.3 13.5l.8-4.2L2 6.4l4.2-.5L8 2Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function AnimateRotateHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateRotate key={run} from={-270} duration={800}>
        <Icon icon={<StarIcon />} size="xl" color="warning" label="Starred" />
      </AnimateRotate>
    </div>
  );
}

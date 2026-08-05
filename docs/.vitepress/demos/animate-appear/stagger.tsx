import { useState } from 'react';
import { AnimateAppear, Button, Chip } from 'neba';

const TAGS = ['design', 'frontend', 'infra', 'docs', 'billing', 'search'];

export default function AnimateAppearStagger() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateAppear key={run} stagger={140} className="flex flex-wrap justify-center gap-2">
        {TAGS.map((tag) => (
          <Chip key={tag}>{tag}</Chip>
        ))}
      </AnimateAppear>
    </div>
  );
}

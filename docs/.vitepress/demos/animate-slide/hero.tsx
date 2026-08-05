import { useState } from 'react';
import { AnimateSlide, Alert, Button } from 'neba';

export default function AnimateSlideHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full max-w-sm flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <div className="w-full overflow-hidden">
        <AnimateSlide key={run} from="left" duration={600}>
          <Alert color="success" title="Invitation sent">
            They will get an email in the next minute.
          </Alert>
        </AnimateSlide>
      </div>
    </div>
  );
}

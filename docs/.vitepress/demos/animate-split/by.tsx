import { useState } from 'react';
import { AnimateSplit, Button, Typography } from 'neba';

export default function AnimateSplitBy() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Play again
      </Button>

      <div key={run} className="flex flex-col gap-5">
        <div className="flex flex-col gap-1">
          <Typography level="caption" color="secondary">
            by=&quot;word&quot; — the default
          </Typography>
          <AnimateSplit className="text-lg text-(--neba-fg)">
            Eight words is eight boxes on the page.
          </AnimateSplit>
        </div>

        <div className="flex flex-col gap-1">
          <Typography level="caption" color="secondary">
            by=&quot;character&quot; · effect=&quot;grow&quot;
          </Typography>
          <AnimateSplit
            by="character"
            effect="grow"
            stagger={28}
            className="text-lg text-(--neba-fg)"
          >
            Letter by letter
          </AnimateSplit>
        </div>
      </div>
    </div>
  );
}

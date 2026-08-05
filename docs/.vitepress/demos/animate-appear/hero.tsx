import { useState } from 'react';
import { AnimateAppear, Button, Card } from 'neba';

const ROWS = [
  { title: 'Design review', body: 'Thursday, 14:00' },
  { title: 'Sprint planning', body: 'Friday, 10:00' },
  { title: 'Retrospective', body: 'Friday, 16:30' }
];

export default function AnimateAppearHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full max-w-xs flex-col items-center gap-4">
      <Button size="sm" variant="outline" onClick={() => setRun((count) => count + 1)}>
        Play again
      </Button>

      <AnimateAppear key={run} className="flex w-full flex-col gap-2">
        {ROWS.map((row) => (
          <Card key={row.title} title={row.title} size="sm">
            {row.body}
          </Card>
        ))}
      </AnimateAppear>
    </div>
  );
}

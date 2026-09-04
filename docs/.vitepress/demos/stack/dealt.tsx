import { useState } from 'react';
import { Avatar, Button, Card, Stack, Typography } from 'neba';

const TEAM = ['Anya Sol', 'Theo Quinn', 'Lucas Adebayo', 'Nadia Rowan', 'Noa Marin'].map(
  (name) => ({ name, src: `/samples/people/${name.toLowerCase().replace(' ', '-')}.jpg` })
);
const CARDS = ['Alpha', 'Beta', 'Gamma', 'Delta'];

export default function StackDealt() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Deal again
      </Button>

      <div key={run} className="flex flex-wrap items-start gap-10">
        <div className="flex flex-col gap-2">
          <Typography level="caption" color="secondary">
            transition=&quot;fade&quot; · stagger=90
          </Typography>
          <Stack ring transition="fade" stagger={90}>
            {TEAM.map((person) => (
              <Avatar key={person.name} name={person.name} src={person.src} />
            ))}
          </Stack>
        </div>

        <div className="flex flex-col gap-2">
          <Typography level="caption" color="secondary">
            transition=&quot;zoom&quot; · stagger=120 · reverse
          </Typography>
          <Stack
            direction="diagonal"
            overlap={56}
            drop={12}
            scaleStep={0.96}
            transition="zoom"
            stagger={120}
            reverse
          >
            {CARDS.map((name) => (
              <Card key={name} size="sm" className="w-32" title={name} elevation={1} />
            ))}
          </Stack>
        </div>
      </div>
    </div>
  );
}

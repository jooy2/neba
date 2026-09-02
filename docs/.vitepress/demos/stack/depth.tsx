import { Card, Stack, Typography } from 'neba';

const CARDS = ['Today', 'Tomorrow', 'Thursday', 'Friday'];

export default function StackDepth() {
  return (
    <div className="flex w-full flex-wrap items-start gap-10">
      <div className="flex flex-col gap-2">
        <Typography level="caption" color="secondary">
          scaleStep=0.94 · opacityStep=0.75
        </Typography>
        <Stack direction="diagonal" overlap={64} drop={10} scaleStep={0.94} opacityStep={0.75}>
          {CARDS.map((day) => (
            <Card key={day} size="sm" className="w-36" title={day} elevation={1} />
          ))}
        </Stack>
      </div>

      <div className="flex flex-col gap-2">
        <Typography level="caption" color="secondary">
          front=&quot;last&quot;
        </Typography>
        <Stack
          direction="diagonal"
          overlap={64}
          drop={10}
          scaleStep={0.94}
          opacityStep={0.75}
          front="last"
        >
          {CARDS.map((day) => (
            <Card key={day} size="sm" className="w-36" title={day} elevation={1} />
          ))}
        </Stack>
      </div>
    </div>
  );
}

import { AnimateFloat, Avatar, Typography } from 'neba';

const FACES = ['Ada', 'Bo', 'Cai', 'Dana'];

export default function AnimateFloatDistance() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div className="flex flex-col gap-2">
        <Typography level="caption" color="secondary">
          stagger=400 — the same drift, out of step
        </Typography>
        <AnimateFloat stagger={400} distance={10} className="flex gap-3">
          {FACES.map((name) => (
            <Avatar key={name} name={name} size="lg" />
          ))}
        </AnimateFloat>
      </div>

      <div className="flex flex-col gap-2">
        <Typography level="caption" color="secondary">
          from=&quot;left&quot; · distance=14 · duration=2200
        </Typography>
        <AnimateFloat from="left" distance={14} duration={2200}>
          <Avatar name="Eun" size="lg" color="success" />
        </AnimateFloat>
      </div>
    </div>
  );
}

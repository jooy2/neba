import { Typography } from 'neba';

const LEVELS = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'lead', 'body', 'caption', 'overline'] as const;

export default function TypographyScale() {
  return (
    <div className="flex flex-col gap-3">
      {LEVELS.map((level) => (
        <div key={level} className="flex items-baseline gap-4">
          <code className="w-20 shrink-0 text-[0.6875rem] text-[var(--neba-muted-fg)]">
            {level}
          </code>
          <Typography level={level}>The quick brown fox</Typography>
        </div>
      ))}
    </div>
  );
}

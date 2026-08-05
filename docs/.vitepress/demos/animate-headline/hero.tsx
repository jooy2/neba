import { AnimateHeadline, Typography } from 'neba';

const CLAIMS = ['faster', 'quieter', 'accessible', 'yours'];

export default function AnimateHeadlineHero() {
  return (
    <Typography level="h3" render={<div />} className="flex items-baseline gap-2">
      <span>Interfaces that are</span>
      <AnimateHeadline interval={2000} className="text-(--neba-primary-accent)">
        {CLAIMS.map((claim) => (
          <span key={claim}>{claim}</span>
        ))}
      </AnimateHeadline>
    </Typography>
  );
}

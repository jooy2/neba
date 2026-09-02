import { AnimateReveal, Typography } from 'neba';

export default function AnimateRevealHero() {
  return (
    <AnimateReveal duration={900}>
      <Typography level="h4">Nothing moved. It was let through.</Typography>
    </AnimateReveal>
  );
}

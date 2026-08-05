import { AnimateLighting, Button } from 'neba';

/* An infinite effect on `hover` stops when the pointer leaves; keyboard focus
   counts as a pointer, so it is reachable without a mouse. */
export default function AnimateLightingHover() {
  return (
    <AnimateLighting trigger="hover" size="md" glow="#d946ef" arc={70} duration={1600}>
      <Button size="lg">Upgrade the plan</Button>
    </AnimateLighting>
  );
}

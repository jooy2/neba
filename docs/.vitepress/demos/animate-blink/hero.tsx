import { AnimateBlink, Chip } from 'neba';

export default function AnimateBlinkHero() {
  return (
    <AnimateBlink min={0.35} duration={1100}>
      <Chip color="danger" variant="solid">
        Recording
      </Chip>
    </AnimateBlink>
  );
}

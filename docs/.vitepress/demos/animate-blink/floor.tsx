import { AnimateBlink, Chip } from 'neba';

/* `min` is a dimming rather than a disappearance, which is what keeps the word
   readable while it pulses. */
export default function AnimateBlinkFloor() {
  return (
    <div className="flex items-center gap-3">
      {[0, 0.3, 0.6].map((min) => (
        <AnimateBlink key={min} min={min} duration={1200}>
          <Chip color="warning">min {min}</Chip>
        </AnimateBlink>
      ))}
    </div>
  );
}

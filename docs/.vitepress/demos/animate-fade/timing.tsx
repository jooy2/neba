import { AnimateFade, Chip } from 'neba';

export default function AnimateFadeTiming() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-2">
      {[0, 200, 400, 600].map((delay) => (
        <AnimateFade key={delay} delay={delay} duration={500}>
          <Chip>{delay}ms</Chip>
        </AnimateFade>
      ))}
    </div>
  );
}

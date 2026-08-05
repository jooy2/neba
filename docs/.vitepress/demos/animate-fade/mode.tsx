import { AnimateFade, Chip } from 'neba';

export default function AnimateFadeMode() {
  return (
    <div className="flex items-center gap-3">
      <AnimateFade duration={1200} repeat="infinite" alternate>
        <Chip color="success">in</Chip>
      </AnimateFade>

      <AnimateFade mode="out" duration={1200} repeat="infinite" alternate>
        <Chip color="danger">out</Chip>
      </AnimateFade>
    </div>
  );
}

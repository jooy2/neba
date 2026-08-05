import { AnimateRotate, Chip } from 'neba';

export default function AnimateRotateOrigin() {
  return (
    <div className="flex items-center gap-8 py-4">
      <AnimateRotate
        origin="bottom left"
        from={-12}
        to={12}
        duration={1600}
        repeat="infinite"
        alternate
        fade={false}
      >
        <Chip color="warning">bottom left</Chip>
      </AnimateRotate>

      <AnimateRotate
        origin="center"
        from={-12}
        to={12}
        duration={1600}
        repeat="infinite"
        alternate
        fade={false}
      >
        <Chip color="warning">center</Chip>
      </AnimateRotate>
    </div>
  );
}

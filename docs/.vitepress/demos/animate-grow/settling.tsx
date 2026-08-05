import { AnimateGrow, Chip } from 'neba';

/* Above 1 it arrives oversized and settles back down onto the page. */
export default function AnimateGrowSettling() {
  return (
    <div className="flex items-center gap-3">
      <AnimateGrow from={0.6} duration={1400} repeat="infinite" alternate>
        <Chip>from 0.6</Chip>
      </AnimateGrow>

      <AnimateGrow from={1.3} duration={1400} repeat="infinite" alternate fade={false}>
        <Chip color="success">from 1.3</Chip>
      </AnimateGrow>
    </div>
  );
}

import { ProgressCircular } from 'neba';

export default function ProgressCircularHero() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <ProgressCircular value={72} showValue label="Indexing" />
      <ProgressCircular color="secondary" />
    </div>
  );
}

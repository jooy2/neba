import { ProgressBox } from 'neba';

export default function ProgressBoxHero() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <ProgressBox />
      <ProgressBox value={62} label="Migrating" showValue color="info" />
    </div>
  );
}

import { ProgressLinear } from 'neba';

export default function ProgressLinearHero() {
  return (
    <div className="flex w-full max-w-96 flex-col gap-5">
      <ProgressLinear value={64} label="Uploading assets" showValue />
      <ProgressLinear color="secondary" />
    </div>
  );
}

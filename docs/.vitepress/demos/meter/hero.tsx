import { Meter } from 'neba';

export default function MeterHero() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <Meter value={38} label="Storage" showValue />
      <Meter
        value={82}
        label="Seats"
        showValue
        thresholds={[
          { from: 70, color: 'warning' },
          { from: 90, color: 'danger' }
        ]}
      />
      <Meter value={96} label="API quota" showValue color="danger" />
    </div>
  );
}

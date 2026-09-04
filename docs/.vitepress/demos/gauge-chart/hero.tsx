import { GaugeChart } from 'neba';

export default function GaugeChartHero() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      <GaugeChart
        variant="outline"
        label="CPU"
        caption="CPU"
        value={0.38}
        format={{ style: 'percent', maximumFractionDigits: 0 }}
        min={0}
        max={1}
      />
      <GaugeChart
        variant="outline"
        label="Memory"
        caption="Memory"
        value={82}
        thresholds={[
          { from: 70, color: 'warning' },
          { from: 90, color: 'danger' }
        ]}
      />
      <GaugeChart variant="outline" label="Disk" caption="Disk" value={96} color="danger" />
    </div>
  );
}

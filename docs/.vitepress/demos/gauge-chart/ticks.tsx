import { GaugeChart } from 'neba';

export default function GaugeChartTicks() {
  return (
    <div className="grid w-full max-w-lg grid-cols-1 gap-4 sm:grid-cols-2">
      <GaugeChart
        variant="outline"
        label="Without marks"
        caption="no ticks"
        value={7.4}
        min={0}
        max={12}
        sweep={270}
        format={{ maximumFractionDigits: 1 }}
      />
      <GaugeChart
        variant="outline"
        label="With marks"
        caption="ticks = 7"
        value={7.4}
        min={0}
        max={12}
        sweep={270}
        ticks={7}
        thickness={0.14}
        format={{ maximumFractionDigits: 1 }}
      />
    </div>
  );
}

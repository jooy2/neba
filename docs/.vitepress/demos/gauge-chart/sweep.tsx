import { GaugeChart } from 'neba';

const sweeps = [180, 240, 300, 360] as const;

export default function GaugeChartSweep() {
  return (
    <div className="grid w-full max-w-3xl grid-cols-2 gap-4 sm:grid-cols-4">
      {sweeps.map((sweep) => (
        <GaugeChart
          key={sweep}
          variant="outline"
          size="sm"
          label={`${sweep} degrees`}
          caption={`${sweep}°`}
          value={64}
          sweep={sweep}
        />
      ))}
    </div>
  );
}

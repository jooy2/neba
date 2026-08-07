import { Card, LineChart } from 'neba';

const DAYS = Array.from({ length: 14 }, (_, index) => `Jun ${index + 1}`);
const UPTIME = [
  99.94, 99.97, 99.99, 99.98, 99.72, 99.88, 99.96, 99.99, 99.99, 99.95, 99.91, 99.97, 99.99, 99.98
];

/**
 * A line chart crops its scale to the data, which is what makes a series that
 * lives between 99.7 and 100 legible at all. `yAxis` is where that gets
 * overridden — a floor, a ceiling, how many ticks, and how each one is written.
 */
export default function LineChartAxes() {
  return (
    <Card title="Availability" subtitle="Rolling fourteen days" className="w-full">
      <LineChart
        label="Availability by day"
        categories={DAYS}
        series={[{ name: 'Uptime', data: UPTIME }]}
        yAxis={{ min: 99.5, max: 100, tickCount: 5, tickFormat: (value) => `${value}%` }}
        xAxis={{ label: 'June' }}
        markers="all"
      />
    </Card>
  );
}

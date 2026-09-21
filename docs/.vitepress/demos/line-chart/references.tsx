import { Card, LineChart } from 'neba';

const DAYS = Array.from({ length: 14 }, (_, index) => `Jun ${index + 1}`);
const LATENCY = [180, 172, 195, 210, 188, 176, 402, 368, 214, 199, 186, 178, 192, 205];

export default function LineChartReferences() {
  return (
    <Card title="Response time" subtitle="p95, milliseconds" className="w-full">
      <LineChart
        label="p95 response time by day"
        categories={DAYS}
        series={[{ name: 'p95', data: LATENCY, color: 'danger' }]}
        yAxis={{ min: 0, tickFormat: (value) => `${value}ms` }}
        references={[
          { value: 250, label: 'SLA', color: 'warning' },
          { value: 0, to: 200, label: 'Budget' },
          { value: 6, to: 7, axis: 'category', label: 'Incident', color: 'danger' }
        ]}
        markers="all"
      />
    </Card>
  );
}

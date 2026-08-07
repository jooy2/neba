import { Card, ScatterChart } from 'neba';

const cloud = (offsetX: number, offsetY: number) =>
  Array.from({ length: 8 }, (_, index) => ({
    x: offsetX + index * 9 + ((index * 37) % 11),
    y: offsetY + ((index * 53) % 17) + index * 2
  }));

/**
 * Four series is one past what the palette separates on a plot where any two
 * marks can end up side by side, so `shape="auto"` gives each series a shape of
 * its own from the fourth on. The legend shows the same shapes.
 */
export default function ScatterChartShape() {
  return (
    <Card title="Latency by region" subtitle="Four regions, four shapes" className="w-full">
      <ScatterChart
        label="Latency against request rate, by region"
        xAxis={{ label: 'Requests per second' }}
        yAxis={{ label: 'p95 latency (ms)' }}
        series={[
          { name: 'us-east', data: cloud(10, 40) },
          { name: 'eu-west', data: cloud(16, 60) },
          { name: 'ap-south', data: cloud(22, 30) },
          { name: 'sa-east', data: cloud(28, 75) }
        ]}
      />
    </Card>
  );
}

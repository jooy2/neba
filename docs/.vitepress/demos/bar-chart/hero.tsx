import { BarChart, Card } from 'neba';

export default function BarChartHero() {
  return (
    <Card title="Deploys per team" subtitle="Last quarter" className="w-full">
      <BarChart
        label="Deploys per team, last quarter"
        categories={['Platform', 'Payments', 'Growth', 'Mobile', 'Data']}
        series={[{ name: 'Deploys', data: [318, 264, 197, 152, 88] }]}
        valueLabels="all"
      />
    </Card>
  );
}

import { Card, LineChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

export default function LineChartHero() {
  return (
    <Card title="Weekly active users" subtitle="Last eight months" className="w-full">
      <LineChart
        label="Weekly active users by month"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [1820, 1960, 2140, 2080, 2390, 2620, 2810, 3040] },
          { name: 'Mobile', data: [940, 1120, 1310, 1580, 1720, 2010, 2380, 2740] },
          { name: 'Desktop app', data: [610, 640, 620, 700, 690, 740, 810, 860] }
        ]}
      />
    </Card>
  );
}

import { Card, LineChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

export default function LineChartExport() {
  return (
    <Card
      title="Weekly active users"
      subtitle="Press the corner to take the numbers"
      className="w-full"
    >
      <LineChart
        label="Weekly active users by month"
        categories={MONTHS}
        exportable
        exportFileName="weekly-active-users.csv"
        series={[
          { name: 'Web', data: [1820, 1960, 2140, 2080, 2310, 2460] },
          { name: 'Mobile', data: [940, 1120, 1310, 1480, 1610, 1790] }
        ]}
      />
    </Card>
  );
}

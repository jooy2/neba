import { Card, PieChart, Typography } from 'neba';

export default function PieChartHero() {
  return (
    <Card title="Traffic by source" subtitle="Sessions this month" className="w-full">
      <PieChart
        label="Sessions by traffic source"
        shape="donut"
        categories={['Organic', 'Direct', 'Paid', 'Referral', 'Social']}
        data={[18420, 9260, 6140, 3080, 1690]}
        center={
          <>
            <Typography level="overline">Sessions</Typography>
            <Typography level="h4">38.6K</Typography>
          </>
        }
      />
    </Card>
  );
}

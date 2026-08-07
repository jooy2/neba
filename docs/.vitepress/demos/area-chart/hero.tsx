import { AreaChart, Card } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

export default function AreaChartHero() {
  return (
    <Card title="Storage used" subtitle="Gigabytes, by tier" className="w-full">
      <AreaChart
        label="Storage used by tier and month"
        categories={MONTHS}
        stacked
        curve="smooth"
        format={{ maximumFractionDigits: 0 }}
        series={[
          { name: 'Hot', data: [120, 138, 149, 162, 171, 188, 204, 226] },
          { name: 'Warm', data: [340, 352, 361, 388, 402, 419, 440, 462] },
          { name: 'Archive', data: [610, 648, 690, 742, 801, 866, 940, 1024] }
        ]}
      />
    </Card>
  );
}

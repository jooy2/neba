import { AreaChart, Card } from 'neba';

const DAYS = Array.from({ length: 30 }, (_, index) => `${index + 1}`);
const SPEND = [
  180, 210, 195, 240, 265, 230, 205, 260, 288, 301, 275, 254, 310, 342, 366, 338, 315, 359, 388,
  402, 377, 351, 396, 421, 448, 430, 405, 452, 481, 512
];

/**
 * One series, so there is no legend — the card's title already says what is
 * plotted, and a box with one swatch in it would only restate it.
 */
export default function AreaChartSingle() {
  return (
    <Card title="Daily spend" subtitle="This month, cumulative by day" className="w-full">
      <AreaChart
        label="Daily spend this month"
        categories={DAYS}
        curve="smooth"
        format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
        series={[{ name: 'Spend', data: SPEND, color: 'success' }]}
        xAxis={{ label: 'Day of month' }}
      />
    </Card>
  );
}

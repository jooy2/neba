import { Card, LineChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

/**
 * The legend is interactive by default: click an entry to hide its series, and
 * the survivors keep the colour they had. `hidden` starts one off.
 */
export default function LineChartLegend() {
  return (
    <Card title="Tickets by priority" className="w-full">
      <LineChart
        label="Tickets by priority and month"
        categories={MONTHS}
        legend={{ side: 'right', align: 'start' }}
        series={[
          { name: 'Urgent', data: [12, 18, 9, 14, 8, 11] },
          { name: 'High', data: [48, 52, 41, 60, 55, 49] },
          { name: 'Normal', data: [190, 204, 176, 221, 208, 194] },
          { name: 'Low', data: [88, 71, 94, 66, 79, 84], hidden: true }
        ]}
      />
    </Card>
  );
}

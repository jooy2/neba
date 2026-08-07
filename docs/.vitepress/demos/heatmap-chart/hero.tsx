import { Card, HeatmapChart } from 'neba';

const HOURS = ['00', '02', '04', '06', '08', '10', '12', '14', '16', '18', '20', '22'];

/** Sessions by hour, one row per weekday. */
const TRAFFIC = [
  { name: 'Mon', data: [4, 2, 1, 6, 24, 41, 38, 44, 51, 33, 18, 9] },
  { name: 'Tue', data: [3, 2, 2, 7, 27, 45, 40, 48, 55, 36, 20, 10] },
  { name: 'Wed', data: [3, 1, 1, 8, 29, 47, 43, 51, 58, 38, 21, 11] },
  { name: 'Thu', data: [4, 2, 2, 8, 28, 46, 41, 49, 56, 40, 23, 12] },
  { name: 'Fri', data: [5, 3, 2, 7, 25, 42, 37, 44, 48, 34, 26, 16] },
  { name: 'Sat', data: [9, 6, 3, 4, 11, 18, 22, 26, 29, 27, 24, 17] },
  { name: 'Sun', data: [8, 5, 2, 3, 9, 15, 19, 23, 25, 24, 21, 13] }
];

export default function HeatmapChartHero() {
  return (
    <Card title="Sessions by hour" subtitle="Thousands, last four weeks" className="w-full">
      <HeatmapChart label="Sessions by hour and weekday" categories={HOURS} series={TRAFFIC} />
    </Card>
  );
}

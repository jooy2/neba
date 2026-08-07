import { Card, Sparkline, Table } from 'neba';

const ROWS = [
  { region: 'Americas', mrr: '$412K', trend: [31, 34, 33, 38, 41, 39, 44, 48] },
  { region: 'EMEA', mrr: '$298K', trend: [28, 27, 30, 29, 31, 30, 33, 34] },
  { region: 'APAC', mrr: '$186K', trend: [11, 14, 13, 18, 17, 22, 26, 29] },
  { region: 'LATAM', mrr: '$74K', trend: [12, 11, 10, 11, 9, 8, 9, 7] }
];

/**
 * The shape a sparkline is usually reached for: one strip per row, in a column
 * of its own. All four are drawn on the same `min` and `max`, without which the
 * bottom row's decline would fill its cell exactly as fully as the top row's
 * climb fills that one.
 */
export default function SparklineShapes() {
  return (
    <Card title="MRR by region" className="w-full">
      <Table
        variant="text"
        headers={[
          { key: 'region', label: 'Region' },
          { key: 'mrr', label: 'MRR', align: 'end' },
          {
            key: 'trend',
            label: 'Eight weeks',
            width: 140,
            render: (row: (typeof ROWS)[number]) => (
              <Sparkline
                data={row.trend}
                shape="area"
                size="sm"
                min={0}
                max={60}
                label={`${row.region} trend`}
              />
            )
          }
        ]}
        items={ROWS}
      />
    </Card>
  );
}

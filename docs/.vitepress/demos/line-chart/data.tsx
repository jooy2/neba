import { Card, Grid, GridContainer, LineChart } from 'neba';

/**
 * The three ways one series can be written. They draw the same chart — pick
 * whichever matches the shape the data already has.
 */
export default function LineChartData() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="Bare numbers" size="sm" className="h-full">
          <LineChart
            label="Bare numbers"
            size="sm"
            height={140}
            categories={['Mon', 'Tue', 'Wed', 'Thu', 'Fri']}
            series={[{ name: 'Orders', data: [24, 31, 28, 39, 44] }]}
          />
        </Card>
      </Grid>

      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="Points with an x" size="sm" className="h-full">
          <LineChart
            label="Points carrying their own x"
            size="sm"
            height={140}
            series={[
              {
                name: 'Orders',
                data: [
                  { x: 'Mon', y: 24 },
                  { x: 'Tue', y: 31 },
                  { x: 'Wed', y: 28 },
                  { x: 'Thu', y: 39 },
                  { x: 'Fri', y: 44 }
                ]
              }
            ]}
          />
        </Card>
      </Grid>

      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="Dates" size="sm" className="h-full">
          <LineChart
            label="Points on dates"
            size="sm"
            height={140}
            series={[
              {
                name: 'Orders',
                data: [
                  { x: new Date(2026, 5, 1), y: 24 },
                  { x: new Date(2026, 5, 2), y: 31 },
                  { x: new Date(2026, 5, 3), y: 28 },
                  { x: new Date(2026, 5, 4), y: 39 },
                  { x: new Date(2026, 5, 5), y: 44 }
                ]
              }
            ]}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

import { BarChart, Card, Grid, GridContainer } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const SERIES = [
  { name: 'New', data: [180, 204, 176, 231, 248, 262] },
  { name: 'Renewed', data: [420, 438, 461, 452, 489, 514] },
  { name: 'Churned', data: [64, 71, 58, 82, 69, 55] }
];

export default function BarChartStacked() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="Grouped" subtitle="Which series is bigger" size="sm" className="h-full">
          <BarChart
            label="Subscriptions, grouped"
            size="sm"
            height={180}
            categories={MONTHS}
            series={SERIES}
            legend={false}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="stacked" subtitle="What the total is made of" size="sm" className="h-full">
          <BarChart
            label="Subscriptions, stacked"
            size="sm"
            height={180}
            categories={MONTHS}
            series={SERIES}
            stacked
            legend={false}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title='stacked="full"' subtitle="The mix" size="sm" className="h-full">
          <BarChart
            label="Subscriptions, as a share"
            size="sm"
            height={180}
            categories={MONTHS}
            series={SERIES}
            stacked="full"
            legend={false}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

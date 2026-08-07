import { BarChart, Card, Grid, GridContainer } from 'neba';

const CATEGORIES = [
  'Documentation',
  'Onboarding flow',
  'Billing portal',
  'Search relevance',
  'Mobile parity'
];
const VOTES = [412, 388, 301, 264, 190];

/**
 * `horizontal` is the right answer whenever the category names are words. A
 * vertical chart gives each name the width of one bar; a horizontal one gives
 * it a whole column.
 */
export default function BarChartOrientation() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card title='orientation="vertical"' size="sm" className="h-full">
          <BarChart
            label="Feature votes, vertical"
            size="sm"
            height={200}
            categories={CATEGORIES}
            series={[{ name: 'Votes', data: VOTES }]}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card title='orientation="horizontal"' size="sm" className="h-full">
          <BarChart
            label="Feature votes, horizontal"
            size="sm"
            height={200}
            orientation="horizontal"
            categories={CATEGORIES}
            series={[{ name: 'Votes', data: VOTES }]}
            valueLabels="all"
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

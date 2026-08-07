import { Card, Grid, GridContainer, LineChart } from 'neba';

const WEEKS = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
// Two weeks the collector was down. Not two weeks of zero.
const READINGS = [42, 47, null, null, 51, 58, 55, 62];

export default function LineChartGaps() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card title="Broken at the gap" subtitle="The default" size="sm" className="h-full">
          <LineChart
            label="Readings with a two-week gap"
            size="sm"
            height={160}
            categories={WEEKS}
            series={[{ name: 'Readings', data: READINGS }]}
            markers="all"
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card
          title="connectNulls"
          subtitle="Only when the gap is an artefact"
          size="sm"
          className="h-full"
        >
          <LineChart
            label="Readings, bridged"
            size="sm"
            height={160}
            categories={WEEKS}
            series={[{ name: 'Readings', data: READINGS }]}
            markers="all"
            connectNulls
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

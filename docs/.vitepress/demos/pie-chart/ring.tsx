import { Card, Grid, GridContainer, PieChart, Typography } from 'neba';

const CATEGORIES = ['Free', 'Pro', 'Team', 'Enterprise'];
const DATA = [4820, 2140, 890, 210];

export default function PieChartRing() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="hole: 0.38" subtitle="A thicker ring" size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, thick ring"
            size="sm"
            height={160}
            shape="donut"
            hole={0.38}
            categories={CATEGORIES}
            data={DATA}
            center={<Typography level="h5">8,060</Typography>}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="gap: 6" subtitle="Slices parted further" size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, wide gap"
            size="sm"
            height={160}
            shape="donut"
            gap={6}
            categories={CATEGORIES}
            data={DATA}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="gap: 0" subtitle="Slices meeting" size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, no gap"
            size="sm"
            height={160}
            gap={0}
            categories={CATEGORIES}
            data={DATA}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

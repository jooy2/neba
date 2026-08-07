import { Card, Grid, GridContainer, PieChart, Typography } from 'neba';

const CATEGORIES = ['Free', 'Pro', 'Team', 'Enterprise'];
const DATA = [4820, 2140, 890, 210];

export default function PieChartShapes() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title='shape="pie"' size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, pie"
            size="sm"
            height={160}
            categories={CATEGORIES}
            data={DATA}
            valueLabels="all"
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title='shape="donut"' size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, donut"
            size="sm"
            height={160}
            shape="donut"
            categories={CATEGORIES}
            data={DATA}
            center={<Typography level="h5">8,060</Typography>}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title='shape="semi"' size="sm" className="h-full">
          <PieChart
            label="Accounts by plan, semicircle"
            size="sm"
            height={160}
            shape="semi"
            categories={CATEGORIES}
            data={DATA}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

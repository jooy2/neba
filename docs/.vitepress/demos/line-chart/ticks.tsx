import { Card, Grid, GridContainer, LineChart } from 'neba';

const STAGES = [
  'Signed up',
  'Email verified',
  'Team invited',
  'Repo connected',
  'PR opened',
  'PR merged',
  'Deployed'
];
const REACHED = [4820, 4110, 2640, 2190, 1480, 1120, 640];

export default function LineChartTicks() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, lg: 6 }}>
        <Card title="Flat" subtitle="Cut to the slot, and two of the seven kept" size="sm">
          <LineChart
            label="Accounts reaching each onboarding stage"
            categories={STAGES}
            series={[{ name: 'Accounts', data: REACHED }]}
            markers="all"
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, lg: 6 }}>
        <Card title="tickAngle: -45" subtitle="All seven, and none of them cut" size="sm">
          <LineChart
            label="Accounts reaching each onboarding stage, turned axis"
            categories={STAGES}
            series={[{ name: 'Accounts', data: REACHED }]}
            xAxis={{ tickAngle: -45 }}
            markers="all"
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

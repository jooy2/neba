import { Grid, GridContainer, Statistic } from 'neba';

export default function StatisticHero() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic
          label="Monthly recurring revenue"
          value={48210}
          prefix="$"
          previousValue={42800}
          caption="vs. last month"
          className="h-full"
        />
      </Grid>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic
          label="Active workspaces"
          value={1284}
          previousValue={1284}
          caption="vs. last month"
          className="h-full"
        />
      </Grid>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic
          label="Churn"
          value={0.041}
          format={{ style: 'percent', maximumFractionDigits: 1 }}
          previousValue={0.036}
          betterWhen="down"
          caption="vs. last month"
          className="h-full"
        />
      </Grid>
    </GridContainer>
  );
}

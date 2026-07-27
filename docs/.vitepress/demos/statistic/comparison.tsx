import { Grid, GridContainer, Statistic } from 'neba';

/**
 * `betterWhen` is the whole reason the delta can be trusted. Both cards below
 * went *up*; only one of them is good news, and the colour has to say which.
 */
export default function StatisticComparison() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Statistic
          label="Signups"
          value={3120}
          previousValue={2740}
          caption="betterWhen up (the default)"
          className="h-full"
        />
      </Grid>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Statistic
          label="p95 latency"
          value={412}
          unit="ms"
          previousValue={366}
          betterWhen="down"
          caption="betterWhen down"
          className="h-full"
        />
      </Grid>

      <Grid span={{ xs: 12, sm: 6 }}>
        <Statistic
          label="Open incidents"
          value={7}
          previousValue={12}
          betterWhen="down"
          delta="absolute"
          caption='delta="absolute"'
          className="h-full"
        />
      </Grid>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Statistic
          label="Seats used"
          value={188}
          previousValue={160}
          delta="both"
          caption='delta="both"'
          className="h-full"
        />
      </Grid>
    </GridContainer>
  );
}

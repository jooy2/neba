import { Grid, GridContainer, Sparkline, Statistic } from 'neba';

const SIGNUPS = [18, 22, 19, 27, 24, 31, 29, 36, 34, 41, 38, 47];
const LATENCY = [188, 194, 181, 212, 240, 226, 208, 196, 231, 258, 244, 219];
const ERRORS = [4, 2, 6, 3, 1, 5, 2, 0, 3, 1, 2, 1];

export default function SparklineHero() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic label="Signups" value={47} previousValue={38} caption="Last 12 weeks">
          <Sparkline data={SIGNUPS} label="Signups, last 12 weeks" endDot />
        </Statistic>
      </Grid>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic
          label="p95 latency"
          value={219}
          unit="ms"
          previousValue={244}
          betterWhen="down"
          caption="Last 12 weeks"
        >
          <Sparkline data={LATENCY} label="p95 latency, last 12 weeks" color="info" endDot />
        </Statistic>
      </Grid>
      <Grid span={{ xs: 12, sm: 4 }}>
        <Statistic
          label="Errors"
          value={1}
          previousValue={2}
          betterWhen="down"
          caption="Last 12 weeks"
        >
          <Sparkline data={ERRORS} shape="bar" color="danger" label="Errors, last 12 weeks" />
        </Statistic>
      </Grid>
    </GridContainer>
  );
}

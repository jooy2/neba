import { Card, Grid, GridContainer, LineChart } from 'neba';

const HOURS = ['00', '04', '08', '12', '16', '20'];
const RATE = [12, 9, 34, 62, 48, 21];

/**
 * The same six readings, three ways. `step` is the honest one for a value that
 * was *set* rather than measured — a plan tier, a rate limit, a thermostat.
 */
export default function LineChartCurve() {
  return (
    <GridContainer spacing={3} padded={false}>
      {(['linear', 'smooth', 'step'] as const).map((curve) => (
        <Grid key={curve} span={{ xs: 12, md: 4 }}>
          <Card title={`curve="${curve}"`} size="sm" className="h-full">
            <LineChart
              label={`Requests per second, ${curve}`}
              size="sm"
              height={140}
              curve={curve}
              categories={HOURS}
              series={[{ name: 'Requests/s', data: RATE }]}
            />
          </Card>
        </Grid>
      ))}
    </GridContainer>
  );
}

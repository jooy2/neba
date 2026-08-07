import { Card, Grid, GridContainer, TimelineChart } from 'neba';

const on = (iso: string) => new Date(`${iso}T00:00:00`);

const TERMS = [
  {
    name: 'Alpha',
    data: [{ start: on('2026-01-05'), end: on('2026-03-30'), label: 'Alpha' }]
  },
  {
    name: 'Beta',
    data: [{ start: on('2026-03-16'), end: on('2026-06-08'), label: 'Beta' }]
  },
  {
    name: 'GA',
    data: [{ start: on('2026-05-25'), end: on('2026-08-31'), label: 'GA' }]
  }
];

export default function TimelineChartBars() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card title="barSize + rounded" size="sm" className="h-full">
          <TimelineChart label="Programme phases, thick bars" barSize={30} series={TERMS} />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 6 }}>
        <Card title='density="compact"' size="sm" className="h-full">
          <TimelineChart
            label="Programme phases, square ends"
            density="compact"
            rounded={false}
            series={TERMS}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

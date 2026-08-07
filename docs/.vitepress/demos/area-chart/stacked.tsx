import { AreaChart, Card, Grid, GridContainer } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const SERIES = [
  { name: 'Organic', data: [4200, 4610, 4880, 5240, 5390, 5720] },
  { name: 'Paid', data: [2100, 2480, 2310, 2760, 3020, 2880] },
  { name: 'Referral', data: [980, 1040, 1190, 1120, 1310, 1440] }
];

/**
 * The same three sources, three ways. Overlaid answers "how big is each";
 * stacked answers "how big is the total"; `'full'` answers "what is the mix",
 * and stops answering the first two.
 */
export default function AreaChartStacked() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="stacked={false}" size="sm" className="h-full">
          <AreaChart
            label="Sessions by source, overlaid"
            size="sm"
            height={160}
            categories={MONTHS}
            series={SERIES}
            legend={false}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title="stacked" size="sm" className="h-full">
          <AreaChart
            label="Sessions by source, stacked"
            size="sm"
            height={160}
            categories={MONTHS}
            series={SERIES}
            stacked
            legend={false}
          />
        </Card>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Card title='stacked="full"' size="sm" className="h-full">
          <AreaChart
            label="Sessions by source, as a share"
            size="sm"
            height={160}
            categories={MONTHS}
            series={SERIES}
            stacked="full"
            legend={false}
          />
        </Card>
      </Grid>
    </GridContainer>
  );
}

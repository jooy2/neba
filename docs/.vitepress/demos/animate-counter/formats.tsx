import { useState } from 'react';
import { AnimateCounter, Button, Grid, GridContainer, Statistic } from 'neba';

export default function AnimateCounterFormats() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex w-full flex-col gap-4">
      <Button variant="outline" size="sm" onClick={() => setRun((n) => n + 1)}>
        Count again
      </Button>

      <GridContainer key={run} spacing={3}>
        <Grid span={{ xs: 12, sm: 4 }}>
          <Statistic
            label="Revenue"
            value={
              <AnimateCounter
                value={48250}
                locale="en-US"
                format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
              />
            }
          />
        </Grid>
        <Grid span={{ xs: 12, sm: 4 }}>
          <Statistic
            label="Conversion"
            value={
              <AnimateCounter
                value={0.184}
                format={{ style: 'percent', maximumFractionDigits: 1 }}
              />
            }
          />
        </Grid>
        <Grid span={{ xs: 12, sm: 4 }}>
          <Statistic
            label="Tickets closed"
            value={<AnimateCounter value={1943} duration={2000} />}
          />
        </Grid>
      </GridContainer>
    </div>
  );
}

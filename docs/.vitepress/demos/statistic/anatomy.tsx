import { Grid, GridContainer, Icon, ProgressLinear, Statistic } from 'neba';

function UsersIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="6" cy="5.5" r="2.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M1.75 13c0-2.3 1.9-3.75 4.25-3.75S10.25 10.7 10.25 13"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M11 4.5a2 2 0 0 1 0 4M12 9.75c1.4.45 2.25 1.6 2.25 3.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * The slots, and what a Statistic looks like when it is asked to carry more than
 * a number: an icon on the label, a unit on the figure, and something of your
 * own underneath.
 */
export default function StatisticAnatomy() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Statistic
          icon={<Icon icon={<UsersIcon />} size="sm" />}
          label="Seats"
          value={188}
          unit="/ 250"
          caption="75% of the plan"
          className="h-full"
        >
          <ProgressLinear value={75} label="Seats used" />
        </Statistic>
      </Grid>

      <Grid span={{ xs: 12, sm: 3 }}>
        <Statistic
          label="Uptime"
          value="99.98%"
          align="center"
          variant="solid"
          color="success"
          className="h-full"
        />
      </Grid>

      <Grid span={{ xs: 12, sm: 3 }}>
        <Statistic
          label="Median build"
          value="3m 12s"
          align="center"
          variant="text"
          size="sm"
          className="h-full"
        />
      </Grid>
    </GridContainer>
  );
}

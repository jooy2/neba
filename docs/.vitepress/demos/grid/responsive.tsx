import { Box, Grid, GridContainer } from 'neba';

/** Resize the window: four rows, then two, then one. */
export default function GridResponsive() {
  return (
    <GridContainer spacing={2} padded={false}>
      {['Overview', 'Traffic', 'Revenue', 'Errors'].map((label) => (
        <Grid key={label} span={{ xs: 12, sm: 6, lg: 3 }}>
          <Box className="text-center">{label}</Box>
        </Grid>
      ))}
    </GridContainer>
  );
}

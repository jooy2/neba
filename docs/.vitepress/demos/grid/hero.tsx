import { Box, Grid, GridContainer } from 'neba';

export default function GridHero() {
  return (
    <GridContainer spacing={3} padded={false}>
      <Grid span={{ xs: 12, md: 8 }}>
        <Box variant="solid" className="h-full">
          span 8 from md — the main column
        </Box>
      </Grid>
      <Grid span={{ xs: 12, md: 4 }}>
        <Box variant="solid" className="h-full">
          span 4 — the aside
        </Box>
      </Grid>
      <Grid span={{ xs: 6, md: 3 }}>
        <Box>6 / 3</Box>
      </Grid>
      <Grid span={{ xs: 6, md: 3 }}>
        <Box>6 / 3</Box>
      </Grid>
      <Grid span={{ xs: 6, md: 3 }}>
        <Box>6 / 3</Box>
      </Grid>
      <Grid span={{ xs: 6, md: 3 }}>
        <Box>6 / 3</Box>
      </Grid>
    </GridContainer>
  );
}

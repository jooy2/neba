import { Box, Grid, GridContainer, Show } from 'neba';

export default function ShowTransparent() {
  return (
    <GridContainer spacing={2} padded={false} className="w-full">
      <Grid span={{ xs: 12, md: 8 }}>
        <Box variant="solid">The article</Box>
      </Grid>
      {/* Still a grid item: `Show` is `display: contents`, so it adds no box
          between the container and the cell. */}
      <Show above="md">
        <Grid span={4}>
          <Box>The aside, from md up</Box>
        </Grid>
      </Show>
    </GridContainer>
  );
}

import { Box, Grid, GridContainer } from 'neba';

/**
 * A grid inside a grid is a `GridContainer` inside a `Grid`, never a `Grid`
 * that is also a container. The inner grid re-divides the width its cell was
 * given, so `span={6}` in here is half of a half.
 */
export default function GridNested() {
  return (
    <GridContainer spacing={2} padded={false}>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Box padded={false} className="p-2">
          <GridContainer spacing={1} padded={false}>
            <Grid span={6}>
              <Box size="xs" variant="solid" className="text-center">
                6
              </Box>
            </Grid>
            <Grid span={6}>
              <Box size="xs" variant="solid" className="text-center">
                6
              </Box>
            </Grid>
            <Grid span={12}>
              <Box size="xs" variant="solid" className="text-center">
                12
              </Box>
            </Grid>
          </GridContainer>
        </Box>
      </Grid>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Box className="h-full">The other half, undivided</Box>
      </Grid>
    </GridContainer>
  );
}

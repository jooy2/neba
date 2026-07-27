import { Box, Grid, GridContainer } from 'neba';

export default function GridOffset() {
  return (
    <div className="flex flex-col gap-2">
      {/* The middle third: four columns in, four columns wide. */}
      <GridContainer padded={false}>
        <Grid span={4} offset={4}>
          <Box size="sm" className="text-center">
            span 4, offset 4
          </Box>
        </Grid>
      </GridContainer>

      {/* Pushed to the end of the row. */}
      <GridContainer padded={false}>
        <Grid span={3} offset={9}>
          <Box size="sm" className="text-center">
            span 3, offset 9
          </Box>
        </Grid>
      </GridContainer>

      {/* An offset is space pushed in ahead of the item, so the gap here is
          between the two cells rather than measured from the start of the row. */}
      <GridContainer padded={false}>
        <Grid span={3}>
          <Box size="sm" className="text-center">
            span 3
          </Box>
        </Grid>
        <Grid span={3} offset={3}>
          <Box size="sm" className="text-center">
            span 3, offset 3
          </Box>
        </Grid>
      </GridContainer>
    </div>
  );
}

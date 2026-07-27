import { Box, Grid, GridContainer } from 'neba';

export default function GridPadding() {
  return (
    <div className="flex flex-col gap-4">
      {/* The default: padded on the size scale, so the grid does not run into
          whatever is around it. */}
      <Box padded={false}>
        <GridContainer size="md">
          {[0, 1, 2].map((cell) => (
            <Grid key={cell} span={4}>
              <Box size="sm" variant="solid" className="text-center">
                padded
              </Box>
            </Grid>
          ))}
        </GridContainer>
      </Box>

      {/* Off, for a grid already inside something that pads — a Card, a
          Container, another grid. */}
      <Box padded={false}>
        <GridContainer padded={false}>
          {[0, 1, 2].map((cell) => (
            <Grid key={cell} span={4}>
              <Box size="sm" variant="solid" className="text-center">
                padded={'{false}'}
              </Box>
            </Grid>
          ))}
        </GridContainer>
      </Box>
    </div>
  );
}

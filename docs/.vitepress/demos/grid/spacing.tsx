import { Box, Grid, GridContainer } from 'neba';

export default function GridSpacing() {
  return (
    <div className="flex flex-col gap-6">
      {/* One number sets both gutters. Fractions are allowed. */}
      {[0, 1.5, 4].map((spacing) => (
        <GridContainer key={spacing} spacing={spacing} padded={false}>
          {[0, 1, 2, 3].map((cell) => (
            <Grid key={cell} span={3}>
              <Box size="sm" className="text-center">
                spacing {spacing}
              </Box>
            </Grid>
          ))}
        </GridContainer>
      ))}

      {/* Or one per axis: tight columns, generous rows. */}
      <GridContainer columnSpacing={1} rowSpacing={6} padded={false}>
        {[0, 1, 2, 3, 4, 5].map((cell) => (
          <Grid key={cell} span={4}>
            <Box size="sm" className="text-center">
              1 / 6
            </Box>
          </Grid>
        ))}
      </GridContainer>
    </div>
  );
}

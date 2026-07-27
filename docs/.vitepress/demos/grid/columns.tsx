import { Box, Grid, GridContainer } from 'neba';

export default function GridColumns() {
  return (
    <div className="flex flex-col gap-6">
      {/* Twelve does not divide by five. Fifteen does. */}
      <GridContainer columns={15} spacing={2} padded={false}>
        {[0, 1, 2, 3, 4].map((cell) => (
          <Grid key={cell} span={3}>
            <Box size="sm" className="text-center">
              3 / 15
            </Box>
          </Grid>
        ))}
      </GridContainer>

      {/* A finer grid for a layout that needs seven-eighths of a row. */}
      <GridContainer columns={24} spacing={2} padded={false}>
        <Grid span={21}>
          <Box size="sm" className="text-center">
            21 / 24
          </Box>
        </Grid>
        <Grid span={3}>
          <Box size="sm" className="text-center">
            3
          </Box>
        </Grid>
      </GridContainer>
    </div>
  );
}

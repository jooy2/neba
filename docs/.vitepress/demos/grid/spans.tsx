import { Box, Grid, GridContainer } from 'neba';

const ROWS = [[12], [6, 6], [4, 4, 4], [3, 3, 3, 3], [8, 4]];

export default function GridSpans() {
  return (
    <div className="flex flex-col gap-2">
      {ROWS.map((row, index) => (
        <GridContainer key={index} padded={false}>
          {row.map((span, cell) => (
            <Grid key={cell} span={span}>
              <Box size="sm" className="text-center">
                {span}
              </Box>
            </Grid>
          ))}
        </GridContainer>
      ))}
    </div>
  );
}

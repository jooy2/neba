import { Box, Grid, GridContainer } from 'neba';

export default function GridAlignment() {
  return (
    <div className="flex flex-col gap-6">
      {/* Three columns in a twelve-column row leave three spare. justifyContent
          decides where the slack goes — no sx, no className. */}
      {(['start', 'center', 'end', 'space-between'] as const).map((justify) => (
        <GridContainer key={justify} justifyContent={justify} padded={false}>
          {[0, 1, 2].map((cell) => (
            <Grid key={cell} span={3}>
              <Box size="sm" className="text-center">
                {justify}
              </Box>
            </Grid>
          ))}
        </GridContainer>
      ))}

      {/* Items are the same height as their row by default; alignItems opts out,
          and alignSelf lets one item disagree with the rest. */}
      <GridContainer alignItems="center" padded={false}>
        <Grid span={4}>
          <Box size="sm" className="h-20 text-center">
            tall
          </Box>
        </Grid>
        <Grid span={4}>
          <Box size="sm" className="text-center">
            centred
          </Box>
        </Grid>
        <Grid span={4} alignSelf="end">
          <Box size="sm" className="text-center">
            alignSelf end
          </Box>
        </Grid>
      </GridContainer>
    </div>
  );
}

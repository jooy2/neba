import { Avatar, Box, Button, Chip, Grid, GridContainer, Typography } from 'neba';

/**
 * The two widths a column count cannot reach: `auto` is as wide as what is in
 * the cell, and `grow` is that plus whatever the row has left over.
 */
export default function GridAutoGrow() {
  return (
    <div className="flex flex-col gap-3">
      <GridContainer spacing={2} padded={false} alignItems="center" wrap={false}>
        <Grid span="auto">
          <Avatar name="Rhea Patel" size="sm" />
        </Grid>
        <Grid span="grow" className="min-w-0">
          <Typography level="body" className="truncate">
            Rhea Patel opened a pull request
          </Typography>
        </Grid>
        <Grid span="auto">
          <Chip size="sm" color="success">
            Ready
          </Chip>
        </Grid>
        <Grid span="auto">
          <Button size="sm" variant="outline">
            Review
          </Button>
        </Grid>
      </GridContainer>

      {/* A keyword and a number in one map: the contents' width on a phone,
          a third of the row from 48rem up. */}
      <GridContainer spacing={2} padded={false}>
        <Grid span={{ xs: 'auto', md: 4 }}>
          <Box size="sm" className="text-center">
            auto, then 4
          </Box>
        </Grid>
        <Grid span={{ xs: 'grow', md: 8 }}>
          <Box size="sm" className="text-center">
            grow, then 8
          </Box>
        </Grid>
      </GridContainer>
    </div>
  );
}

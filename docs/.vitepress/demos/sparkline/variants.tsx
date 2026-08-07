import { Box, Grid, GridContainer, Sparkline, Typography } from 'neba';

const DATA = [32, 28, 41, 39, 52, 47, 61, 58, 72, 68, 81, 94];

const SHAPES = ['line', 'area', 'bar'] as const;

export default function SparklineVariants() {
  return (
    <GridContainer spacing={3} padded={false}>
      {SHAPES.map((shape) => (
        <Grid key={shape} span={{ xs: 12, sm: 4 }}>
          <Box className="flex h-full flex-col gap-2">
            <Typography level="overline">shape=&quot;{shape}&quot;</Typography>
            <Sparkline data={DATA} shape={shape} size="lg" label={`Example, ${shape}`} />
          </Box>
        </Grid>
      ))}

      <Grid span={{ xs: 12, sm: 6 }}>
        <Box className="flex h-full flex-col gap-2">
          <Typography level="overline">curve=&quot;smooth&quot; · endDot</Typography>
          <Sparkline data={DATA} curve="smooth" size="lg" endDot label="Example, smoothed" />
        </Box>
      </Grid>
      <Grid span={{ xs: 12, sm: 6 }}>
        <Box className="flex h-full flex-col gap-2">
          <Typography level="overline">
            baseline={'{'}60{'}'}
          </Typography>
          <Sparkline
            data={DATA}
            shape="area"
            size="lg"
            baseline={60}
            color="success"
            label="Example against a target of 60"
          />
        </Box>
      </Grid>
    </GridContainer>
  );
}

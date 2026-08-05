import { useState } from 'react';
import { AnimateFade, Box, Switch, Typography } from 'neba';

export default function AnimateFadeTriggers() {
  const [play, setPlay] = useState(false);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-wrap items-center justify-center gap-4">
        <AnimateFade trigger="hover" duration={400}>
          <Box size="sm">
            <Typography level="caption">Hover me</Typography>
          </Box>
        </AnimateFade>

        <AnimateFade trigger="visible" duration={600}>
          <Box size="sm">
            <Typography level="caption">On scrolling into view</Typography>
          </Box>
        </AnimateFade>
      </div>

      <Switch checked={play} onCheckedChange={setPlay} label="Play the manual one" size="sm" />

      <AnimateFade trigger="manual" play={play} duration={500}>
        <Box size="sm">
          <Typography level="caption">Driven by the switch</Typography>
        </Box>
      </AnimateFade>
    </div>
  );
}

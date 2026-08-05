import { AnimateLighting, Box, Typography } from 'neba';

const SHAPES = [
  { label: 'spark', arc: 20, spread: 3, blur: 3, duration: 1800 },
  { label: 'sweep', arc: 120, spread: 4, blur: 8, duration: 3200 },
  { label: 'halo', arc: 170, spread: 8, blur: 14, duration: 5000 }
];

export default function AnimateLightingShape() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-5">
      {SHAPES.map((shape) => (
        <AnimateLighting
          key={shape.label}
          arc={shape.arc}
          spread={shape.spread}
          blur={shape.blur}
          duration={shape.duration}
          size="md"
        >
          <Box size="md">
            <Typography level="caption">{shape.label}</Typography>
          </Box>
        </AnimateLighting>
      ))}
    </div>
  );
}

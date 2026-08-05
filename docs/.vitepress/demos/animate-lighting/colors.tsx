import { AnimateLighting, Box, Typography } from 'neba';

const FAMILIES = ['primary', 'success', 'warning', 'danger'] as const;

export default function AnimateLightingColors() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-4">
      {FAMILIES.map((color) => (
        <AnimateLighting key={color} color={color} size="md">
          <Box size="md">
            <Typography level="caption">{color}</Typography>
          </Box>
        </AnimateLighting>
      ))}
    </div>
  );
}

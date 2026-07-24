import { Box } from 'neba';

export default function BoxElevation() {
  return (
    <div className="flex flex-wrap items-start gap-5">
      {([0, 1, 2, 3] as const).map((elevation) => (
        <Box key={elevation} variant="solid" elevation={elevation}>
          elevation {elevation}
        </Box>
      ))}
    </div>
  );
}

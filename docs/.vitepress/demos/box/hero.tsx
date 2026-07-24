import { Box } from 'neba';

export default function BoxHero() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      <Box>The default — a hairline edge</Box>
      <Box variant="solid" color="info">
        solid, info
      </Box>
      <Box variant="text">text — it only groups</Box>
    </div>
  );
}

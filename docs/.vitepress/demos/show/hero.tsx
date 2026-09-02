import { Box, Show, Typography } from 'neba';

export default function ShowHero() {
  return (
    <div className="w-full max-w-2xl">
      <Show below="md">
        <Box variant="solid" color="secondary" className="w-full">
          <Typography level="body">Narrow — under 48rem. Resize the window.</Typography>
        </Box>
      </Show>
      <Show above="md">
        <Box variant="solid" className="w-full">
          <Typography level="body">Wide — 48rem and up. Resize the window.</Typography>
        </Box>
      </Show>
    </div>
  );
}

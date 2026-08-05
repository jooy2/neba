import { AnimateMarquee, Box, Typography } from 'neba';

const EVENTS = [
  'deploy · api · 12:04',
  'deploy · web · 12:07',
  'rollback · web · 12:09',
  'deploy · web · 12:15'
];

export default function AnimateMarqueeVertical() {
  return (
    <AnimateMarquee orientation="vertical" speed={30} gap="0.5rem" className="h-32 w-full max-w-56">
      {EVENTS.map((event) => (
        <Box key={event} size="sm" density="compact" className="w-full">
          <Typography level="caption" render={<span />}>
            {event}
          </Typography>
        </Box>
      ))}
    </AnimateMarquee>
  );
}

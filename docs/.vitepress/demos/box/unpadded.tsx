import { Box } from 'neba';

export default function BoxUnpadded() {
  return (
    <Box padded={false} render={<section />} className="w-full max-w-md overflow-hidden">
      <div className="h-20 bg-[var(--neba-primary-soft-press)]" />
      <div className="p-4 text-[0.8125rem]">
        The strip above touches all four edges, because the box is not padded.
      </div>
    </Box>
  );
}

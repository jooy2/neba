import { Spoiler, Typography } from 'neba';

export default function SpoilerInline() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Typography>
        A Spoiler with <code>variant="text"</code> draws no box at all, which is what a paragraph in
        the middle of a review usually wants:
      </Typography>

      <Spoiler variant="text" size="sm" description={false} padded={false}>
        <Typography>The butler did it, and the dog knew all along.</Typography>
      </Spoiler>

      <Spoiler variant="solid" size="lg" color="info">
        <Typography>And a filled sheet, for one that is meant to be a stop sign.</Typography>
      </Spoiler>
    </div>
  );
}

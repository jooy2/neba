import { Highlight, Typography } from 'neba';

/**
 * The children are walked into rather than required to be a string, which is
 * what makes a highlight survive the first search result that has markup in it.
 */
export default function HighlightNested() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <Highlight query="surface" color="primary">
        <Typography level="body">
          A <strong>surface</strong> is a sheet, and a <em>surface</em> that moves is a key. The{' '}
          <strong>surface</strong> keeps its edge either way.
        </Typography>
      </Highlight>
    </div>
  );
}

import { Pagination, Typography } from 'neba';

/**
 * `variant` is how the pages look *at rest*. The current page is always filled,
 * whatever the row's resting variant is — it is the one thing here that has to
 * be legible without being read.
 */
export default function PaginationVariants() {
  return (
    <div className="flex flex-col gap-5">
      {(['text', 'outline', 'solid'] as const).map((variant) => (
        <div key={variant} className="flex flex-col gap-1">
          <Typography level="caption">variant="{variant}"</Typography>
          <Pagination count={9} defaultPage={4} variant={variant} />
        </div>
      ))}
    </div>
  );
}

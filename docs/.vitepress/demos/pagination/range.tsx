import { Pagination, Typography } from 'neba';

/**
 * The window slides toward whichever end it is near rather than being clipped by
 * it, so the row keeps the same number of slots on every page. Which slots are
 * pages and which are ellipses changes; how many there are does not — otherwise
 * stepping from page 1 to page 2 would relayout the row and move every button
 * out from under the pointer that just pressed one.
 */
export default function PaginationRange() {
  return (
    <div className="flex flex-col gap-5">
      {[1, 2, 10, 19, 20].map((page) => (
        <div key={page} className="flex flex-col gap-1">
          <Typography level="caption">page={page}</Typography>
          <Pagination count={20} page={page} showArrows={false} />
        </div>
      ))}

      <div className="flex flex-col gap-1">
        <Typography level="caption">
          siblingCount={2} · boundaryCount={2}
        </Typography>
        <Pagination count={20} page={10} siblingCount={2} boundaryCount={2} showArrows={false} />
      </div>
    </div>
  );
}

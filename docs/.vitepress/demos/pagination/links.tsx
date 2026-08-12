import { useState } from 'react';
import { Pagination, Typography } from 'neba';

/**
 * The same row twice. Above, `getPageHref` alone: every number is an `<a href>`
 * and pressing one is a navigation, which is what a crawler follows and what a
 * middle-click opens in a new tab. Below, the same links with a handler behind
 * them — the press is cancelled and the page stays, which is the shape a
 * client-side router wants.
 */
export default function PaginationLinks() {
  const [page, setPage] = useState(3);

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-col gap-1">
        <Typography level="caption">getPageHref</Typography>
        <Pagination count={12} page={3} getPageHref={(value) => `/posts?page=${value}`} />
      </div>

      <div className="flex flex-col gap-1">
        <Typography level="caption">getPageHref + onPageChange</Typography>
        <Pagination
          count={12}
          page={page}
          getPageHref={(value) => `/posts?page=${value}`}
          onPageChange={setPage}
        />
      </div>
    </div>
  );
}

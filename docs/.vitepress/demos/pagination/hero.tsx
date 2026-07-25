import { useState } from 'react';
import { Pagination, Typography } from 'neba';

export default function PaginationHero() {
  const [page, setPage] = useState(7);

  return (
    <div className="flex flex-col items-center gap-3">
      <Pagination count={24} page={page} onPageChange={setPage} showEdges />
      <Typography level="caption">Showing 121–140 of 480</Typography>
    </div>
  );
}

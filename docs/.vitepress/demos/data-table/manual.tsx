import { useEffect, useState } from 'react';
import { DataTable, type DataTableColumn, type DataTableSort } from 'neba';

interface Event {
  id: number;
  actor: string;
  action: string;
  at: string;
}

const ACTIONS = ['deployed', 'reverted', 'invited', 'archived', 'renamed'];
const TOTAL = 842;

/** Stands in for the request a real table would make. */
function fetchPage(page: number, pageSize: number, sort: DataTableSort[]): Promise<Event[]> {
  const descending = sort[0]?.direction === 'desc';

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(
        Array.from({ length: pageSize }, (_, offset) => {
          const index = (page - 1) * pageSize + offset;
          const id = descending ? TOTAL - index : index + 1;

          return {
            id,
            actor: `svc-${String((id % 12) + 1).padStart(2, '0')}`,
            action: ACTIONS[id % ACTIONS.length],
            at: `2026-08-${String((id % 28) + 1).padStart(2, '0')}`
          };
        })
      );
    }, 120);
  });
}

const HEADERS: DataTableColumn<Event>[] = [
  { key: 'id', label: 'Event', width: 100, align: 'end' },
  { key: 'actor', label: 'Actor', width: 130 },
  { key: 'action', label: 'Action', sortable: false },
  { key: 'at', label: 'Date', width: 130, sortable: false }
];

export default function DataTableManual() {
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [sort, setSort] = useState<DataTableSort[]>([{ key: 'id', direction: 'desc' }]);
  const [rows, setRows] = useState<Event[]>([]);

  useEffect(() => {
    let live = true;

    fetchPage(page, pageSize, sort).then((next) => {
      if (live) setRows(next);
    });

    return () => {
      live = false;
    };
  }, [page, pageSize, sort]);

  return (
    <DataTable
      headers={HEADERS}
      items={rows}
      getRowKey={(row) => row.id}
      manual
      rowCount={TOTAL}
      paging="pages"
      page={page}
      onPageChange={setPage}
      pageSize={pageSize}
      onPageSizeChange={setPageSize}
      sortable
      sort={sort}
      onSortChange={setSort}
      striped
    />
  );
}

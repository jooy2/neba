import { useState } from 'react';
import { Chip, DataTable, type DataTableColumn } from 'neba';

interface Build {
  id: number;
  branch: string;
  status: 'passed' | 'running' | 'failed';
  duration: number;
  queued: string;
}

const BRANCHES = ['main', 'release/2.4', 'feat/acrylic', 'fix/sticky-header', 'chore/deps'];
const STATUSES: Build['status'][] = ['passed', 'running', 'failed'];

const ITEMS: Build[] = Array.from({ length: 20_000 }, (_, index) => ({
  id: 91_000 - index,
  branch: BRANCHES[index % BRANCHES.length],
  status: STATUSES[index % 3],
  duration: 40 + ((index * 37) % 900),
  queued: `${String((index % 24) + 1).padStart(2, '0')}:${String((index * 7) % 60).padStart(2, '0')}`
}));

const HEADERS: DataTableColumn<Build>[] = [
  { key: 'id', label: 'Build', width: 90, align: 'end' },
  { key: 'branch', label: 'Branch', width: 180 },
  {
    key: 'status',
    label: 'Status',
    width: 120,
    render: (row) => (
      <Chip
        size="xs"
        variant="text"
        color={row.status === 'passed' ? 'success' : row.status === 'failed' ? 'danger' : 'info'}
      >
        {row.status}
      </Chip>
    )
  },
  {
    key: 'duration',
    label: 'Duration',
    width: 110,
    align: 'end',
    render: (row) => `${Math.floor(row.duration / 60)}m ${row.duration % 60}s`
  },
  { key: 'queued', label: 'Queued', width: 100, align: 'end' }
];

export default function DataTableHero() {
  const [selected, setSelected] = useState<React.Key[]>([]);

  return (
    <div className="flex w-full flex-col gap-2">
      <DataTable
        headers={HEADERS}
        items={ITEMS}
        getRowKey={(row) => row.id}
        height={280}
        selectionMode="multiple"
        selected={selected}
        onSelectedChange={setSelected}
        sortable
        resizable
        striped
      />
      <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">
        20,000 rows. Click a row, drag through a run of them, or hold Shift and press the arrow
        keys.
      </span>
    </div>
  );
}

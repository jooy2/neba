import { useState } from 'react';
import { DataTable, type DataTableColumn, type DataTableSort } from 'neba';

interface Ticket {
  id: string;
  title: string;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  points: number;
}

const RANK: Ticket['priority'][] = ['low', 'normal', 'high', 'urgent'];

const ITEMS: Ticket[] = [
  { id: 'NB-12', title: 'Sticky header loses its blur', priority: 'high', points: 3 },
  { id: 'NB-31', title: 'Chip count wraps at 100', priority: 'low', points: 3 },
  { id: 'NB-04', title: 'Focus ring clipped in a cell', priority: 'urgent', points: 8 },
  { id: 'NB-27', title: 'Locale ignored by the footer', priority: 'normal', points: 1 },
  { id: 'NB-19', title: 'Drag selection skips a row', priority: 'urgent', points: 5 },
  { id: 'NB-08', title: 'Column widths reset on filter', priority: 'high', points: 8 }
];

const HEADERS: DataTableColumn<Ticket>[] = [
  { key: 'id', label: 'Key', width: 90 },
  { key: 'title', label: 'Summary', sortable: false },
  {
    key: 'priority',
    label: 'Priority',
    width: 120,
    // Alphabetically `urgent` is last; by rank it is first.
    compare: (a, b) => RANK.indexOf(a.priority) - RANK.indexOf(b.priority)
  },
  { key: 'points', label: 'Points', width: 100, align: 'end' }
];

export default function DataTableSorting() {
  const [sort, setSort] = useState<DataTableSort[]>([{ key: 'priority', direction: 'desc' }]);

  return (
    <div className="flex w-full flex-col gap-2">
      <DataTable
        headers={HEADERS}
        items={ITEMS}
        getRowKey={(row) => row.id}
        sortable
        sortMode="multiple"
        sort={sort}
        onSortChange={setSort}
      />
      <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">
        {sort.length === 0
          ? 'Unsorted. Click a heading; Shift-click a second one to add it.'
          : sort.map((entry) => `${entry.key} ${entry.direction}`).join(', then ')}
      </span>
    </div>
  );
}

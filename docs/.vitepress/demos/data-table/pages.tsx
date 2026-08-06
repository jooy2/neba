import { DataTable, type DataTableColumn } from 'neba';

interface Entry {
  id: number;
  account: string;
  memo: string;
  amount: number;
}

const MEMOS = ['Subscription', 'Refund', 'Top-up', 'Chargeback', 'Payout'];

const ITEMS: Entry[] = Array.from({ length: 137 }, (_, index) => ({
  id: 4100 + index,
  account: `ACC-${String(((index * 17) % 60) + 100)}`,
  memo: MEMOS[index % MEMOS.length],
  amount: Math.round((((index * 733) % 90_000) - 30_000) / 100) * 100
}));

const HEADERS: DataTableColumn<Entry>[] = [
  { key: 'index', label: '#', width: 70, align: 'end', render: (_row, index) => index + 1 },
  { key: 'id', label: 'Entry', width: 100, align: 'end' },
  { key: 'account', label: 'Account', width: 130 },
  { key: 'memo', label: 'Memo' },
  {
    key: 'amount',
    label: 'Amount',
    width: 130,
    align: 'end',
    render: (row) => (
      <span className={row.amount < 0 ? 'text-[var(--neba-danger-accent)]' : undefined}>
        {row.amount.toLocaleString('en-US', { style: 'currency', currency: 'USD' })}
      </span>
    )
  }
];

export default function DataTablePages() {
  return (
    <DataTable
      headers={HEADERS}
      items={ITEMS}
      getRowKey={(row) => row.id}
      paging="pages"
      defaultPageSize={10}
      pageSizeOptions={[10, 25, 50]}
      sortable
      striped
    />
  );
}

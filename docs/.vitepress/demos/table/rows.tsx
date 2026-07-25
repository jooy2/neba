import { useState } from 'react';
import { Table, type TableColumn } from 'neba';

interface Member {
  email: string;
  role: string;
}

const HEADERS: TableColumn<Member>[] = [
  { key: 'email', label: 'Member' },
  { key: 'role', label: 'Role', width: 140, align: 'end' }
];

const ITEMS: Member[] = [
  { email: 'jane@example.com', role: 'Owner' },
  { email: 'sam@example.com', role: 'Admin' },
  { email: 'kim@example.com', role: 'Member' },
  { email: 'lee@example.com', role: 'Member' }
];

export default function TableRows() {
  const [picked, setPicked] = useState<string | null>(null);

  return (
    <div className="flex flex-col gap-3">
      <Table
        headers={HEADERS}
        items={ITEMS}
        getRowKey={(row) => row.email}
        striped
        size="sm"
        onRowClick={(row) => setPicked(row.email)}
      />
      <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">
        {picked ? `Selected ${picked}` : 'Click a row.'}
      </span>
    </div>
  );
}

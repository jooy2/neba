import { useState } from 'react';
import { Button, DataTable, Shortcut, type DataTableColumn } from 'neba';

interface Asset {
  path: string;
  kind: string;
  size: number;
}

const KINDS = ['image/png', 'image/svg+xml', 'font/woff2', 'text/css', 'video/mp4'];

const ITEMS: Asset[] = Array.from({ length: 600 }, (_, index) => ({
  path: `assets/${KINDS[index % KINDS.length].split('/')[0]}/file-${String(index).padStart(3, '0')}`,
  kind: KINDS[index % KINDS.length],
  size: 1024 + ((index * 971) % 4_000_000)
}));

const HEADERS: DataTableColumn<Asset>[] = [
  { key: 'path', label: 'Path' },
  { key: 'kind', label: 'Type', width: 150 },
  {
    key: 'size',
    label: 'Size',
    width: 110,
    align: 'end',
    render: (row) => `${(row.size / 1024).toFixed(0)} KB`
  }
];

export default function DataTableSelection() {
  const [selected, setSelected] = useState<React.Key[]>([]);
  const [opened, setOpened] = useState<string | null>(null);

  return (
    <div className="flex w-full flex-col gap-3">
      <DataTable
        headers={HEADERS}
        items={ITEMS}
        getRowKey={(row) => row.path}
        height={240}
        selectionMode="multiple"
        checkboxes
        selected={selected}
        onSelectedChange={setSelected}
        onRowActivate={(row) => setOpened(row.path)}
      />

      <div className="flex flex-wrap items-center gap-3 text-[0.75rem] text-[var(--neba-muted-fg)]">
        <Button
          size="xs"
          variant="text"
          disabled={selected.length === 0}
          onClick={() => setSelected([])}
        >
          Clear {selected.length} selected
        </Button>
        <span>
          <Shortcut keys={['Shift', '↑']} size="xs" /> extends ·{' '}
          <Shortcut keys={['Mod', 'A']} size="xs" /> takes everything ·{' '}
          <Shortcut keys={['Enter']} size="xs" /> opens
        </span>
        {opened ? <span>Opened {opened}</span> : null}
      </div>
    </div>
  );
}

import { useState } from 'react';
import { DataTable, Segment, SegmentedButton, type DataTableColumn } from 'neba';

interface Reading {
  id: number;
  sensor: string;
  celsius: number;
  taken: string;
}

const ITEMS: Reading[] = Array.from({ length: 100_000 }, (_, index) => ({
  id: index + 1,
  sensor: `S-${String((index % 400) + 1).padStart(4, '0')}`,
  celsius: Math.round((18 + ((index * 13) % 170) / 10) * 10) / 10,
  taken: `2026-0${(index % 9) + 1}-${String((index % 28) + 1).padStart(2, '0')}`
}));

const HEADERS: DataTableColumn<Reading>[] = [
  { key: 'id', label: '#', width: 90, align: 'end' },
  { key: 'sensor', label: 'Sensor', width: 130 },
  { key: 'celsius', label: '°C', width: 90, align: 'end' },
  { key: 'taken', label: 'Taken', width: 140 }
];

export default function DataTableVirtual() {
  const [virtual, setVirtual] = useState(true);

  return (
    <div className="flex w-full flex-col gap-3">
      <SegmentedButton
        size="sm"
        value={virtual ? 'on' : 'off'}
        onValueChange={(value) => setVirtual(value === 'on')}
      >
        <Segment value="on">virtual</Segment>
        <Segment value="off">every row</Segment>
      </SegmentedButton>

      <DataTable
        headers={HEADERS}
        items={virtual ? ITEMS : ITEMS.slice(0, 2000)}
        getRowKey={(row) => row.id}
        height={260}
        virtual={virtual}
        striped
      />

      <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">
        {virtual
          ? '100,000 rows, about thirty of them in the DOM.'
          : '2,000 rows, all of them in the DOM — and that is already as far as this goes.'}
      </span>
    </div>
  );
}

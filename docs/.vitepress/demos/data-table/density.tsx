import { useState } from 'react';
import { DataTable, Segment, SegmentedButton, type DataTableColumn, type NebaSize } from 'neba';

interface Job {
  id: number;
  queue: string;
  attempts: number;
  state: string;
}

const STATES = ['queued', 'running', 'done', 'retrying'];

const ITEMS: Job[] = Array.from({ length: 8 }, (_, index) => ({
  id: 700 + index,
  queue: index % 2 === 0 ? 'default' : 'mailers',
  attempts: (index % 3) + 1,
  state: STATES[index % STATES.length]
}));

const HEADERS: DataTableColumn<Job>[] = [
  { key: 'id', label: 'Job', width: 90, align: 'end' },
  { key: 'queue', label: 'Queue', width: 140 },
  { key: 'attempts', label: 'Tries', width: 90, align: 'end' },
  { key: 'state', label: 'State' }
];

export default function DataTableDensity() {
  const [size, setSize] = useState<NebaSize>('sm');
  const [compact, setCompact] = useState(true);

  return (
    <div className="flex w-full flex-col gap-3">
      <div className="flex flex-wrap gap-2">
        <SegmentedButton
          size="xs"
          value={size}
          onValueChange={(value) => setSize(value as NebaSize)}
        >
          <Segment value="xs">xs</Segment>
          <Segment value="sm">sm</Segment>
          <Segment value="md">md</Segment>
          <Segment value="lg">lg</Segment>
        </SegmentedButton>

        <SegmentedButton
          size="xs"
          value={compact ? 'compact' : 'default'}
          onValueChange={(value) => setCompact(value === 'compact')}
        >
          <Segment value="compact">compact</Segment>
          <Segment value="default">default</Segment>
        </SegmentedButton>
      </div>

      <DataTable
        headers={HEADERS}
        items={ITEMS}
        getRowKey={(row) => row.id}
        size={size}
        density={compact ? 'compact' : 'default'}
        striped
      />
    </div>
  );
}

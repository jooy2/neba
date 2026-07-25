import { Chip, Table, type TableColumn } from 'neba';

interface Deploy {
  id: string;
  environment: string;
  status: 'Live' | 'Building' | 'Failed';
  duration: number;
}

const HEADERS: TableColumn<Deploy>[] = [
  { key: 'environment', label: 'Environment', width: 180 },
  {
    key: 'status',
    label: 'Status',
    width: 140,
    render: (row) => (
      <Chip
        size="xs"
        variant="text"
        color={row.status === 'Live' ? 'success' : row.status === 'Failed' ? 'danger' : 'info'}
      >
        {row.status}
      </Chip>
    )
  },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}m` }
];

const ITEMS: Deploy[] = [
  { id: '1', environment: 'production', status: 'Live', duration: 4 },
  { id: '2', environment: 'staging', status: 'Building', duration: 2 },
  { id: '3', environment: 'preview/1284', status: 'Failed', duration: 1 }
];

export default function TableHero() {
  return <Table headers={HEADERS} items={ITEMS} getRowKey={(row) => row.id} hoverable />;
}

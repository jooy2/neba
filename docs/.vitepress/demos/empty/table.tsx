import { Button, Empty, Table, type TableColumn } from 'neba';

interface Deploy {
  id: string;
  environment: string;
  status: string;
}

const HEADERS: TableColumn<Deploy>[] = [
  { key: 'environment', label: 'Environment', width: 200 },
  { key: 'status', label: 'Status' }
];

export default function EmptyTable() {
  return (
    <Table
      headers={HEADERS}
      items={[]}
      getRowKey={(row) => row.id}
      empty={
        <Empty
          density="compact"
          title="No deploys yet"
          action={<Button size="sm">Deploy the main branch</Button>}
        >
          Every deploy and its outcome will be listed here.
        </Empty>
      }
    />
  );
}

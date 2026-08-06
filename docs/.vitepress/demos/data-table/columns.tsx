import { DataTable, type DataTableColumn } from 'neba';

interface Region {
  code: string;
  city: string;
  latency: number;
  uptime: number;
  nodes: number;
}

const HEADERS: DataTableColumn<Region>[] = [
  { key: 'code', label: 'Code', width: 90 },
  { key: 'city', label: 'City', width: 160 },
  {
    key: 'latency',
    label: 'p95',
    group: 'Last 24 hours',
    width: 100,
    align: 'end',
    render: (row) => `${row.latency} ms`
  },
  {
    key: 'uptime',
    label: 'Uptime',
    group: 'Last 24 hours',
    width: 110,
    align: 'end',
    render: (row) => `${row.uptime.toFixed(2)}%`
  },
  { key: 'nodes', label: 'Nodes', group: 'Capacity', width: 100, align: 'end' }
];

const ITEMS: Region[] = [
  { code: 'icn1', city: 'Seoul', latency: 38, uptime: 99.99, nodes: 24 },
  { code: 'fra1', city: 'Frankfurt', latency: 61, uptime: 99.94, nodes: 40 },
  { code: 'iad1', city: 'Washington', latency: 44, uptime: 100, nodes: 36 },
  { code: 'gru1', city: 'São Paulo', latency: 112, uptime: 99.81, nodes: 12 }
];

export default function DataTableColumns() {
  return <DataTable headers={HEADERS} items={ITEMS} getRowKey={(row) => row.code} resizable />;
}

import { Table, type TableColumn } from 'neba';

interface Invoice {
  number: string;
  total: string;
}

const HEADERS: TableColumn<Invoice>[] = [
  { key: 'number', label: 'Invoice' },
  { key: 'total', label: 'Total', align: 'end' }
];

export default function TableEmpty() {
  return (
    <Table
      headers={HEADERS}
      items={[]}
      caption="Invoices"
      empty="No invoices yet — the first one arrives after your trial."
    />
  );
}

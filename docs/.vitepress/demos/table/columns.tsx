import { Table, type TableColumn } from 'neba';

interface Row {
  sku: string;
  name: string;
  stock: number;
  price: number;
}

const HEADERS: TableColumn<Row>[] = [
  { key: 'sku', label: 'SKU', width: 110 },
  { key: 'name', label: 'Product' },
  { key: 'stock', label: 'In stock', width: 100, align: 'center' },
  {
    key: 'price',
    label: 'Price',
    width: 120,
    align: 'end',
    render: (row) => `$${row.price.toFixed(2)}`
  }
];

const ITEMS: Row[] = [
  { sku: 'NB-001', name: 'Acrylic sheet, 3mm', stock: 42, price: 18.5 },
  { sku: 'NB-014', name: 'Edge polish kit', stock: 7, price: 64 },
  { sku: 'NB-090', name: 'Frosting spray', stock: 0, price: 9.99 }
];

export default function TableColumns() {
  return <Table headers={HEADERS} items={ITEMS} getRowKey={(row) => row.sku} />;
}

import { useState } from 'react';
import { Button, Chip, DataTable, type DataTableColumn } from 'neba';

interface Package {
  name: string;
  version: string;
  licence: string;
  size: number;
  outdated: boolean;
}

const ITEMS: Package[] = [
  { name: '@base-ui/react', version: '1.2.0', licence: 'MIT', size: 412, outdated: false },
  { name: 'react', version: '19.1.0', licence: 'MIT', size: 132, outdated: false },
  { name: 'react-dom', version: '19.1.0', licence: 'MIT', size: 1_040, outdated: false },
  { name: 'tailwindcss', version: '4.0.3', licence: 'MIT', size: 380, outdated: true },
  { name: 'vitepress', version: '1.6.1', licence: 'MIT', size: 2_180, outdated: true },
  { name: 'vitest', version: '4.1.10', licence: 'MIT', size: 1_460, outdated: false },
  { name: 'terser', version: '5.36.0', licence: 'BSD-2-Clause', size: 940, outdated: true },
  { name: 'typescript', version: '5.7.2', licence: 'Apache-2.0', size: 22_100, outdated: false }
];

const HEADERS: DataTableColumn<Package>[] = [
  { key: 'name', label: 'Package' },
  { key: 'version', label: 'Version', width: 110 },
  { key: 'licence', label: 'Licence', width: 130 },
  {
    key: 'size',
    label: 'Install size',
    width: 130,
    align: 'end',
    render: (row) => `${(row.size / 1024).toFixed(1)} MB`
  },
  {
    key: 'outdated',
    label: 'State',
    width: 110,
    // `searchable: false` keeps `true` and `false` out of the query, which
    // would otherwise make "true" match half the table.
    searchable: false,
    render: (row) =>
      row.outdated ? (
        <Chip size="xs" variant="text" color="warning">
          outdated
        </Chip>
      ) : null
  }
];

export default function DataTableSearch() {
  const [onlyOutdated, setOnlyOutdated] = useState(false);

  return (
    <DataTable
      headers={HEADERS}
      items={ITEMS}
      getRowKey={(row) => row.name}
      sortable
      searchable
      searchPlaceholder="Filter packages"
      filter={onlyOutdated ? (row) => row.outdated : undefined}
      toolbar={
        <Button
          size="sm"
          variant={onlyOutdated ? 'solid' : 'text'}
          color="warning"
          onClick={() => setOnlyOutdated((value) => !value)}
        >
          Outdated only
        </Button>
      }
      empty="No package matches."
    />
  );
}

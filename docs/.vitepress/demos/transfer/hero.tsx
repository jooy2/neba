import { useState } from 'react';
import { Transfer } from 'neba';

const COLUMNS = [
  { value: 'status', label: 'Status' },
  { value: 'duration', label: 'Duration' },
  { value: 'commit', label: 'Commit' },
  { value: 'author', label: 'Author' },
  { value: 'branch', label: 'Branch' },
  { value: 'region', label: 'Region' },
  { value: 'runtime', label: 'Runtime' },
  { value: 'id', label: 'Deployment id', disabled: true }
];

export default function TransferHero() {
  const [shown, setShown] = useState<readonly string[]>(['status', 'duration', 'commit']);

  return (
    <Transfer
      className="max-w-2xl"
      items={COLUMNS}
      value={shown}
      onValueChange={setShown}
      sourceLabel="Hidden columns"
      targetLabel="Shown columns"
    />
  );
}

import { Select } from 'neba';

const REGIONS = [
  { value: 'icn', label: 'Seoul' },
  { value: 'nrt', label: 'Tokyo' },
  { value: 'fra', label: 'Frankfurt' },
  { value: 'iad', label: 'Washington DC' },
  { value: 'gru', label: 'São Paulo', disabled: true }
];

export default function SelectHero() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <Select items={REGIONS} label="Region" placeholder="Pick a region" defaultValue="icn" />
      <Select items={REGIONS} label="Failover" placeholder="None" />
    </div>
  );
}

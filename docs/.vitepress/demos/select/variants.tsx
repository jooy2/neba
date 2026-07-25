import { Select } from 'neba';

const ITEMS = [
  { value: 'sans', label: 'Sans-serif' },
  { value: 'serif', label: 'Serif' },
  { value: 'mono', label: 'Monospace' }
];

export default function SelectVariants() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <Select items={ITEMS} variant="solid" label="Solid" defaultValue="sans" />
      <Select items={ITEMS} variant="outline" label="Outline" defaultValue="sans" />
      <Select items={ITEMS} variant="text" label="Text" defaultValue="sans" />
    </div>
  );
}

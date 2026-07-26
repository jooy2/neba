import { Combobox } from 'neba';

const ITEMS = [
  { value: 'sans', label: 'Sans-serif' },
  { value: 'serif', label: 'Serif' },
  { value: 'mono', label: 'Monospace' }
];

export default function ComboboxVariants() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <Combobox items={ITEMS} variant="solid" label="Solid" defaultValue="sans" />
      <Combobox items={ITEMS} variant="outline" label="Outline" defaultValue="sans" />
      <Combobox items={ITEMS} variant="text" label="Text" defaultValue="sans" />
    </div>
  );
}

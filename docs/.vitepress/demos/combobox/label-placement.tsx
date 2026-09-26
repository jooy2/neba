import { Combobox } from 'neba';

const FRAMEWORKS = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'svelte', label: 'Svelte' },
  { value: 'solid', label: 'Solid' }
];

export default function ComboboxLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <Combobox
        items={FRAMEWORKS}
        labelPlacement="notch"
        label="Notch"
        placeholder="Search frameworks"
      />
      <Combobox
        items={FRAMEWORKS}
        labelPlacement="float"
        label="Float"
        placeholder="Search frameworks"
      />
      <Combobox
        multiple
        items={FRAMEWORKS}
        labelPlacement="float"
        label="Also used"
        placeholder="Add a few"
      />
    </div>
  );
}

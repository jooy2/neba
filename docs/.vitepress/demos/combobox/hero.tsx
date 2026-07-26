import { Combobox } from 'neba';

const FRAMEWORKS = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'svelte', label: 'Svelte' },
  { value: 'solid', label: 'Solid' },
  { value: 'angular', label: 'Angular' },
  { value: 'ember', label: 'Ember', disabled: true }
];

export default function ComboboxHero() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <Combobox
        items={FRAMEWORKS}
        label="Framework"
        placeholder="Search or type your own"
        clearable
      />
      <Combobox
        multiple
        items={FRAMEWORKS}
        label="Also used"
        placeholder="Add a few"
        defaultValue={['react', 'svelte']}
      />
    </div>
  );
}

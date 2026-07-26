import { Combobox } from 'neba';

const ITEMS = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' }
];

export default function ComboboxStates() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <Combobox items={ITEMS} label="Read-only" readOnly defaultValue="team" />
      <Combobox items={ITEMS} label="Disabled" disabled defaultValue="team" />
      <Combobox items={ITEMS} label="Plan" placeholder="Pick one" error="Choose a plan." />
      <Combobox
        multiple
        items={ITEMS}
        label="Read-only tags"
        readOnly
        defaultValue={['starter', 'team']}
      />
    </div>
  );
}

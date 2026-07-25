import { Select } from 'neba';

const ITEMS = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' }
];

export default function SelectStates() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <Select items={ITEMS} label="Read-only" readOnly defaultValue="team" />
      <Select items={ITEMS} label="Disabled" disabled defaultValue="team" />
      <Select items={ITEMS} label="Plan" placeholder="Pick one" error="Choose a plan." />
      <Select
        items={ITEMS}
        label="With help"
        description="Billed monthly."
        defaultValue="starter"
      />
    </div>
  );
}

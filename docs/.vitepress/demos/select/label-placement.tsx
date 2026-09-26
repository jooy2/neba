import { Select } from 'neba';

const PLANS = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' },
  { value: 'enterprise', label: 'Enterprise' }
];

export default function SelectLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <Select items={PLANS} label="Top" placeholder="Pick a plan" />
      <Select items={PLANS} labelPlacement="notch" label="Notch" placeholder="Pick a plan" />
      <Select items={PLANS} labelPlacement="float" label="Float" placeholder="Pick a plan" />
    </div>
  );
}

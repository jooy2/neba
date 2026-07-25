import { Checkbox } from 'neba';

export default function CheckboxStates() {
  return (
    <div className="flex flex-col gap-3">
      <Checkbox label="Unchecked" />
      <Checkbox label="Checked" defaultChecked />
      <Checkbox label="Read-only" readOnly defaultChecked />
      <Checkbox label="Disabled" disabled />
      <Checkbox label="Disabled and checked" disabled defaultChecked />
      <Checkbox label="I agree to the terms" error="You have to agree to continue." />
    </div>
  );
}

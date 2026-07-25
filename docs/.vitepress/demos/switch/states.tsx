import { Switch } from 'neba';

export default function SwitchStates() {
  return (
    <div className="flex flex-col gap-3">
      <Switch label="Off" />
      <Switch label="On" defaultChecked />
      <Switch label="Read-only" readOnly defaultChecked />
      <Switch label="Disabled" disabled />
      <Switch label="Disabled and on" disabled defaultChecked />
    </div>
  );
}

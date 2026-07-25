import { Switch } from 'neba';

export default function SwitchPlacement() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <Switch
        labelPlacement="start"
        label="Two-factor authentication"
        description="Required for admins."
        defaultChecked
      />
      <Switch labelPlacement="start" label="Session timeout" description="After 30 minutes." />
    </div>
  );
}

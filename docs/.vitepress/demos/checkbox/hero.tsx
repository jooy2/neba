import { Checkbox } from 'neba';

export default function CheckboxHero() {
  return (
    <div className="flex flex-col gap-3">
      <Checkbox label="Remember me" defaultChecked />
      <Checkbox label="Send me product updates" description="About once a month. No newsletters." />
      <Checkbox label="Delete after export" color="danger" />
      <Checkbox label="Managed by your workspace" disabled defaultChecked />
    </div>
  );
}

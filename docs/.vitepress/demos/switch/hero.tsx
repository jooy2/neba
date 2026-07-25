import { Switch } from 'neba';

export default function SwitchHero() {
  return (
    <div className="flex flex-col gap-3">
      <Switch label="Email alerts" defaultChecked />
      <Switch label="Preview deployments" description="Builds every pull request." />
      <Switch label="Maintenance mode" color="warning" />
      <Switch label="Enforced by your workspace" disabled defaultChecked />
    </div>
  );
}

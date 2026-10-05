import { Radio, RadioGroup } from 'neba';

export default function RadioGroupSpacing() {
  return (
    <RadioGroup label="Plan" defaultValue="team" spacing={4}>
      <Radio value="starter" label="Starter" description="One project, community support." />
      <Radio value="team" label="Team" description="Up to twelve seats." />
      <Radio value="enterprise" label="Enterprise" description="SSO and an uptime agreement." />
    </RadioGroup>
  );
}

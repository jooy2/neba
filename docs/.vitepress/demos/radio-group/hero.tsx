import { Radio, RadioGroup } from 'neba';

export default function RadioGroupHero() {
  return (
    <RadioGroup label="Plan" defaultValue="team">
      <Radio value="starter" label="Starter" />
      <Radio value="team" label="Team" />
      <Radio value="enterprise" label="Enterprise" />
    </RadioGroup>
  );
}

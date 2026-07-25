import { Radio, RadioGroup } from 'neba';

export default function RadioGroupStates() {
  return (
    <div className="flex flex-wrap gap-10">
      <RadioGroup label="One option is out of reach" defaultValue="starter">
        <Radio value="starter" label="Starter" />
        <Radio value="team" label="Team" />
        <Radio value="enterprise" label="Enterprise" disabled />
      </RadioGroup>

      <RadioGroup label="The whole set is read-only" readOnly defaultValue="team">
        <Radio value="starter" label="Starter" />
        <Radio value="team" label="Team" />
      </RadioGroup>

      <RadioGroup label="Plan" error="Choose a plan to continue.">
        <Radio value="starter" label="Starter" />
        <Radio value="team" label="Team" />
      </RadioGroup>
    </div>
  );
}

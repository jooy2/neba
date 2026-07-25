import { Radio, RadioGroup } from 'neba';

export default function RadioGroupDescriptions() {
  return (
    <RadioGroup
      label="Deploy target"
      description="You can change this later."
      defaultValue="preview"
    >
      <Radio value="preview" label="Preview" description="A throwaway URL per pull request." />
      <Radio value="staging" label="Staging" description="Shared, and reset every night." />
      <Radio value="production" label="Production" description="Live. Requires an approval." />
    </RadioGroup>
  );
}

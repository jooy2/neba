import { Radio, RadioGroup } from 'neba';

export default function RadioGroupOrientation() {
  return (
    <RadioGroup label="Billing period" orientation="horizontal" defaultValue="yearly">
      <Radio value="monthly" label="Monthly" />
      <Radio value="yearly" label="Yearly" />
      <Radio value="once" label="One-off" />
    </RadioGroup>
  );
}

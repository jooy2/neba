import { Card, Fieldset, Select, TextField } from 'neba';

const COUNTRIES = [
  { value: 'kr', label: 'South Korea' },
  { value: 'jp', label: 'Japan' },
  { value: 'us', label: 'United States' }
];

export default function FieldsetHero() {
  return (
    <Card className="w-full max-w-sm" title="Checkout">
      <Fieldset legend="Billing address" description="Where the card statement goes.">
        <TextField label="Street" name="street" />
        <TextField label="City" name="city" />
        <Select label="Country" name="country" items={COUNTRIES} placeholder="Choose one" />
      </Fieldset>
    </Card>
  );
}

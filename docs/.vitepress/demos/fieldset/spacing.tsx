import { Fieldset, Select, TextField } from 'neba';

export default function FieldsetSpacing() {
  return (
    <Fieldset legend="Shipping address" spacing={6} className="w-full max-w-sm">
      <TextField label="Street" name="street" />
      <TextField label="City" name="city" />
      <Select
        label="Country"
        name="country"
        placeholder="Choose one"
        items={[
          { value: 'kr', label: 'South Korea' },
          { value: 'jp', label: 'Japan' }
        ]}
      />
    </Fieldset>
  );
}

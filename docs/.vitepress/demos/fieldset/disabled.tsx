import { useState } from 'react';
import { Checkbox, Fieldset, TextField } from 'neba';

export default function FieldsetDisabled() {
  const [custom, setCustom] = useState(false);

  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <Checkbox label="Ship to a different address" checked={custom} onCheckedChange={setCustom} />
      <Fieldset legend="Delivery address" disabled={!custom}>
        <TextField label="Street" name="ship-street" />
        <TextField label="City" name="ship-city" />
      </Fieldset>
    </div>
  );
}

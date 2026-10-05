import { Checkbox, Fieldset } from 'neba';

export default function FieldsetSpacing() {
  return (
    <Fieldset legend="Email me about" spacing={2}>
      <Checkbox label="Failed deploys" defaultChecked />
      <Checkbox label="New members" />
      <Checkbox label="The weekly digest" defaultChecked />
    </Fieldset>
  );
}

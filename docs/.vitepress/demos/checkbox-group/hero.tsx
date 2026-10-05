import { Checkbox, CheckboxGroup } from 'neba';

export default function CheckboxGroupHero() {
  return (
    <CheckboxGroup label="Email me about" defaultValue={['deploys', 'digest']}>
      <Checkbox value="deploys" label="Failed deploys" />
      <Checkbox value="members" label="New members" />
      <Checkbox value="digest" label="The weekly digest" />
    </CheckboxGroup>
  );
}

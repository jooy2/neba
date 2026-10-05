import { Checkbox, CheckboxGroup } from 'neba';

export default function CheckboxGroupSpacing() {
  return (
    <CheckboxGroup label="Show in the sidebar" spacing={4} defaultValue={['activity']}>
      <Checkbox value="activity" label="Activity" description="Deploys, comments and reviews." />
      <Checkbox value="usage" label="Usage" description="Requests and bandwidth this month." />
      <Checkbox value="billing" label="Billing" description="The next invoice and its total." />
    </CheckboxGroup>
  );
}

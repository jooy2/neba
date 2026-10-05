import { Checkbox, CheckboxGroup } from 'neba';

export default function CheckboxGroupOrientation() {
  return (
    <CheckboxGroup label="Days" orientation="horizontal" defaultValue={['mon', 'wed', 'fri']}>
      <Checkbox value="mon" label="Mon" />
      <Checkbox value="tue" label="Tue" />
      <Checkbox value="wed" label="Wed" />
      <Checkbox value="thu" label="Thu" />
      <Checkbox value="fri" label="Fri" />
    </CheckboxGroup>
  );
}

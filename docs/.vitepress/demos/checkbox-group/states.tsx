import { Checkbox, CheckboxGroup } from 'neba';

export default function CheckboxGroupStates() {
  return (
    <div className="flex flex-wrap gap-10">
      <CheckboxGroup label="One option is out of reach" defaultValue={['web']}>
        <Checkbox value="web" label="Web" />
        <Checkbox value="ios" label="iOS" />
        <Checkbox value="android" label="Android" disabled />
      </CheckboxGroup>

      <CheckboxGroup label="The whole set is read-only" readOnly defaultValue={['web', 'ios']}>
        <Checkbox value="web" label="Web" />
        <Checkbox value="ios" label="iOS" />
      </CheckboxGroup>

      <CheckboxGroup label="Platforms" error="Choose at least one platform.">
        <Checkbox value="web" label="Web" />
        <Checkbox value="ios" label="iOS" />
      </CheckboxGroup>
    </div>
  );
}

import { Toggle, ToggleGroup } from 'neba';

export default function ToggleGroupOrientation() {
  return (
    <ToggleGroup orientation="vertical" aria-label="Density" defaultValue={['cosy']}>
      <Toggle value="compact">Compact</Toggle>
      <Toggle value="cosy">Cosy</Toggle>
      <Toggle value="roomy">Roomy</Toggle>
    </ToggleGroup>
  );
}

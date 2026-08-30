import { Toggle, ToggleGroup } from 'neba';

export default function ToggleGroupHero() {
  return (
    <div className="flex flex-col items-center gap-5">
      <ToggleGroup aria-label="Text alignment" defaultValue={['left']}>
        <Toggle value="left">Left</Toggle>
        <Toggle value="center">Center</Toggle>
        <Toggle value="right">Right</Toggle>
      </ToggleGroup>

      <ToggleGroup multiple aria-label="Marks" defaultValue={['bold', 'underline']}>
        <Toggle value="bold">Bold</Toggle>
        <Toggle value="italic">Italic</Toggle>
        <Toggle value="underline">Underline</Toggle>
      </ToggleGroup>
    </div>
  );
}

import { useState } from 'react';
import { Toggle, ToggleGroup } from 'neba';

export default function ToggleGroupMultiple() {
  const [marks, setMarks] = useState<readonly string[]>(['bold']);

  return (
    <div className="flex flex-col items-center gap-4">
      <ToggleGroup multiple aria-label="Marks" value={marks} onValueChange={setMarks}>
        <Toggle value="bold">Bold</Toggle>
        <Toggle value="italic">Italic</Toggle>
        <Toggle value="underline">Underline</Toggle>
      </ToggleGroup>

      <p className="text-[0.75rem] text-(--neba-muted-fg)">
        {marks.length > 0 ? marks.join(', ') : 'none'}
      </p>
    </div>
  );
}

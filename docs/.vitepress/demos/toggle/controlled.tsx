import { useState } from 'react';
import { Toggle } from 'neba';

export default function ToggleControlled() {
  const [grid, setGrid] = useState(true);

  return (
    <div className="flex flex-col items-center gap-4">
      <Toggle pressed={grid} onPressedChange={setGrid}>
        Grid
      </Toggle>

      <div
        className="size-40 rounded-(--neba-radius-md) border border-(--neba-line)"
        style={{
          backgroundImage: grid
            ? 'linear-gradient(var(--neba-line) 1px, transparent 1px), linear-gradient(90deg, var(--neba-line) 1px, transparent 1px)'
            : undefined,
          backgroundSize: '16px 16px'
        }}
      />
    </div>
  );
}

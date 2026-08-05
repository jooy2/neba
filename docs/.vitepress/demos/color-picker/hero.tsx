import { useState } from 'react';
import { ColorPicker } from 'neba';

export default function ColorPickerHero() {
  const [color, setColor] = useState('#1a58d1');

  return (
    <div className="flex items-center gap-3">
      <ColorPicker value={color} onValueChange={setColor} />
      <span
        className="size-8 rounded-lg border border-[var(--neba-border)]"
        style={{ backgroundColor: color }}
      />
    </div>
  );
}

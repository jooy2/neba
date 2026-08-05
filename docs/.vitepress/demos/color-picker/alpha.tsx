import { useState } from 'react';
import { ColorPicker, Typography } from 'neba';

export default function ColorPickerAlpha() {
  const [color, setColor] = useState('rgba(217, 70, 239, 0.65)');

  return (
    <div className="flex flex-col items-center gap-3">
      <ColorPicker alpha format="rgb" value={color} onValueChange={setColor} />
      <Typography level="caption">{color}</Typography>
    </div>
  );
}

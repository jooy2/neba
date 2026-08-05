import { useState } from 'react';
import { ColorPicker, Segment, SegmentedButton, Typography } from 'neba';

const FORMATS = ['hex', 'rgb', 'hsl'] as const;

export default function ColorPickerFormat() {
  const [format, setFormat] = useState<(typeof FORMATS)[number]>('hex');
  const [color, setColor] = useState('#f97316');

  return (
    <div className="flex flex-col items-center gap-3">
      <SegmentedButton
        value={format}
        onValueChange={(next) => setFormat(next as (typeof FORMATS)[number])}
        size="sm"
      >
        {FORMATS.map((name) => (
          <Segment key={name} value={name}>
            {name}
          </Segment>
        ))}
      </SegmentedButton>

      <ColorPicker format={format} value={color} onValueChange={setColor} />

      <Typography level="caption">{color}</Typography>
    </div>
  );
}

import { ColorPicker } from 'neba';

/* The colours a product actually uses, one press away. */
const BRAND = ['#0f172a', '#1a58d1', '#0891b2', '#16a34a', '#ca8a04', '#dc2626'];

export default function ColorPickerSwatches() {
  return (
    <div className="flex flex-wrap items-start justify-center gap-6">
      <ColorPicker inline size="sm" swatches={BRAND} defaultValue="#1a58d1" editable={false} />
      <ColorPicker inline size="sm" swatches={false} defaultValue="#dc2626" />
    </div>
  );
}

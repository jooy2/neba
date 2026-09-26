import { ColorPicker } from 'neba';

export default function ColorPickerLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <ColorPicker label="Top" defaultValue="#8b5cf6" />
      <ColorPicker labelPlacement="notch" label="Notch" defaultValue="#8b5cf6" />
    </div>
  );
}

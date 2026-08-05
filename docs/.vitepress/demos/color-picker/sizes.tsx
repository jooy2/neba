import { ColorPicker } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ColorPickerSizes() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {SIZES.map((size) => (
        <ColorPicker key={size} size={size} defaultValue="#06b6d4" />
      ))}
    </div>
  );
}

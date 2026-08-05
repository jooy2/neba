import { ColorPicker } from 'neba';

export default function ColorPickerField() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      <ColorPicker
        label="Label colour"
        description="Shown on the project card and in the calendar."
        name="labelColour"
        clearable
        fullWidth
        defaultValue="#8b5cf6"
      />

      <ColorPicker
        label="Brand colour"
        error="This colour fails contrast against white."
        defaultValue="#fef08a"
        fullWidth
      />
    </div>
  );
}

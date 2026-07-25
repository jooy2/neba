import { FilePicker } from 'neba';

export default function FilePickerVariants() {
  return (
    <div className="grid w-full grid-cols-1 gap-4 lg:grid-cols-3">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <FilePicker key={variant} variant={variant} size="sm" title={variant} hint="Any file" />
      ))}
    </div>
  );
}

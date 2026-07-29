import { OtpField } from 'neba';

export default function OtpFieldSizes() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <OtpField key={size} size={size} length={4} label={size} defaultValue="42" />
      ))}
    </div>
  );
}

import { Meter } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function MeterSizes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {sizes.map((size) => (
        <Meter key={size} size={size} value={62} label={size} showValue />
      ))}
    </div>
  );
}

import { ProgressLinear, type NebaSize } from 'neba';

const SIZES: NebaSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

export default function ProgressLinearSizes() {
  return (
    <div className="flex w-full max-w-96 flex-col gap-4">
      {SIZES.map((size) => (
        <ProgressLinear key={size} size={size} value={45} label={size} showValue />
      ))}
    </div>
  );
}

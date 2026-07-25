import { ProgressCircular, type NebaSize } from 'neba';

const SIZES: NebaSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

export default function ProgressCircularSizes() {
  return (
    <div className="flex flex-wrap items-center gap-5">
      {SIZES.map((size) => (
        <ProgressCircular key={size} size={size} value={60} showValue />
      ))}
    </div>
  );
}

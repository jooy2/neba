import { Skeleton } from 'neba';

export default function SkeletonLines() {
  return (
    <div className="flex w-full max-w-96 flex-col gap-6">
      <Skeleton size="sm" lines={2} />
      <Skeleton lines={4} />
      <Skeleton size="lg" lines={3} />
    </div>
  );
}

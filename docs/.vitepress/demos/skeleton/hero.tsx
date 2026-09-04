import { Card, Skeleton } from 'neba';

export default function SkeletonHero() {
  return (
    <Card className="w-full max-w-96">
      {/* A card's body is one block of copy, so the rows it holds bring their
          own rhythm. */}
      <div className="flex flex-col gap-4">
        <div className="flex items-center gap-3">
          <Skeleton shape="circle" size="lg" />
          <div className="flex flex-1 flex-col gap-2">
            <Skeleton width="45%" />
            <Skeleton size="sm" width="30%" />
          </div>
        </div>
        <Skeleton shape="rect" height={120} />
        <Skeleton lines={3} />
      </div>
    </Card>
  );
}

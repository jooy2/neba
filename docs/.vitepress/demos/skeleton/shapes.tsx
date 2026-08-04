import { Skeleton } from 'neba';

export default function SkeletonShapes() {
  return (
    <div className="flex w-full max-w-96 flex-col gap-5">
      <div className="flex flex-col gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">line</span>
        <Skeleton />
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">rect</span>
        <Skeleton shape="rect" />
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">circle</span>
        <Skeleton shape="circle" size="xl" />
      </div>
    </div>
  );
}

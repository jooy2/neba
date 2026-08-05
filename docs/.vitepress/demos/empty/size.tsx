import { Empty } from 'neba';

export default function EmptySize() {
  return (
    <div className="flex w-full flex-col gap-4">
      <Empty variant="outline" size="sm" title="sm" />
      <Empty variant="outline" size="md" title="md" />
      <Empty variant="outline" size="lg" title="lg" />
      <Empty variant="outline" size="lg" density="compact" title="lg, compact" />
    </div>
  );
}

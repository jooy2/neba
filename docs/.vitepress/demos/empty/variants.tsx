import { Empty } from 'neba';

export default function EmptyVariants() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      <Empty variant="text" title="text" />
      <Empty variant="outline" title="outline" />
      <Empty variant="solid" title="solid" />
    </div>
  );
}

import { Empty } from 'neba';

export default function EmptyTitle() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      <Empty variant="outline" />

      <Empty variant="outline" title="No invoices">
        Nothing has been billed to this account yet.
      </Empty>

      <Empty variant="outline" title={false}>
        Nothing matched that filter.
      </Empty>
    </div>
  );
}

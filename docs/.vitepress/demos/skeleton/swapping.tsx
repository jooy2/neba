import { useState } from 'react';
import { Button, Card, Skeleton, Statistic } from 'neba';

export default function SkeletonSwapping() {
  const [loading, setLoading] = useState(true);

  return (
    <div className="flex w-full max-w-96 flex-col gap-3">
      <Card>
        {loading ? (
          <Skeleton shape="rect" height={64} label="Loading this month's usage" />
        ) : (
          <Statistic label="Requests this month" value={1284910} previousValue={1142380} />
        )}
      </Card>

      <Button size="sm" variant="outline" onClick={() => setLoading((value) => !value)}>
        {loading ? 'Finish loading' : 'Load again'}
      </Button>
    </div>
  );
}

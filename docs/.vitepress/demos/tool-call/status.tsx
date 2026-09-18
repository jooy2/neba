import { useEffect, useState } from 'react';
import { Button, ToolCall, type NebaRunStatus } from 'neba';

const ORDER: NebaRunStatus[] = ['pending', 'running', 'success', 'error'];

export default function ToolCallStatus() {
  const [index, setIndex] = useState(0);
  const status = ORDER[index];

  // The clock is the point of `running`: with no `duration` the header counts
  // its own seconds, and stops the moment one is handed to it.
  useEffect(() => {
    if (status !== 'running') {
      return undefined;
    }

    const id = setTimeout(() => setIndex(2), 3200);

    return () => clearTimeout(id);
  }, [status]);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <ToolCall
        name="index_repository"
        status={status}
        duration={status === 'success' ? 3180 : undefined}
        result={status === 'success' ? '1,204 files indexed' : undefined}
        error={status === 'error' ? 'Repository is not readable' : undefined}
      />
      <div className="flex flex-wrap gap-2">
        {ORDER.map((name, at) => (
          <Button
            key={name}
            size="sm"
            variant={name === status ? 'solid' : 'outline'}
            onClick={() => setIndex(at)}
          >
            {name}
          </Button>
        ))}
      </div>
    </div>
  );
}

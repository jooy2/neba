import { useState } from 'react';
import { Button, Chip, Popover, PopoverClose, Select, TextField } from 'neba';

export default function PopoverForm() {
  const [status, setStatus] = useState('failed');
  const [query, setQuery] = useState('');

  return (
    <div className="flex flex-wrap items-center gap-3">
      <Popover
        width={300}
        trigger={<Button variant="outline">Filter deploys</Button>}
        title="Filter"
        description="Applied to the table behind this popup."
      >
        <div className="flex flex-col gap-3">
          <TextField
            size="sm"
            label="Commit"
            placeholder="8f2c1a"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />
          <Select
            size="sm"
            label="Status"
            value={status}
            onValueChange={(value) => setStatus(String(value))}
            items={[
              { value: 'all', label: 'Any status' },
              { value: 'ready', label: 'Ready' },
              { value: 'building', label: 'Building' },
              { value: 'failed', label: 'Failed' }
            ]}
          />
          <div className="flex justify-end gap-2">
            <PopoverClose
              render={
                <Button size="sm" variant="text" color="secondary">
                  Cancel
                </Button>
              }
            />
            <PopoverClose render={<Button size="sm">Apply</Button>} />
          </div>
        </div>
      </Popover>

      <Chip size="sm" variant="outline" color="secondary">
        status: {status}
      </Chip>
    </div>
  );
}

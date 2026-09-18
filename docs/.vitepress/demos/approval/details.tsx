import { useState } from 'react';
import { Approval, NumberField, TextField } from 'neba';

export default function ApprovalDetails() {
  const [to, setTo] = useState('team@example.com');
  const [limit, setLimit] = useState<number | null>(50);

  return (
    <div className="w-full max-w-lg">
      <Approval
        risk="medium"
        title="Send the digest?"
        description="Check the recipient before this goes out."
        options={[
          { value: 'send', label: 'Send', variant: 'solid' },
          { value: 'deny', label: 'Not now' }
        ]}
        details={
          <div className="flex flex-col gap-3">
            <TextField
              size="sm"
              fullWidth
              label="To"
              value={to}
              onChange={(event) => setTo(event.target.value)}
            />
            <NumberField size="sm" label="Rows" value={limit} onValueChange={setLimit} min={1} />
          </div>
        }
      />
    </div>
  );
}

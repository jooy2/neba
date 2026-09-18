import { useState } from 'react';
import { Approval, Button } from 'neba';

const OPTIONS = [
  { value: 'once', label: 'Allow once' },
  { value: 'always', label: 'Always allow' },
  { value: 'deny', label: 'Deny', color: 'danger' as const }
];

export default function ApprovalDecision() {
  const [decision, setDecision] = useState<string | null>(null);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Approval
        risk="medium"
        title="Send an email?"
        details={'to: team@example.com\nsubject: Weekly summary'}
        options={OPTIONS}
        decision={decision}
        onDecide={setDecision}
      />
      <div className="flex items-center gap-2">
        <Button size="sm" variant="outline" onClick={() => setDecision(null)}>
          Ask again
        </Button>
        <span className="text-[0.8125rem] text-[var(--vp-c-text-2)]">
          {decision === null ? 'Waiting for an answer' : `Sent back: ${decision}`}
        </span>
      </div>
    </div>
  );
}

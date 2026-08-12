import { useState } from 'react';
import { FloatingAction, FloatingActionButton, Segment, SegmentedButton } from 'neba';

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4.25" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

const corners = ['top-start', 'top-end', 'bottom-start', 'bottom-end'] as const;

export default function FloatingActionButtonCorners() {
  const [corner, setCorner] = useState<string | number | null>('bottom-end');

  return (
    <div className="flex w-full max-w-sm flex-col items-center gap-4">
      <SegmentedButton size="sm" aria-label="Corner" value={corner} onValueChange={setCorner}>
        {corners.map((value) => (
          <Segment key={value} value={value}>
            {value}
          </Segment>
        ))}
      </SegmentedButton>

      <div className="relative h-56 w-full overflow-hidden rounded-(--neba-radius-md) border [border-color:var(--neba-border)]">
        <FloatingActionButton
          position="absolute"
          corner={(corner ?? 'bottom-end') as (typeof corners)[number]}
          offset={12}
          icon={<PlusIcon />}
          label="Add"
        >
          <FloatingAction icon={<DotIcon />} label="Task" />
          <FloatingAction icon={<DotIcon />} label="Note" />
        </FloatingActionButton>
      </div>
    </div>
  );
}

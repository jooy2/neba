import { useState } from 'react';
import { Pill, Typography } from 'neba';

function PlaneIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M2 8.5 14 3l-3.5 10-2.2-4.2L2 8.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The compact/expanded pair, which is the whole idea being borrowed. The pill
 * grows into its second half by animating a measured height — nothing is
 * transformed, so no text is ever resampled on the way.
 */
export default function PillExpandable() {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="flex flex-col items-start gap-3">
      <Pill
        startIcon={<PlaneIcon />}
        color="info"
        title="KE081 → ICN"
        description="Boards in 25 minutes"
        expanded={expanded}
        onClick={() => setExpanded(!expanded)}
        details={
          <div className="flex flex-col gap-1">
            <Typography level="caption">Gate B14 · seat 12A</Typography>
            <Typography level="caption">On time</Typography>
          </div>
        }
      />

      <Typography level="caption">Press the pill.</Typography>
    </div>
  );
}

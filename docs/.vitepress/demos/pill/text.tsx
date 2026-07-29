import { Pill } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

/**
 * A title alone keeps the row one line tall, so the lozenge stays a stadium.
 * Adding a description grows it into a rounded rectangle with the same corner.
 */
export default function PillText() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <Pill startIcon={<DotIcon />} color="success" title="All systems normal" />

      <Pill
        startIcon={<DotIcon />}
        color="warning"
        title="Degraded"
        description="EU-west is slow"
      />
    </div>
  );
}

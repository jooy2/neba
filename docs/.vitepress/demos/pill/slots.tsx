import { IconButton, Pill } from 'neba';

function PauseIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M6 3.5v9M10 3.5v9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

/**
 * The leading slot takes an image as readily as a glyph — it is a square box
 * clipped to a circle, and the image fills and crops it. The trailing slot is
 * outside the pressable area, so a control can live there.
 */
export default function PillSlots() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <Pill
        variant="outline"
        color="primary"
        startIcon={<img src="/logo-32.png" alt="" />}
        title="Neba UI"
        description="1.0.0 published"
      />

      <Pill
        color="info"
        title="Deploying"
        description="build 8f2c1a"
        endIcon={
          <IconButton icon={<PauseIcon />} label="Pause" size="xs" variant="text" color="info" />
        }
      />
    </div>
  );
}

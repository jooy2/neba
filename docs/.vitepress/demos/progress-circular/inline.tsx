import { Button, Chip, ProgressCircular, TextField } from 'neba';

/**
 * The ring lands just under the control height at every step, so it drops into
 * a row of controls without making the row taller than it was.
 */
export default function ProgressCircularInline() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <TextField size="sm" placeholder="Search" endIcon={<ProgressCircular size="xs" />} />
      <Chip
        size="sm"
        variant="text"
        color="info"
        startIcon={<ProgressCircular size="xs" color="info" />}
      >
        Building
      </Chip>
      <Button size="sm" variant="outline" startIcon={<ProgressCircular size="xs" />}>
        Syncing
      </Button>
    </div>
  );
}

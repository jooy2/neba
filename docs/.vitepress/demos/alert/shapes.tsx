import { Alert } from 'neba';

export default function AlertShapes() {
  return (
    <div className="flex w-full flex-col gap-3">
      {/* A bare line: no glyph, nothing but the sentence. */}
      <Alert icon={false}>Scheduled maintenance on Sunday at 02:00 UTC.</Alert>

      {/* The default: a glyph and a line. */}
      <Alert color="info">Scheduled maintenance on Sunday at 02:00 UTC.</Alert>

      {/* A headline with the detail under it. */}
      <Alert color="info" title="Scheduled maintenance">
        The API will be read-only on Sunday between 02:00 and 03:00 UTC.
      </Alert>
    </div>
  );
}

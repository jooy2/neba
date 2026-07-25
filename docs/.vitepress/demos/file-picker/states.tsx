import { FilePicker } from 'neba';

const SAMPLE = [new File(['x'.repeat(24_000)], 'design-spec.pdf', { type: 'application/pdf' })];

export default function FilePickerStates() {
  return (
    <div className="grid w-full grid-cols-1 gap-4 lg:grid-cols-2">
      <FilePicker
        size="sm"
        label="Required"
        required
        error="Pick a file before saving."
        title="Nothing here yet"
      />

      <FilePicker size="sm" label="Read-only" readOnly defaultValue={SAMPLE} title="Locked" />

      <FilePicker size="sm" label="Disabled" disabled title="Unavailable" />

      <FilePicker
        size="sm"
        label="No picture, no list"
        icon={null}
        showList={false}
        defaultValue={SAMPLE}
        title="Just the sentence"
        hint="icon={null} · showList={false}"
      />
    </div>
  );
}

import { useState } from 'react';
import { Combobox } from 'neba';

const LABELS = [
  { value: 'bug', label: 'bug' },
  { value: 'docs', label: 'documentation' },
  { value: 'dx', label: 'developer experience' },
  { value: 'good-first', label: 'good first issue' },
  { value: 'perf', label: 'performance' }
];

export default function ComboboxMultiple() {
  const [labels, setLabels] = useState<(string | number)[]>(['bug']);

  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <Combobox
        multiple
        fullWidth
        items={LABELS}
        label="Labels"
        placeholder="Add a label"
        description="Type something the list does not have and the last row offers it."
        value={labels}
        onValueChange={setLabels}
      />
      <p className="text-xs text-(--neba-muted-fg)">
        {labels.length > 0 ? labels.join(', ') : 'nothing chosen'}
      </p>
    </div>
  );
}

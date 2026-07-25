import { useState } from 'react';
import { Chip } from 'neba';

const ALL = ['bug', 'docs', 'good first issue', 'help wanted'];

export default function ChipInteractive() {
  const [selected, setSelected] = useState<string[]>(['bug']);
  const [tags, setTags] = useState(['react', 'tailwind', 'base-ui']);

  const toggle = (label: string) =>
    setSelected((current) =>
      current.includes(label) ? current.filter((item) => item !== label) : [...current, label]
    );

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-center gap-2">
        {ALL.map((label) => (
          <Chip
            key={label}
            selected={selected.includes(label)}
            onClick={() => toggle(label)}
            deleteLabel={`Remove ${label}`}
          >
            {label}
          </Chip>
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {tags.map((tag) => (
          <Chip
            key={tag}
            variant="text"
            color="secondary"
            onDelete={() => setTags(tags.filter((item) => item !== tag))}
            deleteLabel={`Remove ${tag}`}
          >
            {tag}
          </Chip>
        ))}
        {tags.length === 0 ? (
          <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">No tags left.</span>
        ) : null}
      </div>
    </div>
  );
}

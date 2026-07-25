import { Chip } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" aria-hidden="true">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

export default function ChipHero() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Chip>design-system</Chip>
      <Chip variant="solid" color="success" startIcon={<DotIcon />}>
        Live
      </Chip>
      <Chip color="danger" count={12}>
        Errors
      </Chip>
      <Chip variant="text" onDelete={() => {}}>
        typescript
      </Chip>
    </div>
  );
}

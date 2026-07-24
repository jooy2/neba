import { Button } from 'neba';

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function ChevronIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m6 4 4 4-4 4"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function ButtonIcons() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button startIcon={<PlusIcon />}>New project</Button>
      <Button variant="outline" endIcon={<ChevronIcon />}>
        Continue
      </Button>
      <Button variant="outline" aria-label="Add" startIcon={<PlusIcon />} />
    </div>
  );
}

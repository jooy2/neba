import { IconButton } from 'neba';

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function TrashIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M3 4.5h10M6.5 4.5V3h3v1.5M4.5 4.5l.5 8h6l.5-8"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function StarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m8 2 1.8 3.9 4.2.5-3.1 2.9.8 4.2L8 11.4 4.3 13.5l.8-4.2L2 6.4l4.2-.5L8 2Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function IconButtonHero() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <IconButton icon={<PlusIcon />} label="Add item" />
      <IconButton icon={<StarIcon />} label="Star" variant="outline" />
      <IconButton icon={<TrashIcon />} label="Delete" variant="text" color="danger" />
    </div>
  );
}

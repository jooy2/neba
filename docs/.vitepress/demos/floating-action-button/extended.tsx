import { FloatingActionButton } from 'neba';

function PencilIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M11 2.5 13.5 5 6 12.5l-3.25.75L3.5 10 11 2.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function FloatingActionButtonExtended() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-4">
      <FloatingActionButton position="static" icon={<PencilIcon />} label="Compose" extended />
      <FloatingActionButton
        position="static"
        icon={<PencilIcon />}
        label="Compose"
        extended
        variant="outline"
      />
      <FloatingActionButton position="static" icon={<PencilIcon />} label="Compose" />
    </div>
  );
}

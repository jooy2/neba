import { FloatingActionButton, Typography } from 'neba';

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

export default function FloatingActionButtonHero() {
  return (
    <div className="relative h-48 w-full max-w-sm overflow-hidden rounded-(--neba-radius-md) border [border-color:var(--neba-border)] p-4">
      <Typography level="caption" className="text-(--neba-muted-fg)">
        A region with one action floating over it.
      </Typography>

      <FloatingActionButton
        position="absolute"
        icon={<PencilIcon />}
        label="Compose"
        onClick={() => {}}
      />
    </div>
  );
}

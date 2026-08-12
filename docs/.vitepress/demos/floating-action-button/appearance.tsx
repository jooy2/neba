import { FloatingActionButton, Typography } from 'neba';

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

export default function FloatingActionButtonAppearance() {
  return (
    <div className="flex flex-col items-center gap-5">
      <div className="flex flex-wrap items-center justify-center gap-4">
        {(['sm', 'md', 'lg', 'xl'] as const).map((size) => (
          <FloatingActionButton
            key={size}
            position="static"
            size={size}
            icon={<PlusIcon />}
            label={`Add, ${size}`}
          />
        ))}
      </div>

      <div className="flex flex-wrap items-center justify-center gap-4">
        <FloatingActionButton position="static" icon={<PlusIcon />} label="Add" variant="outline" />
        <FloatingActionButton
          position="static"
          icon={<PlusIcon />}
          label="Add"
          color="success"
          elevation={3}
        />
        <FloatingActionButton position="static" icon={<PlusIcon />} label="Add" disabled />
      </div>

      <Typography level="caption" className="text-(--neba-muted-fg)">
        size defaults to lg, elevation to 2
      </Typography>
    </div>
  );
}

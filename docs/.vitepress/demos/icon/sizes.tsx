import { Icon, Typography } from 'neba';

function BellIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M4 6.5a4 4 0 0 1 8 0c0 3 1 4 1 4H3s1-1 1-4Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M6.5 13a1.5 1.5 0 0 0 3 0" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function IconSizes() {
  return (
    <div className="flex flex-wrap items-end gap-6">
      {SIZES.map((size) => (
        <div key={size} className="flex flex-col items-center gap-2">
          <Icon icon={<BellIcon />} size={size} label={`Notifications, ${size}`} />
          <Typography level="caption">{size}</Typography>
        </div>
      ))}
    </div>
  );
}

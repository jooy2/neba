import { Icon, Typography } from 'neba';

/** Whatever your icon set hands back — here, a drawing of our own. */
function BoltIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M9 1.5 3.5 9.25H7.5L7 14.5 12.5 6.75H8.5L9 1.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function IconHero() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <Icon icon={<BoltIcon />} size="xl" color="warning" label="Fast" />
      <Typography level="body">
        Deploys finish in <Icon icon={<BoltIcon />} color="warning" /> under a minute.
      </Typography>
    </div>
  );
}

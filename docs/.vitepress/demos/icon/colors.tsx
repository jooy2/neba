import { Button, Icon, Typography } from 'neba';

function CheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m3.5 8.5 3 3 6-6"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

/**
 * `color` defaults to `inherit`, which is why the icon inside the button comes
 * out white without being told to. Naming a family opts out of that.
 */
export default function IconColors() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center gap-4">
        {COLORS.map((color) => (
          <Icon key={color} icon={<CheckIcon />} color={color} size="lg" label={color} />
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <Button startIcon={<Icon icon={<CheckIcon />} size="sm" />}>Approve</Button>
        <Button
          variant="outline"
          color="danger"
          startIcon={<Icon icon={<CheckIcon />} size="sm" />}
        >
          Reject
        </Button>
        <Typography level="caption">Both icons inherit; neither was given a colour.</Typography>
      </div>
    </div>
  );
}

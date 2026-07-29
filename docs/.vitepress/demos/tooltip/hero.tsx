import { Button, Chip, Tooltip } from 'neba';

function LinkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.5 9.5a2.5 2.5 0 0 0 3.54 0l2-2a2.5 2.5 0 0 0-3.54-3.54l-.5.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 6.5a2.5 2.5 0 0 0-3.54 0l-2 2a2.5 2.5 0 0 0 3.54 3.54l.5-.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function TooltipHero() {
  return (
    // `delay={0}` so the preview answers the first hover. A real page wants the
    // default wait — see the delay example below.
    <div className="flex flex-wrap items-center gap-3">
      <Tooltip content="Copy the deploy URL" delay={0}>
        <Button variant="outline" startIcon={<LinkIcon />} />
      </Tooltip>
      <Tooltip content="Every commit on main deploys here" delay={0}>
        <Chip variant="text" color="success">
          production
        </Chip>
      </Tooltip>
      <Tooltip content="Deleting a workspace cannot be undone" color="danger" delay={0}>
        <Button color="danger" variant="outline">
          Delete
        </Button>
      </Tooltip>
    </div>
  );
}

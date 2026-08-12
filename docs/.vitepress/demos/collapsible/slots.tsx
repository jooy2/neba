import { Collapsible, Switch, Typography } from 'neba';

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

export default function CollapsibleSlots() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <Collapsible
        title="Notifications"
        subtitle="How we reach you"
        startIcon={<BellIcon />}
        action={<Switch size="sm" defaultChecked aria-label="Enable notifications" />}
      >
        <Typography>
          Email goes out immediately. Push waits five minutes, so a message you have already read on
          another device never rings twice.
        </Typography>
      </Collapsible>

      <Collapsible title="No chevron" indicator={false}>
        <Typography>The header still reports its state by colour.</Typography>
      </Collapsible>
    </div>
  );
}

import { Button, Icon, IconButton, Toolbar, Typography } from 'neba';

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

function LogoIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect
        x="2.5"
        y="2.5"
        width="11"
        height="11"
        rx="3.5"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path d="M5.5 10.5v-5l5 5v-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export default function ToolbarHero() {
  return (
    <Toolbar
      render={<header />}
      className="w-full"
      start={
        <>
          <Icon icon={<LogoIcon />} size="lg" color="primary" label="Neba" />
          <Typography level="h6">Workspace</Typography>
        </>
      }
      end={
        <>
          <IconButton icon={<BellIcon />} label="Notifications" variant="text" size="sm" />
          <Button size="sm">Deploy</Button>
        </>
      }
    />
  );
}

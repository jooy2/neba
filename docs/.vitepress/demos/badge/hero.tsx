import { Avatar, Badge, Button, Chip } from 'neba';

function BellIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
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

export default function BadgeHero() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <Badge content={4} label="4 unread notifications">
        <Button variant="outline" color="secondary" startIcon={<BellIcon />} />
      </Badge>

      <Badge content={128} label="128 open issues">
        <Button variant="outline" color="secondary">
          Issues
        </Button>
      </Badge>

      <Badge dot color="success" label="Online" overlap="circle">
        <Avatar name="Jane Doe" size="lg" />
      </Badge>

      <Badge content="NEW" size="sm" color="warning" placement="top-start">
        <Chip variant="outline" color="secondary">
          Releases
        </Chip>
      </Badge>
    </div>
  );
}

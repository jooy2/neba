import { Avatar } from 'neba';

function RobotIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <rect
        x="3.5"
        y="7.5"
        width="17"
        height="13"
        rx="3.5"
        stroke="currentColor"
        strokeWidth="1.6"
      />
      <path d="M12 3.5v4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
      <circle cx="9" cy="13.5" r="1.5" fill="currentColor" />
      <circle cx="15" cy="13.5" r="1.5" fill="currentColor" />
    </svg>
  );
}

export default function AvatarFallback() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      {/* Loads, so nothing else is ever drawn. */}
      <Avatar size="xl" src="/samples/people/noa-marin.jpg" name="Noa Marin" />

      {/* Fails, so the initials take over. */}
      <Avatar size="xl" src="/not-a-real-image.png" name="Jane Doe" color="danger" />

      {/* No picture at all: children stand in for it. */}
      <Avatar size="xl" name="Deploy bot" color="secondary">
        <RobotIcon />
      </Avatar>

      <Avatar size="xl" variant="solid" color="warning">
        🐈
      </Avatar>

      {/* Nothing to go on at all. */}
      <Avatar size="xl" color="secondary" />
    </div>
  );
}

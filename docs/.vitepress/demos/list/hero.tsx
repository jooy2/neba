import { Chip, List, ListItem } from 'neba';

function GlobeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M2 8h12M8 1.75c1.6 1.7 2.4 3.8 2.4 6.25S9.6 12.55 8 14.25c-1.6-1.7-2.4-3.8-2.4-6.25S6.4 3.45 8 1.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
      />
    </svg>
  );
}

export default function ListHero() {
  return (
    <div className="w-full max-w-96">
      <List>
        <ListItem
          startIcon={<GlobeIcon />}
          description="Deployed 4 minutes ago"
          action={
            <Chip size="xs" variant="text" color="success">
              Live
            </Chip>
          }
          onClick={() => {}}
          selected
        >
          production
        </ListItem>
        <ListItem
          startIcon={<GlobeIcon />}
          description="Deployed 2 hours ago"
          action={
            <Chip size="xs" variant="text" color="info">
              Building
            </Chip>
          }
          onClick={() => {}}
        >
          staging
        </ListItem>
        <ListItem
          startIcon={<GlobeIcon />}
          description="Never deployed"
          onClick={() => {}}
          disabled
        >
          preview
        </ListItem>
      </List>
    </div>
  );
}

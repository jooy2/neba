import { Button, Chip, IconButton, VisuallyHidden } from 'neba';

export default function VisuallyHiddenHero() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <IconButton
        label="Refresh"
        icon={
          <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor">
            <path d="M13.5 8a5.5 5.5 0 1 1-1.6-3.9M13 2v3h-3" strokeWidth="1.4" />
          </svg>
        }
      />

      <Chip onDelete={() => {}}>Seoul</Chip>

      <Button variant="text">
        <span aria-hidden="true">7</span>
        <VisuallyHidden>7 unread messages</VisuallyHidden>
      </Button>

      <p className="text-sm text-(--neba-muted-fg)">
        The last button says “7” to the eye and “7 unread messages” to a screen reader.
      </p>
    </div>
  );
}

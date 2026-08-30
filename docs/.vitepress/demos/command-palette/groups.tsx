import { useState } from 'react';
import { Button, CommandPalette } from 'neba';

function FileIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M9 1.5H4.5A1.5 1.5 0 0 0 3 3v10a1.5 1.5 0 0 0 1.5 1.5h7A1.5 1.5 0 0 0 13 13V5.5L9 1.5Z"
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function BoltIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M9 1.5 3.5 9H8l-1 5.5L12.5 7H8l1-5.5Z"
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function CommandPaletteGroups() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button size="sm" variant="outline" onClick={() => setOpen(true)}>
        Grouped commands
      </Button>
      <CommandPalette
        size="sm"
        shortcut={false}
        open={open}
        onOpenChange={setOpen}
        items={[
          { value: 'new', label: 'New file', group: 'File', icon: <FileIcon />, shortcut: 'Mod+N' },
          { value: 'open', label: 'Open…', group: 'File', icon: <FileIcon />, shortcut: 'Mod+O' },
          { value: 'build', label: 'Run build', group: 'Run', icon: <BoltIcon /> },
          { value: 'test', label: 'Run tests', group: 'Run', icon: <BoltIcon /> },
          {
            value: 'clean',
            label: 'Clean the cache',
            group: 'Run',
            icon: <BoltIcon />,
            disabled: true
          }
        ]}
      />
    </>
  );
}

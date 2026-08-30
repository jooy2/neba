import { useState } from 'react';
import { Button, CommandPalette, Shortcut, Typography } from 'neba';

const COMMANDS = [
  { value: 'overview', label: 'Go to overview', group: 'Navigate', shortcut: 'G O' },
  { value: 'deploys', label: 'Go to deployments', group: 'Navigate', shortcut: 'G D' },
  { value: 'logs', label: 'Go to logs', group: 'Navigate', keywords: ['traces', 'output'] },
  {
    value: 'deploy',
    label: 'Deploy production',
    description: 'Builds the current branch and moves traffic when it is healthy.',
    group: 'Actions',
    shortcut: 'Mod+Shift+D',
    keywords: ['ship', 'release']
  },
  {
    value: 'rollback',
    label: 'Roll back the last deploy',
    group: 'Actions',
    keywords: ['undo', 'revert']
  },
  { value: 'invite', label: 'Invite a teammate', group: 'Actions' },
  { value: 'theme', label: 'Toggle dark mode', group: 'Preferences' },
  { value: 'shortcuts', label: 'Keyboard shortcuts', group: 'Preferences', shortcut: '?' }
];

export default function CommandPaletteHero() {
  const [open, setOpen] = useState(false);
  const [ran, setRan] = useState<string | null>(null);

  return (
    <div className="flex flex-col items-center gap-4">
      <Button variant="outline" onClick={() => setOpen(true)} endIcon={<Shortcut keys="Mod+K" />}>
        Open the palette
      </Button>

      {ran ? <Typography level="caption">Ran: {ran}</Typography> : null}

      <CommandPalette
        items={COMMANDS}
        open={open}
        onOpenChange={setOpen}
        onSelect={(item) => setRan(item.label)}
      />
    </div>
  );
}

import { useState } from 'react';
import { Button, CommandPalette } from 'neba';

const ITEMS = [
  { value: 'a', label: 'Go to overview' },
  { value: 'b', label: 'Deploy production' },
  { value: 'c', label: 'Invite a teammate' }
];

const sizes = ['sm', 'md', 'lg'] as const;

export default function CommandPaletteSizes() {
  const [size, setSize] = useState<(typeof sizes)[number] | null>(null);

  return (
    <div className="flex items-center gap-2">
      {sizes.map((each) => (
        <Button key={each} size="sm" variant="outline" onClick={() => setSize(each)}>
          {each}
        </Button>
      ))}

      <CommandPalette
        items={ITEMS}
        shortcut={false}
        size={size ?? 'md'}
        open={size !== null}
        onOpenChange={(open) => setSize(open ? size : null)}
      />
    </div>
  );
}

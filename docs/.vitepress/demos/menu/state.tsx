import { useState } from 'react';
import {
  Button,
  Menu,
  MenuCheckboxItem,
  MenuGroup,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator
} from 'neba';

export default function MenuState() {
  const [density, setDensity] = useState<string | number>('cosy');
  const [columns, setColumns] = useState({ status: true, owner: true, updated: false });

  return (
    <div className="flex flex-col items-start gap-3">
      <Menu
        trigger={
          <Button variant="outline" color="secondary">
            View
          </Button>
        }
      >
        {/* A tick says "and", a dot says "instead of" — the same distinction
            Checkbox and Radio make everywhere else in the library. */}
        <MenuGroup label="Columns">
          {(['status', 'owner', 'updated'] as const).map((key) => (
            <MenuCheckboxItem
              key={key}
              checked={columns[key]}
              onCheckedChange={(checked) => setColumns({ ...columns, [key]: checked })}
            >
              {key}
            </MenuCheckboxItem>
          ))}
        </MenuGroup>

        <MenuSeparator />

        <MenuGroup label="Density">
          <MenuRadioGroup value={density} onValueChange={setDensity}>
            <MenuRadioItem value="compact">Compact</MenuRadioItem>
            <MenuRadioItem value="cosy">Cosy</MenuRadioItem>
            <MenuRadioItem value="roomy">Roomy</MenuRadioItem>
          </MenuRadioGroup>
        </MenuGroup>
      </Menu>

      <p className="m-0 text-[0.75rem] text-(--neba-muted-fg)">
        {density} ·{' '}
        {Object.entries(columns)
          .filter(([, on]) => on)
          .map(([key]) => key)
          .join(', ') || 'no columns'}
      </p>
    </div>
  );
}

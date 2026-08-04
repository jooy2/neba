import { useState } from 'react';
import { Button, Drawer, List, ListItem } from 'neba';

export default function DrawerInline() {
  const [open, setOpen] = useState(true);

  return (
    <div className="flex h-64 w-full overflow-hidden rounded-xl border border-[var(--n-line)]">
      <Drawer
        mode="inline"
        open={open}
        onOpenChange={setOpen}
        showClose
        title="Projects"
        extent={200}
      >
        <List density="compact">
          <ListItem>neba</ListItem>
          <ListItem>docs-site</ListItem>
          <ListItem>api-gateway</ListItem>
        </List>
      </Drawer>

      <div className="flex flex-1 flex-col items-start gap-3 p-4">
        <p className="m-0 text-[0.8125rem] text-(--neba-muted-fg)">
          The page is laid out around an inline drawer rather than under it. Closing it takes it out
          of the flow.
        </p>
        <Button size="sm" variant="outline" onClick={() => setOpen((value) => !value)}>
          {open ? 'Collapse the sidebar' : 'Show the sidebar'}
        </Button>
      </div>
    </div>
  );
}

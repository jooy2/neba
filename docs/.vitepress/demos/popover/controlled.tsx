import { useState } from 'react';
import { Button, Popover } from 'neba';

export default function PopoverControlled() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex flex-wrap items-center gap-3">
      <Popover
        open={open}
        onOpenChange={setOpen}
        trigger={<Button variant="outline">Trigger</Button>}
        title="Controlled"
      >
        The caller owns the state, so anything else on the page can open or close this.
      </Popover>

      <Button size="sm" variant="text" onClick={() => setOpen((value) => !value)}>
        {open ? 'Close from out here' : 'Open from out here'}
      </Button>
    </div>
  );
}

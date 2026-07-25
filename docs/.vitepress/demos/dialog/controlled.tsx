import { useState } from 'react';
import { Button, Dialog, TextField } from 'neba';

export default function DialogControlled() {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState('');

  const confirmed = name === 'neba';

  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button color="danger" onClick={() => setOpen(true)}>
        Delete project
      </Button>

      {/* Not dismissible: no Escape, no click outside. A dialog that has to be
          answered needs actions that answer it, and this one has both. */}
      <Dialog
        open={open}
        onOpenChange={setOpen}
        dismissible={false}
        showClose={false}
        size="sm"
        color="danger"
        title="Type the project name"
        description="This is the last step before it is gone."
        actions={
          <>
            <Button variant="text" color="secondary" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button color="danger" disabled={!confirmed} onClick={() => setOpen(false)}>
              Delete
            </Button>
          </>
        }
      >
        <TextField
          fullWidth
          label="Project name"
          placeholder="neba"
          value={name}
          onChange={(event) => setName(event.target.value)}
        />
      </Dialog>
    </div>
  );
}

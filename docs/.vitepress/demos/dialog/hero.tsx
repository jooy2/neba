import { Button, Dialog, DialogClose } from 'neba';

export default function DialogHero() {
  return (
    <Dialog
      trigger={<Button color="danger">Delete workspace</Button>}
      title="Delete this workspace?"
      description="Every project, deploy and log inside it goes with it."
      actions={
        <>
          <DialogClose
            render={
              <Button variant="text" color="secondary">
                Cancel
              </Button>
            }
          />
          <DialogClose render={<Button color="danger">Delete</Button>} />
        </>
      }
    >
      This cannot be undone. Members will lose access immediately.
    </Dialog>
  );
}

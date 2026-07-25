import { Button, Dialog, DialogClose } from 'neba';

const TERMS = Array.from({ length: 12 }, (_, index) => ({
  heading: `${index + 1}. Clause ${index + 1}`,
  body: 'The header and the actions stay put while this part scrolls, which is what the hairlines are there to say.'
}));

export default function DialogScrolling() {
  return (
    <Dialog
      dividers
      size="lg"
      trigger={<Button variant="outline">Read the terms</Button>}
      title="Terms of service"
      description="Last updated 2 March"
      actions={
        <>
          <DialogClose
            render={
              <Button variant="text" color="secondary">
                Decline
              </Button>
            }
          />
          <DialogClose render={<Button>Accept</Button>} />
        </>
      }
    >
      <div className="flex flex-col gap-4">
        {TERMS.map((term) => (
          <div key={term.heading} className="flex flex-col gap-1">
            <div className="font-semibold">{term.heading}</div>
            <p className="text-(--neba-muted-fg)">{term.body}</p>
          </div>
        ))}
      </div>
    </Dialog>
  );
}

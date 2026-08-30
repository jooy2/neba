import { useState } from 'react';
import { Button, Tour } from 'neba';

export default function TourCentred() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button variant="outline" onClick={() => setOpen(true)}>
        Start the welcome
      </Button>

      <Tour
        open={open}
        onOpenChange={setOpen}
        skippable={false}
        steps={[
          {
            title: 'Welcome to Neba Cloud',
            content: 'Three things worth knowing before you start. It takes about a minute.'
          },
          {
            title: 'That is it',
            content: 'Everything else is where you would expect it.'
          }
        ]}
      />
    </>
  );
}

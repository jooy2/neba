import { useState } from 'react';
import { Button, Spoiler, Typography } from 'neba';

export default function SpoilerWords() {
  const [revealed, setRevealed] = useState(false);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Spoiler label="Show the ending" description="Season 2, episode 6" color="warning">
        <Typography>Words of its own, on both lines.</Typography>
      </Spoiler>

      <Spoiler description={false} blur={16}>
        <Typography>A cover with nothing written on it, blurred harder.</Typography>
      </Spoiler>

      {/* A control of your own means driving the state yourself. */}
      <Spoiler
        revealed={revealed}
        onRevealedChange={setRevealed}
        description="Contains the last five minutes"
        action={
          <Button variant="outline" color="danger" onClick={() => setRevealed(true)}>
            I can take it
          </Button>
        }
      >
        <Typography>A button of your own, wired up through revealed.</Typography>
      </Spoiler>
    </div>
  );
}

import { useState } from 'react';
import { AspectRatio, Button, Card, Skeleton } from 'neba';

export default function AspectRatioReserving() {
  const [loaded, setLoaded] = useState(false);

  return (
    <div className="flex w-full max-w-80 flex-col gap-3">
      {/* The box is the same height either way, so the card does not jump when
          the image arrives and nothing below it moves under the reader. */}
      <Card title="Alpine lake, dawn" subtitle="Uploaded 4 minutes ago">
        <AspectRatio ratio={16 / 9} rounded>
          {loaded ? (
            <img
              src="/samples/photos/alpine-lake-dawn.jpg"
              alt="A still alpine lake with the first light on the far ridge"
            />
          ) : (
            <Skeleton shape="rect" className="size-full" label="Loading the photograph" />
          )}
        </AspectRatio>
      </Card>

      <Button size="sm" variant="outline" onClick={() => setLoaded((value) => !value)}>
        {loaded ? 'Unload the image' : 'Load the image'}
      </Button>
    </div>
  );
}

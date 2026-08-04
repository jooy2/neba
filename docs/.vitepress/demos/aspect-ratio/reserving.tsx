import { useState } from 'react';
import { AspectRatio, Button, Card, Skeleton } from 'neba';
import { photo } from './photo';

export default function AspectRatioReserving() {
  const [loaded, setLoaded] = useState(false);

  return (
    <div className="flex w-full max-w-80 flex-col gap-3">
      {/* The box is the same height either way, so the card does not jump when
          the image arrives and nothing below it moves under the reader. */}
      <Card title="Sierra Nevada" subtitle="Uploaded 4 minutes ago">
        <AspectRatio ratio={16 / 9} rounded>
          {loaded ? (
            <img src={photo(30)} alt="A ridge of hills under a low sun" />
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

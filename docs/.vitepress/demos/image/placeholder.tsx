import { Button, Image } from 'neba';
import { useState } from 'react';

export default function ImagePlaceholder() {
  const [requested, setRequested] = useState(false);

  return (
    <div className="flex w-full max-w-md flex-col items-start gap-3">
      {/* Until there is a `src` the picture is still arriving, so the 24-pixel
          copy stands in for it, blurred. */}
      <Image
        src={requested ? '/samples/photos/misty-tea-terraces-sunrise.jpg' : undefined}
        alt="Terraced tea fields under morning mist"
        width={560}
        height={373}
        rounded
        placeholder={{ src: '/samples/photos/misty-tea-terraces-sunrise-tiny.jpg', blur: true }}
      />
      <Button variant="outline" size="sm" onClick={() => setRequested((value) => !value)}>
        {requested ? 'Reset' : 'Load the picture'}
      </Button>
    </div>
  );
}

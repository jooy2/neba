import { useState } from 'react';
import { Box, Button, Tour, Typography } from 'neba';

export default function TourMask() {
  const [masked, setMasked] = useState<boolean | null>(null);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <Box id="tour-mask-target" variant="solid" color="secondary">
        <Typography level="body">The thing being pointed at.</Typography>
      </Box>

      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={() => setMasked(true)}>
          With the mask
        </Button>
        <Button size="sm" variant="outline" onClick={() => setMasked(false)}>
          Without it
        </Button>
      </div>

      <Tour
        open={masked !== null}
        onOpenChange={(open) => setMasked(open ? masked : null)}
        mask={masked ?? true}
        steps={[
          {
            target: '#tour-mask-target',
            title: 'Here',
            content: 'The dimming never takes the pointer — the page keeps working.'
          }
        ]}
      />
    </div>
  );
}

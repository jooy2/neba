import { useState } from 'react';
import { Box, Button, Chip, TextField, Toolbar, Tour, Typography } from 'neba';

export default function TourHero() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Toolbar
        size="sm"
        end={
          <Button id="tour-deploy" size="sm">
            Deploy
          </Button>
        }
      >
        <TextField id="tour-search" size="sm" placeholder="Search projects" />
        <Chip id="tour-status" size="sm" variant="solid" color="success">
          Live
        </Chip>
      </Toolbar>

      <Box variant="outline">
        <Typography level="body" color="secondary">
          A page that already exists. The tour stands over it and points.
        </Typography>
      </Box>

      <Button variant="outline" onClick={() => setOpen(true)}>
        Show me around
      </Button>

      <Tour
        open={open}
        onOpenChange={setOpen}
        steps={[
          {
            target: '#tour-search',
            title: 'Find anything',
            content: 'Every project, deployment and log line is behind this field.'
          },
          {
            target: '#tour-status',
            title: 'The current state',
            content: 'Green means the last deploy is serving traffic.',
            side: 'bottom'
          },
          {
            target: '#tour-deploy',
            title: 'Ship it',
            content: 'Builds the current branch and moves traffic when it is healthy.',
            side: 'left'
          }
        ]}
      />
    </div>
  );
}

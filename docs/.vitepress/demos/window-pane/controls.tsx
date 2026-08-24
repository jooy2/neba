import { useState } from 'react';
import { Button, Typography, WindowPane } from 'neba';

export default function WindowPaneControls() {
  const [open, setOpen] = useState(true);
  const [minimized, setMinimized] = useState(false);
  const [maximized, setMaximized] = useState(false);

  return (
    <div className="flex w-full flex-col items-center gap-4">
      {/* The stage a maximized window fills. Anything positioned is enough. */}
      <div className="relative h-64 w-full overflow-hidden rounded-(--neba-radius-md) bg-(--neba-primary-soft) p-4">
        {open ? (
          <WindowPane
            os="windows11"
            title="Terminal"
            position="absolute"
            width={320}
            height={180}
            offset={{ x: 24, y: 24 }}
            open={open}
            onOpenChange={setOpen}
            minimized={minimized}
            onMinimizedChange={setMinimized}
            maximized={maximized}
            onMaximizedChange={setMaximized}
          >
            <div className="p-3 font-mono">
              <Typography level="body">$ npm install neba</Typography>
              <Typography level="body" color="secondary">
                added 1 package in 1.2s
              </Typography>
            </div>
          </WindowPane>
        ) : null}
      </div>

      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={() => setOpen(true)} disabled={open}>
          Reopen
        </Button>
        <Button
          size="sm"
          variant="outline"
          onClick={() => setMinimized(false)}
          disabled={!minimized}
        >
          Unroll
        </Button>
      </div>
    </div>
  );
}

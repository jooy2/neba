import { useState } from 'react';
import { Pane, Panes, Typography } from 'neba';

export default function PanesSizing() {
  const [sizes, setSizes] = useState<number[]>([]);

  return (
    <div className="flex w-full flex-col gap-2">
      <div className="h-40">
        <Panes onResize={setSizes}>
          <Pane defaultSize="180px" minSize="120px" maxSize="50%" className="p-3">
            <Typography color="secondary">180px to start, never under 120</Typography>
          </Pane>
          <Pane minSize={20} className="p-3">
            <Typography color="secondary">at least a fifth</Typography>
          </Pane>
        </Panes>
      </div>
      <Typography level="caption" color="secondary">
        {sizes.length ? sizes.map((size) => `${Math.round(size)}%`).join(' · ') : 'Drag the bar.'}
      </Typography>
    </div>
  );
}

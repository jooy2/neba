import { Pane, Panes, Typography } from 'neba';

export default function PanesOrientation() {
  return (
    <div className="grid w-full grid-cols-1 gap-4 lg:grid-cols-2">
      <div className="h-40">
        <Panes orientation="horizontal">
          <Pane className="p-3">
            <Typography color="secondary">horizontal, one</Typography>
          </Pane>
          <Pane className="p-3">
            <Typography color="secondary">two</Typography>
          </Pane>
        </Panes>
      </div>

      <div className="h-40">
        <Panes orientation="vertical">
          <Pane className="p-3">
            <Typography color="secondary">vertical, one</Typography>
          </Pane>
          <Pane className="p-3">
            <Typography color="secondary">two</Typography>
          </Pane>
        </Panes>
      </div>
    </div>
  );
}

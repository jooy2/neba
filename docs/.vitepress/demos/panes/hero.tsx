import { Pane, Panes, Typography } from 'neba';

export default function PanesHero() {
  return (
    <div className="h-72 w-full">
      <Panes>
        <Pane defaultSize="200px" minSize="140px" maxSize="45%" className="p-3">
          <Typography level="h6">Files</Typography>
          <Typography color="secondary">Drag the bar to resize.</Typography>
        </Pane>
        <Pane>
          <Panes orientation="vertical">
            <Pane defaultSize={70} minSize="80px" className="p-3">
              <Typography level="h6">Editor</Typography>
              <Typography color="secondary">A split inside a split.</Typography>
            </Pane>
            <Pane minSize="60px" className="p-3">
              <Typography level="h6">Terminal</Typography>
            </Pane>
          </Panes>
        </Pane>
      </Panes>
    </div>
  );
}

import { Pane, Panes, Typography } from 'neba';

/* `resizable={false}` leaves the split as a layout: the bar is still drawn as a
   rule between the panes, but it is not something to grab. */
export default function PanesFixed() {
  return (
    <div className="h-40 w-full">
      <Panes resizable={false}>
        <Pane defaultSize={30} className="p-3">
          <Typography color="secondary">Fixed at 30%</Typography>
        </Pane>
        <Pane className="p-3">
          <Typography color="secondary">The rest</Typography>
        </Pane>
      </Panes>
    </div>
  );
}

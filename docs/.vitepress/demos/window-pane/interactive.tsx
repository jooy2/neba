import { Typography, WindowPane } from 'neba';

export default function WindowPaneInteractive() {
  return (
    <div className="relative h-80 w-full overflow-hidden rounded-(--neba-radius-md) bg-(--neba-secondary-soft)">
      <WindowPane
        title="Inspector"
        position="absolute"
        draggable
        resizable
        width={260}
        height={170}
        defaultOffset={{ x: 20, y: 20 }}
      >
        <div className="p-3">
          <Typography level="body">Drag the title bar.</Typography>
          <Typography level="caption" color="secondary">
            Pull any edge or corner to resize.
          </Typography>
        </div>
      </WindowPane>

      <WindowPane
        os="linux"
        title="Console"
        position="absolute"
        draggable
        resizable
        width={230}
        height={150}
        defaultOffset={{ x: 210, y: 130 }}
      >
        <div className="p-3">
          <Typography level="caption" color="secondary">
            Press one: the other steps back.
          </Typography>
        </div>
      </WindowPane>
    </div>
  );
}

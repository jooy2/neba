import { Button, Drawer, type NebaSide } from 'neba';

const SIDES: NebaSide[] = ['left', 'right', 'top', 'bottom'];

export default function DrawerSides() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {SIDES.map((side) => (
        <Drawer
          key={side}
          side={side}
          trigger={
            <Button variant="outline" color="secondary">
              {side}
            </Button>
          }
          title={`Attached to the ${side}`}
          description="The corners on the free edge are cut; the ones against the window stay square."
        >
          A side panel takes the width its size implies. A top or bottom panel is as tall as what is
          in it, up to 85% of the window.
        </Drawer>
      ))}
    </div>
  );
}

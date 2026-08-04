import { Button, Drawer } from 'neba';

export default function DrawerRounded() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Drawer
        side="bottom"
        size="lg"
        trigger={<Button variant="outline">Rounded</Button>}
        title="Cut corners"
      >
        The two corners facing the page are cut to the size step of the radius ladder.
      </Drawer>

      <Drawer
        side="bottom"
        size="lg"
        rounded={false}
        trigger={
          <Button variant="outline" color="secondary">
            Square
          </Button>
        }
        title="Square corners"
      >
        Every corner is square, for a panel that should read as an extension of the window rather
        than a sheet laid over it.
      </Drawer>
    </div>
  );
}

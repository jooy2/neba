import { Button, Popover, type NebaSide } from 'neba';

const SIDES: NebaSide[] = ['top', 'right', 'bottom', 'left'];

export default function PopoverSides() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {SIDES.map((side) => (
        <Popover
          key={side}
          side={side}
          arrow
          size="sm"
          trigger={
            <Button variant="outline" color="secondary">
              {side}
            </Button>
          }
        >
          Placed on the {side}, and flipped to the opposite side when the window has no room for it.
        </Popover>
      ))}
    </div>
  );
}

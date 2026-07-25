import { Button, Tooltip, type NebaSide } from 'neba';

const SIDES: NebaSide[] = ['top', 'right', 'bottom', 'left'];

export default function TooltipSides() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {SIDES.map((side) => (
        <Tooltip key={side} side={side} delay={0} content={`Placed on the ${side}`}>
          <Button variant="outline" color="secondary">
            {side}
          </Button>
        </Tooltip>
      ))}
    </div>
  );
}

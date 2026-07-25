import { Badge, Button } from 'neba';

const CORNERS = ['top-start', 'top-end', 'bottom-start', 'bottom-end'] as const;

export default function BadgePlacement() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-center gap-6">
        {CORNERS.map((placement) => (
          <Badge key={placement} placement={placement} content={3}>
            <Button variant="outline" color="secondary" size="lg">
              {placement}
            </Button>
          </Badge>
        ))}
      </div>

      {/* A circle's corner is further from its centre than a square's, so the
          badge has to tuck in further or it floats off the edge. */}
      <div className="flex flex-wrap items-center gap-6">
        {(['square', 'circle'] as const).map((overlap) => (
          <div key={overlap} className="flex items-center gap-3">
            <Badge overlap={overlap} content={3} color="danger">
              <span className="flex size-10 items-center justify-center rounded-full bg-(--n-soft-press) text-[0.8125rem] font-semibold text-(--neba-fg)">
                JD
              </span>
            </Badge>
            <span className="text-[0.75rem] text-(--neba-muted-fg)">overlap="{overlap}"</span>
          </div>
        ))}
      </div>
    </div>
  );
}

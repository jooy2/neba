import { Badge, Button } from 'neba';

export default function BadgeContent() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <Badge content={7}>
        <Button variant="outline" color="secondary">
          Seven
        </Button>
      </Badge>

      {/* Past `max`, and the badge says so rather than growing. */}
      <Badge content={1204}>
        <Button variant="outline" color="secondary">
          Capped
        </Button>
      </Badge>

      <Badge content={1204} max={999}>
        <Button variant="outline" color="secondary">
          Higher cap
        </Button>
      </Badge>

      {/* A count of nothing is not news, so it does not show up at all. */}
      <Badge content={0}>
        <Button variant="outline" color="secondary">
          Zero
        </Button>
      </Badge>

      <Badge content={0} showZero color="secondary">
        <Button variant="outline" color="secondary">
          Zero, shown
        </Button>
      </Badge>

      {/* Nothing to count, but something to report. */}
      <Badge dot color="danger">
        <Button variant="outline" color="secondary">
          Dot
        </Button>
      </Badge>
    </div>
  );
}

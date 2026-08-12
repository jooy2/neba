import { Collapsible, Typography } from 'neba';

export default function CollapsibleHero() {
  return (
    <div className="w-full max-w-lg">
      <Collapsible title="Shipping and returns" subtitle="Before you order">
        <Typography>
          Orders placed before 2pm ship the same day. Returns are free for thirty days and the label
          is already in the box.
        </Typography>
      </Collapsible>
    </div>
  );
}

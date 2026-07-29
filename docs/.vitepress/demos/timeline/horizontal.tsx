import { Timeline, TimelineItem } from 'neba';

export default function TimelineHorizontal() {
  return (
    <div className="w-full max-w-2xl">
      <Timeline orientation="horizontal" active={1} density="compact">
        <TimelineItem bullet="1" title="Cart" meta="3 items" />
        <TimelineItem bullet="2" title="Delivery" meta="Address" />
        <TimelineItem bullet="3" title="Payment" meta="Card" />
        <TimelineItem bullet="4" title="Done" />
      </Timeline>
    </div>
  );
}

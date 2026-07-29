import { Timeline, TimelineItem } from 'neba';

export default function TimelineHero() {
  return (
    <div className="w-full max-w-md">
      <Timeline active={2}>
        <TimelineItem title="Ordered" meta="12 Jul">
          Payment taken and the order confirmed.
        </TimelineItem>
        <TimelineItem title="Packed" meta="13 Jul">
          Left the warehouse in Incheon.
        </TimelineItem>
        <TimelineItem title="In transit" meta="14 Jul">
          Out for delivery with the local carrier.
        </TimelineItem>
        <TimelineItem title="Delivered">Expected tomorrow before 6pm.</TimelineItem>
      </Timeline>
    </div>
  );
}

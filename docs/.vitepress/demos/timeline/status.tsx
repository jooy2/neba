import { Timeline, TimelineItem } from 'neba';

/**
 * `active` describes a sequence that is going to plan. A step that failed and
 * stopped it is not something an index can say, which is what the per-item
 * `status` and `color` overrides are for.
 */
export default function TimelineStatus() {
  return (
    <div className="w-full max-w-md">
      <Timeline active={2}>
        <TimelineItem title="Queued" meta="09:31">
          Picked up by the runner.
        </TimelineItem>
        <TimelineItem title="Built" meta="09:33" connector="dashed">
          Artifacts uploaded.
        </TimelineItem>
        <TimelineItem title="Tests failed" meta="09:36" color="danger" status="current">
          3 of 412 assertions did not pass.
        </TimelineItem>
        <TimelineItem title="Deploy" status="upcoming">
          Blocked until the tests pass.
        </TimelineItem>
      </Timeline>
    </div>
  );
}

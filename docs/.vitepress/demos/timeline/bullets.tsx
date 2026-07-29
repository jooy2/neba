import { Timeline, TimelineItem } from 'neba';

function CheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m3.5 8.5 3 3 6-6"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function TimelineBullets() {
  return (
    <div className="flex w-full max-w-md flex-col gap-8">
      {/* Numbers, for a sequence somebody is being walked through. */}
      <Timeline active={1} size="lg">
        <TimelineItem bullet="1" title="Account">
          Email and a password.
        </TimelineItem>
        <TimelineItem bullet="2" title="Workspace">
          Name it and pick a region.
        </TimelineItem>
        <TimelineItem bullet="3" title="Invite">
          Optional, and skippable.
        </TimelineItem>
      </Timeline>

      {/* Icons, for a sequence that already happened. */}
      <Timeline active={2} color="success" size="lg">
        <TimelineItem bullet={<CheckIcon />} title="Built" meta="1m 12s" />
        <TimelineItem bullet={<CheckIcon />} title="Tested" meta="3m 40s" />
        <TimelineItem title="Deploying" meta="running" />
      </Timeline>
    </div>
  );
}

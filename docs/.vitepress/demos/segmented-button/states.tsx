import { Segment, SegmentedButton } from 'neba';

function GridIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect
        x="2.5"
        y="2.5"
        width="4.5"
        height="4.5"
        rx="1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <rect x="9" y="2.5" width="4.5" height="4.5" rx="1" stroke="currentColor" strokeWidth="1.5" />
      <rect x="2.5" y="9" width="4.5" height="4.5" rx="1" stroke="currentColor" strokeWidth="1.5" />
      <rect x="9" y="9" width="4.5" height="4.5" rx="1" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function ListIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M5.5 4h8M5.5 8h8M5.5 12h8M2.5 4h.01M2.5 8h.01M2.5 12h.01"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function SegmentedButtonStates() {
  return (
    <div className="flex w-full max-w-md flex-col items-center gap-5">
      {/* Icons ride on the label, sized in `em`. */}
      <SegmentedButton aria-label="Layout" defaultValue="grid">
        <Segment value="list" startIcon={<ListIcon />}>
          List
        </Segment>
        <Segment value="grid" startIcon={<GridIcon />}>
          Grid
        </Segment>
      </SegmentedButton>

      {/* One segment out of the set, without disabling the rest. */}
      <SegmentedButton aria-label="Plan" defaultValue="team">
        <Segment value="starter">Starter</Segment>
        <Segment value="team">Team</Segment>
        <Segment value="enterprise" disabled>
          Enterprise
        </Segment>
      </SegmentedButton>

      {/* Read-only keeps the choice and drains the saturation; disabled drops
          the colour family entirely. */}
      <SegmentedButton aria-label="Mode" defaultValue="auto" readOnly>
        <Segment value="light">Light</Segment>
        <Segment value="auto">Auto</Segment>
        <Segment value="dark">Dark</Segment>
      </SegmentedButton>

      {/* The full width, divided evenly. */}
      <SegmentedButton aria-label="Period" defaultValue="30d" fullWidth>
        <Segment value="7d">7 days</Segment>
        <Segment value="30d">30 days</Segment>
        <Segment value="90d">90 days</Segment>
      </SegmentedButton>
    </div>
  );
}

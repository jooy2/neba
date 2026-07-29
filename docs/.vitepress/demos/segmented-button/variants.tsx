import { Segment, SegmentedButton } from 'neba';

const variants = ['solid', 'outline', 'text'] as const;

export default function SegmentedButtonVariants() {
  return (
    <div className="flex flex-col items-center gap-5">
      {variants.map((variant) => (
        <SegmentedButton key={variant} aria-label={variant} variant={variant} defaultValue="week">
          <Segment value="day">Day</Segment>
          <Segment value="week">Week</Segment>
          <Segment value="month">Month</Segment>
        </SegmentedButton>
      ))}
    </div>
  );
}

import { Segment, SegmentedButton } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function SegmentedButtonSizes() {
  return (
    <div className="flex flex-col items-center gap-4">
      {sizes.map((size) => (
        <SegmentedButton key={size} aria-label={size} size={size} defaultValue="on">
          <Segment value="on">On</Segment>
          <Segment value="auto">Auto</Segment>
          <Segment value="off">Off</Segment>
        </SegmentedButton>
      ))}
    </div>
  );
}

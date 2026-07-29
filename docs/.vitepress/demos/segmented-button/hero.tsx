import { useState } from 'react';
import { Segment, SegmentedButton } from 'neba';

export default function SegmentedButtonHero() {
  const [range, setRange] = useState<string | number | null>('week');

  return (
    <div className="flex flex-col items-center gap-5">
      <SegmentedButton aria-label="Range" value={range} onValueChange={setRange}>
        <Segment value="day">Day</Segment>
        <Segment value="week">Week</Segment>
        <Segment value="month">Month</Segment>
        <Segment value="year">Year</Segment>
      </SegmentedButton>

      <SegmentedButton aria-label="Layout" variant="solid" defaultValue="grid">
        <Segment value="list">List</Segment>
        <Segment value="grid">Grid</Segment>
        <Segment value="map">Map</Segment>
      </SegmentedButton>
    </div>
  );
}

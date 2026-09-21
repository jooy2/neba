import { DataList, DataListItem, Sparkline } from 'neba';

// Three weeks the exporter was down. Not three weeks of nothing.
const READINGS = [42, 47, 51, null, null, null, 58, 55, 62, 68];

export default function SparklineGaps() {
  return (
    <DataList className="w-full max-w-md" size="sm">
      <DataListItem label="nulls='gap'">
        <Sparkline data={READINGS} label="Readings, broken at the gap" width={160} />
      </DataListItem>
      <DataListItem label="nulls='connect'">
        <Sparkline data={READINGS} nulls="connect" label="Readings, bridged" width={160} />
      </DataListItem>
      <DataListItem label="nulls='zero'">
        <Sparkline data={READINGS} nulls="zero" label="Readings, read as zero" width={160} />
      </DataListItem>
    </DataList>
  );
}

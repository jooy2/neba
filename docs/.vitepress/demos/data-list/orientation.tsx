import { Box, DataList, DataListItem } from 'neba';

export default function DataListOrientation() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      {(['horizontal', 'vertical'] as const).map((orientation) => (
        <Box key={orientation} variant="outline">
          <DataList orientation={orientation}>
            <DataListItem label="Plan">Team</DataListItem>
            <DataListItem label="Seats">12 of 20</DataListItem>
            <DataListItem label="Renews">1 April 2026</DataListItem>
          </DataList>
        </Box>
      ))}
    </div>
  );
}

import { Box, DataList, DataListItem } from 'neba';

export default function DataListDividers() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      {[false, true].map((dividers) => (
        <Box key={String(dividers)} variant="outline">
          <DataList dividers={dividers} density="compact" size="sm">
            <DataListItem label="Runtime">Node 26</DataListItem>
            <DataListItem label="Framework">Next.js 16</DataListItem>
            <DataListItem label="Bundle">215.3 kB</DataListItem>
          </DataList>
        </Box>
      ))}
    </div>
  );
}

import { Box, DataList, DataListItem } from 'neba';

export default function DataListLabelWidth() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <Box variant="outline">
        <DataList>
          <DataListItem label="Id">8f2c1a</DataListItem>
          <DataListItem label="Environment">Production</DataListItem>
        </DataList>
      </Box>
      <Box variant="outline">
        <DataList labelWidth={140}>
          <DataListItem label="Id">8f2c1a</DataListItem>
          <DataListItem label="Environment">Production</DataListItem>
        </DataList>
      </Box>
    </div>
  );
}

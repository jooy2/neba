import { Box, ScrollZone, Typography } from 'neba';

const releases = [
  ['1.5.0', 'Breadcrumb trails'],
  ['1.4.0', 'Charts'],
  ['1.3.0', 'Date pickers'],
  ['1.2.0', 'Menus'],
  ['1.1.0', 'Tables'],
  ['1.0.0', 'First release'],
  ['0.9.0', 'Beta'],
  ['0.8.0', 'Alpha']
];

export default function ScrollZoneVertical() {
  return (
    <div className="h-56 w-full max-w-sm">
      <ScrollZone
        orientation="vertical"
        label="Releases"
        spacing={2}
        buttons="always"
        className="h-full"
      >
        {releases.map(([version, note]) => (
          <Box key={version} size="sm" variant="outline">
            <Typography level="body">{version}</Typography>
            <Typography level="caption" color="secondary">
              {note}
            </Typography>
          </Box>
        ))}
      </ScrollZone>
    </div>
  );
}

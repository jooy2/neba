import { Box, ScrollZone, Typography } from 'neba';

const numbers = Array.from({ length: 12 }, (_, index) => index + 1);

function Strip() {
  return (
    <>
      {numbers.map((number) => (
        <Box key={number} size="sm" variant="solid" className="w-28 text-center">
          Item {number}
        </Box>
      ))}
    </>
  );
}

export default function ScrollZonePlacement() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          buttonPlacement=&quot;overlay&quot;
        </Typography>
        <ScrollZone label="Overlaid" buttons="always">
          <Strip />
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          buttonPlacement=&quot;inline&quot;
        </Typography>
        <ScrollZone label="Beside" buttons="always" buttonPlacement="inline">
          <Strip />
        </ScrollZone>
      </div>
    </div>
  );
}

import { Box, ScrollZone, Typography } from 'neba';

const numbers = Array.from({ length: 14 }, (_, index) => index + 1);

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

export default function ScrollZoneWheel() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          The wheel is the page&apos;s
        </Typography>
        <ScrollZone label="Without the wheel">
          <Strip />
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          wheel — roll over the strip, and keep rolling at the end
        </Typography>
        <ScrollZone label="With the wheel" wheel>
          <Strip />
        </ScrollZone>
      </div>
    </div>
  );
}

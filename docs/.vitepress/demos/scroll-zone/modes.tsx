import { Box, ScrollZone, Typography } from 'neba';

const numbers = Array.from({ length: 14 }, (_, index) => index + 1);

function Strip({ children }: { children: React.ReactNode }) {
  return (
    <>
      {numbers.map((number) => (
        <Box key={number} size="sm" variant="outline" className="w-24 text-center">
          {number}
        </Box>
      ))}
      {children}
    </>
  );
}

export default function ScrollZoneModes() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          mode=&quot;item&quot; · step=2
        </Typography>
        <ScrollZone label="One item at a time" step={2} buttons="always">
          <Strip>{null}</Strip>
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          mode=&quot;page&quot;
        </Typography>
        <ScrollZone label="A page at a time" mode="page" buttons="always">
          <Strip>{null}</Strip>
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          mode=&quot;hold&quot; · speed=600
        </Typography>
        <ScrollZone label="Hold to scroll" mode="hold" speed={600} buttons="always">
          <Strip>{null}</Strip>
        </ScrollZone>
      </div>
    </div>
  );
}

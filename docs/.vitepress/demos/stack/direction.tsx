import { Card, Stack, Typography } from 'neba';

function Sheet({ label }: { label: string }) {
  return (
    <Card size="sm" className="w-32">
      <Typography level="caption">{label}</Typography>
    </Card>
  );
}

const SHEETS = ['Invoice', 'Receipt', 'Contract'];

export default function StackDirection() {
  return (
    <div className="flex w-full flex-wrap items-start gap-10">
      {(['horizontal', 'vertical', 'diagonal'] as const).map((direction) => (
        <div key={direction} className="flex flex-col gap-2">
          <Typography level="caption" color="secondary">
            {direction}
          </Typography>
          <Stack direction={direction} overlap={28} drop={14}>
            {SHEETS.map((sheet) => (
              <Sheet key={sheet} label={sheet} />
            ))}
          </Stack>
        </div>
      ))}
    </div>
  );
}

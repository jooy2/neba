import { Typography } from 'neba';

const COPY =
  'A Neba surface is a sheet of cut acrylic, not a moulded plastic key. Press is instant and release is slow, elevation is opt-in, and no control ever moves under the cursor.';

export default function TypographyClamp() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <div className="flex flex-col gap-1">
        <Typography level="overline">lines=1</Typography>
        <Typography lines={1}>{COPY}</Typography>
      </div>
      <div className="flex flex-col gap-1">
        <Typography level="overline">lines=2</Typography>
        <Typography lines={2}>{COPY}</Typography>
      </div>
      <div className="flex flex-col gap-1">
        <Typography level="overline">no clamp</Typography>
        <Typography>{COPY}</Typography>
      </div>
    </div>
  );
}

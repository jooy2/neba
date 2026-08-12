import { Rating, Typography } from 'neba';

export default function RatingStates() {
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-col items-center gap-1">
        <Rating defaultValue={3} clearable={false} />
        <Typography level="caption" className="text-(--neba-muted-fg)">
          clearable={'{false}'} — a score, once given, stays given
        </Typography>
      </div>

      <div className="flex flex-col items-center gap-1">
        <Rating defaultValue={2} disabled />
        <Typography level="caption" className="text-(--neba-muted-fg)">
          disabled
        </Typography>
      </div>
    </div>
  );
}

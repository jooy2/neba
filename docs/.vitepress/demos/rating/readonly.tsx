import { Rating, Typography } from 'neba';

const reviews = [
  { name: 'Cold brew concentrate', score: 4.6, count: 1284 },
  { name: 'Ceramic pour-over cone', score: 3.2, count: 96 },
  { name: 'Paper filters, 100 pack', score: 5, count: 12 }
];

export default function RatingReadonly() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      {reviews.map((review) => (
        <div key={review.name} className="flex items-center justify-between gap-4">
          <Typography level="body">{review.name}</Typography>
          <div className="flex shrink-0 items-center gap-2">
            <Rating value={review.score} readOnly size="sm" />
            <Typography level="caption" className="text-(--neba-muted-fg)">
              {review.score} ({review.count})
            </Typography>
          </div>
        </div>
      ))}
    </div>
  );
}

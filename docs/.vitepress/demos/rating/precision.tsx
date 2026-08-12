import { useState } from 'react';
import { Rating, Typography } from 'neba';

export default function RatingPrecision() {
  const [score, setScore] = useState(3.5);

  return (
    <div className="flex flex-col items-center gap-3">
      <Rating value={score} onValueChange={setScore} precision={0.5} size="lg" />
      <Typography level="caption" className="text-(--neba-muted-fg)">
        {score || 'nothing'} chosen
      </Typography>

      <Rating defaultValue={7} count={10} precision={0.5} size="sm" label="Out of ten" />
    </div>
  );
}

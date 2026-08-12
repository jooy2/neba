import { useState } from 'react';
import { Rating, Typography } from 'neba';

export default function RatingHero() {
  const [score, setScore] = useState(4);

  return (
    <div className="flex flex-col items-center gap-2">
      <Rating value={score} onValueChange={setScore} size="lg" />
      <Typography level="caption" className="text-(--neba-muted-fg)">
        {score === 0 ? 'Not rated yet' : `${score} out of 5`}
      </Typography>
    </div>
  );
}

import { Rating } from 'neba';

export default function RatingAppearance() {
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-col items-center gap-2">
        {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
          <Rating key={size} size={size} defaultValue={3} label={`Rating, ${size}`} />
        ))}
      </div>

      <div className="flex flex-wrap items-center justify-center gap-4">
        {(['primary', 'success', 'danger', 'info'] as const).map((color) => (
          <Rating key={color} color={color} defaultValue={4} label={`Rating, ${color}`} />
        ))}
      </div>
    </div>
  );
}

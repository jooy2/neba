import { Avatar } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function AvatarVariants() {
  return (
    <div className="flex flex-col gap-4">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <div key={variant} className="flex flex-wrap items-center gap-3">
          {COLORS.map((color) => (
            <Avatar key={color} variant={variant} color={color} name="Jane Doe" size="lg" />
          ))}
        </div>
      ))}
    </div>
  );
}

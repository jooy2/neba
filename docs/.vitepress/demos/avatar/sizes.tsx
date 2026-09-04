import { Avatar, Button } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function AvatarSizes() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar key={size} size={size} src="/samples/people/anya-sol.jpg" name="Anya Sol" />
        ))}
      </div>
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar key={size} size={size} name="Anya Sol" color="info" />
        ))}
      </div>
      {/* An avatar is on the control ladder, so it lines up with the button beside it. */}
      <div className="flex flex-wrap items-center gap-3">
        {SIZES.map((size) => (
          <div key={size} className="flex items-center gap-2">
            <Avatar size={size} name="Anya Sol" />
            <Button size={size} variant="outline" color="secondary">
              {size}
            </Button>
          </div>
        ))}
      </div>
    </div>
  );
}

import { Avatar } from 'neba';

const SIZES = ['sm', 'md', 'lg', 'xl'] as const;

export default function AvatarShape() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar
            key={size}
            size={size}
            shape="circle"
            src="/samples/people/theo-quinn.jpg"
            name="Theo Quinn"
          />
        ))}
      </div>
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar
            key={size}
            size={size}
            shape="square"
            src="/samples/people/theo-quinn.jpg"
            name="Theo Quinn"
          />
        ))}
      </div>
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar
            key={size}
            size={size}
            shape="square"
            variant="solid"
            color="secondary"
            name="Neba UI"
          />
        ))}
      </div>
    </div>
  );
}

import { Avatar } from 'neba';
import { portrait } from './portrait';

const SIZES = ['sm', 'md', 'lg', 'xl'] as const;

export default function AvatarShape() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar key={size} size={size} shape="circle" src={portrait(30)} name="Jane Doe" />
        ))}
      </div>
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Avatar key={size} size={size} shape="square" src={portrait(30)} name="Jane Doe" />
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

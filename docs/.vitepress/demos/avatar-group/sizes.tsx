import { Avatar, AvatarGroup } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;
const TEAM = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee'];

export default function AvatarGroupSizes() {
  return (
    <div className="flex flex-col items-center gap-4">
      {sizes.map((size) => (
        <AvatarGroup key={size} size={size} max={3}>
          {TEAM.map((person) => (
            <Avatar key={person} name={person} />
          ))}
        </AvatarGroup>
      ))}
    </div>
  );
}

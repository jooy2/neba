import { Avatar, AvatarGroup } from 'neba';

const TEAM = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee', 'Noa Cohen'];

export default function AvatarGroupMax() {
  return (
    <div className="flex flex-col items-center gap-5">
      {[undefined, 3, 2].map((max, index) => (
        <div key={index} className="flex items-center gap-4">
          <span className="w-20 text-[0.75rem] text-(--neba-muted-fg)">
            {max === undefined ? 'no max' : `max ${max}`}
          </span>
          <AvatarGroup max={max}>
            {TEAM.map((person) => (
              <Avatar key={person} name={person} />
            ))}
          </AvatarGroup>
        </div>
      ))}
    </div>
  );
}

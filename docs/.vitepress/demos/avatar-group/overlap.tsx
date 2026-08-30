import { Avatar, AvatarGroup } from 'neba';

const TEAM = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee'];

export default function AvatarGroupOverlap() {
  return (
    <div className="flex flex-col items-center gap-5">
      {[0, 4, 18].map((overlap) => (
        <div key={overlap} className="flex items-center gap-4">
          <span className="w-20 text-[0.75rem] text-(--neba-muted-fg)">{overlap}px</span>
          <AvatarGroup overlap={overlap} shape="square">
            {TEAM.map((person) => (
              <Avatar key={person} name={person} />
            ))}
          </AvatarGroup>
        </div>
      ))}
    </div>
  );
}

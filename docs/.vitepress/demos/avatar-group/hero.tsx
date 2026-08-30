import { Avatar, AvatarGroup } from 'neba';

const TEAM = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee', 'Noa Cohen', 'Ravi Patel'];

export default function AvatarGroupHero() {
  return (
    <div className="flex flex-col items-center gap-6">
      <AvatarGroup>
        {TEAM.slice(0, 4).map((person) => (
          <Avatar key={person} name={person} />
        ))}
      </AvatarGroup>

      <AvatarGroup max={3} total={24} variant="solid" color="secondary">
        {TEAM.map((person) => (
          <Avatar key={person} name={person} />
        ))}
      </AvatarGroup>
    </div>
  );
}

import { Avatar } from 'neba';

const PEOPLE = [
  { name: 'Jane Doe' },
  { name: 'jane miriam van doe' },
  { name: '홍길동' },
  { name: 'Ada' },
  { name: 'Jane Doe', initials: 'vD' }
];

export default function AvatarInitials() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      {PEOPLE.map((person) => (
        <div key={person.initials ?? person.name} className="flex flex-col items-center gap-2">
          <Avatar size="xl" color="info" name={person.name} initials={person.initials} />
          <code className="text-[0.75rem] text-(--neba-muted-fg)">
            {person.initials ? `initials="${person.initials}"` : `"${person.name}"`}
          </code>
        </div>
      ))}
    </div>
  );
}

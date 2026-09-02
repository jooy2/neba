import { Avatar, Stack } from 'neba';

const TEAM = ['Jane Doe', 'Kim Minji', 'Alex Park', 'Sam Lee'];

export default function StackHero() {
  return (
    <Stack ring max={3} total={12} overflow={(hidden) => <Avatar initials={`+${hidden}`} />}>
      {TEAM.map((name) => (
        <Avatar key={name} name={name} />
      ))}
    </Stack>
  );
}

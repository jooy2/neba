import { Avatar, Stack } from 'neba';

const TEAM = ['Anya Sol', 'Theo Quinn', 'Lucas Adebayo', 'Nadia Rowan'].map((name) => ({
  name,
  src: `/samples/people/${name.toLowerCase().replace(' ', '-')}.jpg`
}));

export default function StackHero() {
  return (
    <Stack ring max={3} total={12} overflow={(hidden) => <Avatar initials={`+${hidden}`} />}>
      {TEAM.map((person) => (
        <Avatar key={person.name} name={person.name} src={person.src} />
      ))}
    </Stack>
  );
}

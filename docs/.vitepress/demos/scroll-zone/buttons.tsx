import { Avatar, ScrollZone, Typography } from 'neba';

const people = [
  'Anya Sol',
  'Farah Wells',
  'Helen Voss',
  'Joon Mercer',
  'Lucas Adebayo',
  'Nadia Rowan',
  'Noa Marin',
  'Sam Arden',
  'Theo Quinn',
  'Victor Saye'
].map((name) => ({ name, src: `/samples/people/${name.toLowerCase().replace(' ', '-')}.jpg` }));

export default function ScrollZoneButtons() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          buttons=&quot;always&quot;
        </Typography>
        <ScrollZone label="Always" buttons="always" spacing={3}>
          {people.map((person) => (
            <Avatar key={person.name} name={person.name} src={person.src} size="lg" />
          ))}
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          buttons=&quot;none&quot; · snap
        </Typography>
        <ScrollZone label="None" buttons="none" snap spacing={3}>
          {people.map((person) => (
            <Avatar key={person.name} name={person.name} src={person.src} size="lg" />
          ))}
        </ScrollZone>
      </div>
    </div>
  );
}

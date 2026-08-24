import { Avatar, ScrollZone, Typography } from 'neba';

const people = ['Ada', 'Bo', 'Cai', 'Dana', 'Eun', 'Fen', 'Gus', 'Hana', 'Ivo', 'Jun'];

export default function ScrollZoneButtons() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          buttons=&quot;always&quot;
        </Typography>
        <ScrollZone label="Always" buttons="always" spacing={3}>
          {people.map((name) => (
            <Avatar key={name} name={name} size="lg" />
          ))}
        </ScrollZone>
      </div>

      <div>
        <Typography level="caption" color="secondary">
          buttons=&quot;none&quot; · snap
        </Typography>
        <ScrollZone label="None" buttons="none" snap spacing={3}>
          {people.map((name) => (
            <Avatar key={name} name={name} size="lg" color="secondary" />
          ))}
        </ScrollZone>
      </div>
    </div>
  );
}

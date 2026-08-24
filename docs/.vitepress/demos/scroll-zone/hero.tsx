import { Card, ScrollZone, Typography } from 'neba';

const shows = [
  { name: 'Aurora', note: 'Documentary' },
  { name: 'Deep Field', note: 'Science' },
  { name: 'The Long Road', note: 'Drama' },
  { name: 'Salt & Stone', note: 'Cooking' },
  { name: 'Night Shift', note: 'Thriller' },
  { name: 'Paper Boats', note: 'Family' },
  { name: 'Signal', note: 'Mystery' }
];

export default function ScrollZoneHero() {
  return (
    <div className="w-full">
      <Typography level="h6" className="mb-2">
        Continue watching
      </Typography>

      <ScrollZone label="Continue watching" spacing={3}>
        {shows.map((show) => (
          <Card key={show.name} size="sm" className="w-40" title={show.name} subtitle={show.note}>
            <div className="h-16 rounded-(--neba-radius-sm) bg-(--neba-primary-soft)" />
          </Card>
        ))}
      </ScrollZone>
    </div>
  );
}

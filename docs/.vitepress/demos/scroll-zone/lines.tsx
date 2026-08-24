import { Chip, ScrollZone } from 'neba';

const tags = [
  'Design',
  'Engineering',
  'Research',
  'Marketing',
  'Support',
  'Finance',
  'Legal',
  'People',
  'Security',
  'Data',
  'Sales',
  'Operations'
];

export default function ScrollZoneLines() {
  return (
    <div className="flex w-full flex-col gap-6">
      <ScrollZone label="Teams, one line" spacing={2}>
        {tags.map((tag) => (
          <Chip key={tag}>{tag}</Chip>
        ))}
      </ScrollZone>

      <ScrollZone label="Teams, two lines" lines={2} spacing={2}>
        {tags.map((tag) => (
          <Chip key={tag} color="secondary">
            {tag}
          </Chip>
        ))}
      </ScrollZone>
    </div>
  );
}

import { Avatar, Card, Chip, DataList, DataListItem, TextLink } from 'neba';

export default function DataListHero() {
  return (
    <Card className="w-full max-w-md" title="Deployment 8f2c1a" subtitle="Production">
      <DataList dividers>
        <DataListItem label="Status">
          <Chip size="xs" variant="solid" color="success">
            Live
          </Chip>
        </DataListItem>
        <DataListItem label="Region">Frankfurt · eu-central-1</DataListItem>
        <DataListItem label="Author">
          <span className="inline-flex items-center gap-2">
            <Avatar size="xs" src="/samples/people/anya-sol.jpg" name="Anya Sol" />
            Kim Minji
          </span>
        </DataListItem>
        <DataListItem label="Duration">42s</DataListItem>
        <DataListItem label="Commit">
          <TextLink href="#commit">8f2c1a</TextLink>
        </DataListItem>
      </DataList>
    </Card>
  );
}

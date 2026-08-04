import { Button, Drawer, DrawerClose, List, ListItem } from 'neba';

const REGIONS = [
  'us-east-1',
  'us-west-2',
  'eu-west-1',
  'eu-central-1',
  'ap-northeast-1',
  'ap-northeast-2',
  'ap-southeast-1',
  'ap-southeast-2',
  'sa-east-1',
  'af-south-1',
  'me-south-1',
  'ca-central-1'
];

export default function DrawerScrolling() {
  return (
    <Drawer
      side="right"
      dividers
      trigger={<Button variant="outline">Pick a region</Button>}
      title="Regions"
      description="The header and the actions stay put; only the body scrolls."
      actions={
        <>
          <DrawerClose
            render={
              <Button variant="text" color="secondary">
                Cancel
              </Button>
            }
          />
          <DrawerClose render={<Button>Apply</Button>} />
        </>
      }
    >
      <List>
        {REGIONS.map((region) => (
          <ListItem key={region}>{region}</ListItem>
        ))}
      </List>
    </Drawer>
  );
}

import { Button, Drawer, DrawerClose, List, ListItem } from 'neba';

export default function DrawerHero() {
  return (
    <Drawer
      trigger={<Button variant="outline">Open navigation</Button>}
      title="Workspace"
      description="Everything this account can reach."
      actions={
        <DrawerClose
          render={
            <Button variant="text" color="secondary">
              Close
            </Button>
          }
        />
      }
    >
      <List>
        <ListItem description="Deploys, usage and alerts">Overview</ListItem>
        <ListItem description="12 active">Projects</ListItem>
        <ListItem description="4 people">Members</ListItem>
        <ListItem description="Team plan">Billing</ListItem>
      </List>
    </Drawer>
  );
}

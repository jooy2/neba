import { List, ListItem, Sidebar, Typography } from 'neba';

export default function SidebarSides() {
  return (
    <div className="flex h-72 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <Sidebar collapseBelow="none" width={160} label="Sections">
        <Typography level="overline">Sections</Typography>
        <List variant="text" size="sm">
          <ListItem href="#" selected>
            Overview
          </ListItem>
          <ListItem href="#">Props</ListItem>
        </List>
      </Sidebar>

      <div className="min-w-0 flex-1 p-4">
        <Typography level="h6">Two sidebars</Typography>
        <Typography color="secondary">Each has its own width and its own drawer.</Typography>
      </div>

      <Sidebar collapseBelow="none" side="end" width={160} label="On this page" variant="text">
        <Typography level="overline">On this page</Typography>
        <List variant="text" size="sm">
          <ListItem href="#">Props</ListItem>
          <ListItem href="#">Examples</ListItem>
        </List>
      </Sidebar>
    </div>
  );
}

import { List, ListItem, Sidebar, Typography } from 'neba';

export default function SidebarHero() {
  return (
    <div className="flex h-72 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <Sidebar collapseBelow="none" width={200}>
        <Typography level="overline">Sections</Typography>
        <List>
          <ListItem selected>Overview</ListItem>
          <ListItem>Components</ListItem>
          <ListItem>Design</ListItem>
          <ListItem>Changelog</ListItem>
        </List>
      </Sidebar>

      <div className="min-w-0 flex-1 p-4">
        <Typography level="h6">Overview</Typography>
        <Typography color="secondary">The content the sidebar sits beside.</Typography>
      </div>
    </div>
  );
}

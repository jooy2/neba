import { useState } from 'react';
import { List, ListItem, Sidebar, Typography } from 'neba';

export default function SidebarResizable() {
  const [width, setWidth] = useState(200);

  return (
    <div className="flex h-72 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <Sidebar
        collapseBelow="none"
        resizable
        width={200}
        minWidth={140}
        maxWidth={320}
        onResize={setWidth}
      >
        <Typography level="overline">Files</Typography>
        <List>
          <ListItem>src</ListItem>
          <ListItem selected>package.json</ListItem>
          <ListItem>README.md</ListItem>
        </List>
      </Sidebar>

      <div className="min-w-0 flex-1 p-4">
        <Typography level="h6">Drag the inner edge</Typography>
        <Typography color="secondary">{Math.round(width)}px</Typography>
      </div>
    </div>
  );
}

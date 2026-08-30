import { Menubar, MenubarMenu, MenuItem, MenuSeparator, Typography, WindowPane } from 'neba';

export default function MenubarWindow() {
  return (
    <WindowPane os="windows11" title="notes.txt" className="w-full max-w-lg" height={220}>
      <div className="flex h-full flex-col">
        <Menubar size="xs" className="border-b border-(--neba-border) px-1 py-0.5">
          <MenubarMenu label="File">
            <MenuItem>New</MenuItem>
            <MenuSeparator />
            <MenuItem>Exit</MenuItem>
          </MenubarMenu>
          <MenubarMenu label="Edit">
            <MenuItem>Find…</MenuItem>
          </MenubarMenu>
          <MenubarMenu label="Format">
            <MenuItem>Word wrap</MenuItem>
          </MenubarMenu>
        </Menubar>
        <div className="p-3">
          <Typography level="body">
            The strip sits on the window, not on a sheet of its own.
          </Typography>
        </div>
      </div>
    </WindowPane>
  );
}

import {
  Menubar,
  MenubarMenu,
  MenuCheckboxItem,
  MenuGroup,
  MenuItem,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator,
  MenuSubmenu,
  Toolbar
} from 'neba';

export default function MenubarHero() {
  return (
    <Toolbar className="w-full max-w-lg" size="sm">
      <Menubar size="sm">
        <MenubarMenu label="File">
          <MenuItem shortcut="⌘N">New file</MenuItem>
          <MenuItem shortcut="⌘O">Open…</MenuItem>
          <MenuSubmenu label="Open recent">
            <MenuItem>neba/src/index.ts</MenuItem>
            <MenuItem>neba/README.md</MenuItem>
          </MenuSubmenu>
          <MenuSeparator />
          <MenuItem shortcut="⌘S">Save</MenuItem>
          <MenuItem color="danger">Close window</MenuItem>
        </MenubarMenu>

        <MenubarMenu label="Edit">
          <MenuItem shortcut="⌘Z">Undo</MenuItem>
          <MenuItem shortcut="⇧⌘Z">Redo</MenuItem>
          <MenuSeparator />
          <MenuItem shortcut="⌘X">Cut</MenuItem>
          <MenuItem shortcut="⌘C">Copy</MenuItem>
        </MenubarMenu>

        <MenubarMenu label="View">
          <MenuGroup label="Panels">
            <MenuCheckboxItem defaultChecked>Sidebar</MenuCheckboxItem>
            <MenuCheckboxItem>Terminal</MenuCheckboxItem>
          </MenuGroup>
          <MenuSeparator />
          <MenuRadioGroup defaultValue="comfortable">
            <MenuRadioItem value="compact">Compact</MenuRadioItem>
            <MenuRadioItem value="comfortable">Comfortable</MenuRadioItem>
          </MenuRadioGroup>
        </MenubarMenu>
      </Menubar>
    </Toolbar>
  );
}

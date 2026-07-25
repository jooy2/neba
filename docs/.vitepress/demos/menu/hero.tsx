import { Button, Menu, MenuItem, MenuSeparator, MenuSubmenu } from 'neba';

export default function MenuHero() {
  return (
    <Menu
      trigger={
        <Button variant="outline" color="secondary">
          Actions
        </Button>
      }
    >
      <MenuItem shortcut="⌘E">Rename</MenuItem>
      <MenuItem shortcut="⌘D">Duplicate</MenuItem>
      <MenuSubmenu label="Move to">
        <MenuItem>Archive</MenuItem>
        <MenuItem>Templates</MenuItem>
        <MenuSubmenu label="Team">
          <MenuItem>Design</MenuItem>
          <MenuItem>Platform</MenuItem>
        </MenuSubmenu>
      </MenuSubmenu>
      <MenuSeparator />
      <MenuItem color="danger" shortcut="⌫">
        Delete
      </MenuItem>
    </Menu>
  );
}

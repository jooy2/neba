import { Button, Menu, MenuItem, MenuSubmenu } from 'neba';

/**
 * Nesting is unlimited because a submenu's children are just menu rows, and one
 * of those rows can be another submenu. Base UI opens them on hover with a safe
 * triangle, so reaching diagonally into an open submenu does not close it.
 */
export default function MenuNested() {
  return (
    <Menu
      trigger={
        <Button variant="outline" color="secondary">
          Insert
        </Button>
      }
    >
      <MenuItem>Text block</MenuItem>
      <MenuSubmenu label="Media">
        <MenuItem>Image</MenuItem>
        <MenuItem>Video</MenuItem>
        <MenuSubmenu label="Embed">
          <MenuItem>YouTube</MenuItem>
          <MenuItem>CodeSandbox</MenuItem>
          <MenuSubmenu label="Other">
            <MenuItem>By URL</MenuItem>
            <MenuItem>By oEmbed</MenuItem>
          </MenuSubmenu>
        </MenuSubmenu>
      </MenuSubmenu>
      <MenuSubmenu label="Data">
        <MenuItem>Table</MenuItem>
        <MenuItem>Chart</MenuItem>
      </MenuSubmenu>
    </Menu>
  );
}

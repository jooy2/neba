import { Menubar, MenubarMenu, MenuItem } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg'] as const;

export default function MenubarSizes() {
  return (
    <div className="flex flex-col items-start gap-4">
      {sizes.map((size) => (
        <Menubar key={size} size={size} aria-label={size}>
          <MenubarMenu label="File">
            <MenuItem>New file</MenuItem>
          </MenubarMenu>
          <MenubarMenu label="Edit">
            <MenuItem>Undo</MenuItem>
          </MenubarMenu>
          <MenubarMenu label="View">
            <MenuItem>Sidebar</MenuItem>
          </MenubarMenu>
        </Menubar>
      ))}
    </div>
  );
}

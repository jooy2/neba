import { Menubar, MenubarMenu, MenuItem } from 'neba';

export default function MenubarOrientation() {
  return (
    <Menubar orientation="vertical" size="sm" aria-label="Sections" className="w-40">
      <MenubarMenu label="Project">
        <MenuItem>Settings</MenuItem>
        <MenuItem>Members</MenuItem>
      </MenubarMenu>
      <MenubarMenu label="Deploys">
        <MenuItem>Production</MenuItem>
        <MenuItem>Preview</MenuItem>
      </MenubarMenu>
      <MenubarMenu label="Billing">
        <MenuItem>Invoices</MenuItem>
      </MenubarMenu>
    </Menubar>
  );
}

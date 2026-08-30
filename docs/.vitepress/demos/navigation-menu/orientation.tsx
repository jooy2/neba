import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

export default function NavigationMenuOrientation() {
  return (
    <NavigationMenu orientation="vertical" size="sm" aria-label="Sections" className="w-44">
      <NavigationMenuItem label="Overview" href="#overview" />
      <NavigationMenuItem label="Deploys">
        <NavigationMenuLink href="#production" title="Production" />
        <NavigationMenuLink href="#preview" title="Preview" />
      </NavigationMenuItem>
      <NavigationMenuItem label="Settings">
        <NavigationMenuLink href="#general" title="General" />
        <NavigationMenuLink href="#members" title="Members" />
      </NavigationMenuItem>
    </NavigationMenu>
  );
}

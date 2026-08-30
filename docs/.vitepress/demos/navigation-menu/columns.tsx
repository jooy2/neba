import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

export default function NavigationMenuColumns() {
  return (
    <NavigationMenu aria-label="Regions" size="sm">
      <NavigationMenuItem label="One column">
        <NavigationMenuLink href="#seoul" title="Seoul" />
        <NavigationMenuLink href="#tokyo" title="Tokyo" />
        <NavigationMenuLink href="#osaka" title="Osaka" />
      </NavigationMenuItem>
      <NavigationMenuItem label="Three columns" columns={3}>
        <NavigationMenuLink href="#seoul" title="Seoul" description="ap-northeast-2" />
        <NavigationMenuLink href="#tokyo" title="Tokyo" description="ap-northeast-1" />
        <NavigationMenuLink href="#osaka" title="Osaka" description="ap-northeast-3" />
        <NavigationMenuLink href="#frankfurt" title="Frankfurt" description="eu-central-1" />
        <NavigationMenuLink href="#dublin" title="Dublin" description="eu-west-1" />
        <NavigationMenuLink href="#virginia" title="Virginia" description="us-east-1" />
      </NavigationMenuItem>
    </NavigationMenu>
  );
}

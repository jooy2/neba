import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

export default function NavigationMenuHero() {
  return (
    <NavigationMenu aria-label="Main">
      <NavigationMenuItem label="Product" columns={2}>
        <NavigationMenuLink
          href="#analytics"
          title="Analytics"
          description="Every number the product produces."
        />
        <NavigationMenuLink
          href="#pipelines"
          title="Pipelines"
          description="Builds, tests and deploys."
        />
        <NavigationMenuLink
          href="#insights"
          title="Insights"
          description="What the numbers mean."
        />
        <NavigationMenuLink href="#alerts" title="Alerts" description="When to look at them." />
      </NavigationMenuItem>

      <NavigationMenuItem label="Developers">
        <NavigationMenuLink href="#docs" title="Documentation" description="Every component." />
        <NavigationMenuLink href="#api" title="API reference" />
        <NavigationMenuLink href="#changelog" title="Changelog" />
      </NavigationMenuItem>

      <NavigationMenuItem label="Pricing" href="#pricing" />
      <NavigationMenuItem label="Blog" href="#blog" />
    </NavigationMenu>
  );
}

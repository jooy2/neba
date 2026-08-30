import {
  AppLogo,
  Button,
  Header,
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink
} from 'neba';

export default function NavigationMenuHeader() {
  return (
    <Header
      className="w-full"
      brand={<AppLogo name="Neba" size="sm" />}
      actions={
        <Button size="sm" variant="outline">
          Sign in
        </Button>
      }
    >
      <NavigationMenu size="sm" aria-label="Main">
        <NavigationMenuItem label="Product">
          <NavigationMenuLink href="#analytics" title="Analytics" description="Every number." />
          <NavigationMenuLink href="#pipelines" title="Pipelines" description="Build and ship." />
        </NavigationMenuItem>
        <NavigationMenuItem label="Docs" href="#docs" />
        <NavigationMenuItem label="Pricing" href="#pricing" />
      </NavigationMenu>
    </Header>
  );
}

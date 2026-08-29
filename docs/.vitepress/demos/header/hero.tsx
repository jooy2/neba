import { AppLogo, Button, Header, TextLink } from 'neba';

export default function HeaderHero() {
  return (
    <Header
      position="static"
      brand={<AppLogo name="Neba" shape="app" showName />}
      actions={
        <>
          <Button variant="text" size="sm">
            Sign in
          </Button>
          <Button variant="solid" size="sm">
            Get started
          </Button>
        </>
      }
      className="rounded-(--neba-radius-md)"
    >
      <nav className="flex items-center gap-4">
        <TextLink href="#" underline="hover">
          Docs
        </TextLink>
        <TextLink href="#" underline="hover">
          Components
        </TextLink>
        <TextLink href="#" underline="hover">
          Changelog
        </TextLink>
      </nav>
    </Header>
  );
}

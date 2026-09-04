import { AppLogo, Button, Header } from 'neba';

export default function HeaderMeasure() {
  return (
    <Header
      position="static"
      maxWidth="sm"
      brand={<AppLogo name="Neba" src="/128x128.png" showName size="sm" />}
      actions={
        <Button size="sm" variant="outline">
          Sign in
        </Button>
      }
      className="rounded-(--neba-radius-md)"
    />
  );
}

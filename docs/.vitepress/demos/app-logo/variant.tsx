import { AppLogo } from 'neba';

export default function AppLogoVariant() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <AppLogo name="Acme Corp" shape="app" size="lg" />
      <AppLogo name="Acme Corp" shape="app" size="lg" variant="outline" color="info" />
      <AppLogo name="Acme Corp" shape="app" size="lg" variant="text" color="success" />
    </div>
  );
}

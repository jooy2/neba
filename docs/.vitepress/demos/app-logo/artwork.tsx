import { AppLogo } from 'neba';

function Mark() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 18V7l8 10 8-10v11" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function AppLogoArtwork() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      {/* A file, drawn as it came. */}
      <AppLogo name="Acme Compass" src="/samples/logos/compass.png" size="lg" />
      <AppLogo name="Acme Stack" src="/samples/logos/layered-stack.png" size="lg" />

      {/* Markup, which takes the colour around it. */}
      <AppLogo name="Neba" size="lg">
        <Mark />
      </AppLogo>
      <AppLogo name="Neba" size="lg" shape="app">
        <Mark />
      </AppLogo>

      {/* Neither, so the name's initials stand in. */}
      <AppLogo name="Acme Corp" size="lg" shape="app" variant="outline" />
    </div>
  );
}

import { AppLogo } from 'neba';

function Mark() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 18V7l8 10 8-10v11" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function AppLogoHero() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <AppLogo name="Neba" />
      <AppLogo name="Neba" shape="app">
        <Mark />
      </AppLogo>
      <AppLogo name="Neba" shape="app" showName color="secondary">
        <Mark />
      </AppLogo>
    </div>
  );
}

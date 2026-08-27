import { AppLogo } from 'neba';

function Mark() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 18V7l8 10 8-10v11" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function AppLogoLink() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <AppLogo name="Neba" href="/" shape="app" showName>
        <Mark />
      </AppLogo>
      <AppLogo name="Neba" render={<h1 />} size="xl" />
      <AppLogo name="Neba" height={56} shape="app">
        <Mark />
      </AppLogo>
    </div>
  );
}

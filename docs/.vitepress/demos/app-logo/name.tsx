import { AppLogo } from 'neba';

function Mark() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 18V7l8 10 8-10v11" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function AppLogoName() {
  return (
    <div className="flex flex-col gap-5">
      <AppLogo name="Neba Studio" />
      <AppLogo name="Neba Studio" shape="app" />
      <AppLogo name="Neba Studio" shape="app" showName />
      <AppLogo name="Neba Studio" shape="circle" showName initials="NS">
        <Mark />
      </AppLogo>
    </div>
  );
}

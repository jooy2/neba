/** The four glyphs the FloatingBottomNavigation demos share. */

export function HomeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M2.5 7 8 2.5 13.5 7v6a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V7Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.25 10.25 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function LibraryIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect x="2.5" y="3" width="3" height="10" rx="1" stroke="currentColor" strokeWidth="1.5" />
      <rect x="7" y="3" width="3" height="10" rx="1" stroke="currentColor" strokeWidth="1.5" />
      <path d="m11.6 4 2.4 8.4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function ProfileIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="5.75" r="2.75" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M3 13.25a5 5 0 0 1 10 0"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

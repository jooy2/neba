import { useState } from 'react';
import { BottomNavigation, BottomNavigationItem, Typography } from 'neba';

function HomeIcon() {
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

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.25 10.25 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function InboxIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect
        x="2.25"
        y="3.25"
        width="11.5"
        height="9.5"
        rx="2"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path
        d="M2.25 8.5h3l1 1.5h3.5l1-1.5h3"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ProfileIcon() {
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

export default function BottomNavigationHero() {
  const [section, setSection] = useState<string | number>('home');

  return (
    <div className="w-full max-w-xs">
      <div className="flex h-24 items-center justify-center">
        <Typography level="caption" className="text-(--neba-muted-fg)">
          {section}
        </Typography>
      </div>

      <BottomNavigation position="static" label="Main" value={section} onValueChange={setSection}>
        <BottomNavigationItem value="home" icon={<HomeIcon />}>
          Home
        </BottomNavigationItem>
        <BottomNavigationItem value="search" icon={<SearchIcon />}>
          Search
        </BottomNavigationItem>
        <BottomNavigationItem value="inbox" icon={<InboxIcon />}>
          Inbox
        </BottomNavigationItem>
        <BottomNavigationItem value="profile" icon={<ProfileIcon />}>
          Profile
        </BottomNavigationItem>
      </BottomNavigation>
    </div>
  );
}

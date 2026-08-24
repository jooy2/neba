import { useState } from 'react';
import { BottomNavigationItem, FloatingBottomNavigation, Typography } from 'neba';
import { HomeIcon, LibraryIcon, ProfileIcon, SearchIcon } from './icons';

export default function FloatingBottomNavigationHero() {
  const [section, setSection] = useState<string | number>('home');

  return (
    // The screen the bar floats over. `position="absolute"` pins it to this box
    // rather than to the window.
    <div className="relative h-72 w-full max-w-sm overflow-hidden rounded-(--neba-radius-lg) border [border-color:var(--neba-border)] bg-(--neba-surface)">
      <div className="flex flex-col gap-3 p-4">
        <Typography level="h6">{section}</Typography>
        {Array.from({ length: 6 }, (_, index) => (
          <div key={index} className="h-8 rounded-(--neba-radius-sm) bg-(--neba-primary-soft)" />
        ))}
      </div>

      <FloatingBottomNavigation
        position="absolute"
        label="Main"
        value={section}
        onValueChange={setSection}
      >
        <BottomNavigationItem value="home" icon={<HomeIcon />}>
          Home
        </BottomNavigationItem>
        <BottomNavigationItem value="search" icon={<SearchIcon />}>
          Search
        </BottomNavigationItem>
        <BottomNavigationItem value="library" icon={<LibraryIcon />}>
          Library
        </BottomNavigationItem>
        <BottomNavigationItem value="you" icon={<ProfileIcon />}>
          You
        </BottomNavigationItem>
      </FloatingBottomNavigation>
    </div>
  );
}

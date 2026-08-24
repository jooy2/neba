import { BottomNavigationItem, FloatingBottomNavigation, Typography } from 'neba';
import { HomeIcon, ProfileIcon, SearchIcon } from './icons';

export default function FloatingBottomNavigationPinned() {
  return (
    <div className="h-64 w-full max-w-sm overflow-y-auto rounded-(--neba-radius-md) border [border-color:var(--neba-border)]">
      <div className="flex flex-col gap-4 p-4">
        {Array.from({ length: 10 }, (_, index) => (
          <Typography key={index}>
            Row {index + 1}. Scroll the box: the bar keeps its gap from the bottom edge.
          </Typography>
        ))}
      </div>

      <FloatingBottomNavigation
        position="sticky"
        offset={12}
        safeArea={false}
        size="sm"
        defaultValue="home"
      >
        <BottomNavigationItem value="home" icon={<HomeIcon />}>
          Home
        </BottomNavigationItem>
        <BottomNavigationItem value="search" icon={<SearchIcon />}>
          Search
        </BottomNavigationItem>
        <BottomNavigationItem value="you" icon={<ProfileIcon />}>
          You
        </BottomNavigationItem>
      </FloatingBottomNavigation>
    </div>
  );
}

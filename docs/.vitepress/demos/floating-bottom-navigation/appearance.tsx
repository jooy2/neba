import { BottomNavigationItem, FloatingBottomNavigation, Typography } from 'neba';
import { HomeIcon, ProfileIcon, SearchIcon } from './icons';

const variants = ['outline', 'solid', 'text'] as const;

export default function FloatingBottomNavigationAppearance() {
  return (
    <div className="flex w-full flex-col items-center gap-6">
      {variants.map((variant) => (
        <div key={variant} className="flex flex-col items-center gap-2">
          <Typography level="caption" color="secondary">
            variant=&quot;{variant}&quot;
          </Typography>

          <FloatingBottomNavigation
            position="static"
            variant={variant}
            color="info"
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
      ))}
    </div>
  );
}

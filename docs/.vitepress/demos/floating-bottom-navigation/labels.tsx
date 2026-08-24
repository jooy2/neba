import { BottomNavigationItem, FloatingBottomNavigation, Typography } from 'neba';
import { HomeIcon, ProfileIcon, SearchIcon } from './icons';

const options = ['selected', 'all', 'none'] as const;

export default function FloatingBottomNavigationLabels() {
  return (
    <div className="flex w-full flex-col items-center gap-6">
      {options.map((labels) => (
        <div key={labels} className="flex flex-col items-center gap-2">
          <Typography level="caption" color="secondary">
            labels=&quot;{labels}&quot;
          </Typography>

          <FloatingBottomNavigation position="static" labels={labels} defaultValue="home">
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

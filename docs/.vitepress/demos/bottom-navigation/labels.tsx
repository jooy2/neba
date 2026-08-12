import { BottomNavigation, BottomNavigationItem, Typography } from 'neba';

function DiscIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="5.25" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="8" cy="8" r="1.5" fill="currentColor" />
    </svg>
  );
}

const modes = ['all', 'selected', 'none'] as const;

export default function BottomNavigationLabels() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      {modes.map((labels) => (
        <div key={labels} className="flex flex-col gap-1">
          <Typography level="caption" className="text-(--neba-muted-fg)">
            labels=&quot;{labels}&quot;
          </Typography>
          <BottomNavigation position="static" labels={labels} defaultValue="library">
            <BottomNavigationItem value="listen" icon={<DiscIcon />}>
              Listen
            </BottomNavigationItem>
            <BottomNavigationItem value="library" icon={<DiscIcon />}>
              Library
            </BottomNavigationItem>
            <BottomNavigationItem value="radio" icon={<DiscIcon />}>
              Radio
            </BottomNavigationItem>
          </BottomNavigation>
        </div>
      ))}
    </div>
  );
}

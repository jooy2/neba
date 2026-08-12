import { BottomNavigation, BottomNavigationItem, Typography } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4.25" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

export default function BottomNavigationPinned() {
  return (
    <div className="h-64 w-full max-w-xs overflow-y-auto rounded-(--neba-radius-md) border [border-color:var(--neba-border)]">
      <div className="flex flex-col gap-4 p-4">
        {Array.from({ length: 8 }, (_, index) => (
          <Typography key={index}>
            Row {index + 1}. Scroll the box: the bar stays against its bottom edge.
          </Typography>
        ))}
      </div>

      <BottomNavigation position="sticky" defaultValue="feed" safeArea={false}>
        <BottomNavigationItem value="feed" icon={<DotIcon />}>
          Feed
        </BottomNavigationItem>
        <BottomNavigationItem value="saved" icon={<DotIcon />}>
          Saved
        </BottomNavigationItem>
      </BottomNavigation>
    </div>
  );
}

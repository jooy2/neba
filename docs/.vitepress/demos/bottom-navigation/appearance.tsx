import type { ComponentProps } from 'react';
import { BottomNavigation, BottomNavigationItem, Typography } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4.25" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function Bar({ children, ...props }: ComponentProps<typeof BottomNavigation>) {
  return (
    <BottomNavigation position="static" defaultValue="two" {...props}>
      <BottomNavigationItem value="one" icon={<DotIcon />}>
        One
      </BottomNavigationItem>
      <BottomNavigationItem value="two" icon={<DotIcon />}>
        Two
      </BottomNavigationItem>
      <BottomNavigationItem value="three" icon={<DotIcon />}>
        Three
      </BottomNavigationItem>
      {children}
    </BottomNavigation>
  );
}

export default function BottomNavigationAppearance() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      <div className="flex flex-col gap-1">
        <Typography level="caption" className="text-(--neba-muted-fg)">
          variant=&quot;solid&quot; color=&quot;success&quot;
        </Typography>
        <Bar variant="solid" color="success" />
      </div>

      <div className="flex flex-col gap-1">
        <Typography level="caption" className="text-(--neba-muted-fg)">
          size=&quot;sm&quot; density=&quot;compact&quot;
        </Typography>
        <Bar size="sm" density="compact" />
      </div>

      <div className="flex flex-col gap-1">
        <Typography level="caption" className="text-(--neba-muted-fg)">
          variant=&quot;text&quot; divider={'{false}'}
        </Typography>
        <Bar variant="text" divider={false} />
      </div>
    </div>
  );
}

import { BottomNavigation, BottomNavigationItem } from 'neba';

function DocsIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M4 2.75h5L12 6v7.25H4V2.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8.75 2.75V6H12" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
    </svg>
  );
}

function GridIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect
        x="2.75"
        y="2.75"
        width="4.5"
        height="4.5"
        rx="1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <rect
        x="8.75"
        y="2.75"
        width="4.5"
        height="4.5"
        rx="1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <rect
        x="2.75"
        y="8.75"
        width="4.5"
        height="4.5"
        rx="1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <rect
        x="8.75"
        y="8.75"
        width="4.5"
        height="4.5"
        rx="1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
    </svg>
  );
}

export default function BottomNavigationLinks() {
  return (
    <div className="w-full max-w-xs">
      <BottomNavigation position="static" label="Documentation" value="components">
        <BottomNavigationItem value="guide" href="/guide/getting-started" icon={<DocsIcon />}>
          Guide
        </BottomNavigationItem>
        <BottomNavigationItem value="components" href="/components/" icon={<GridIcon />}>
          Components
        </BottomNavigationItem>
        <BottomNavigationItem value="design" href="/design/design-language" icon={<DocsIcon />}>
          Design
        </BottomNavigationItem>
      </BottomNavigation>
    </div>
  );
}

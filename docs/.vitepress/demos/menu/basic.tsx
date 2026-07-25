import { Button, Menu, MenuGroup, MenuItem, MenuSeparator } from 'neba';

function CopyIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect
        x="5.5"
        y="5.5"
        width="8"
        height="8"
        rx="1.75"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path
        d="M10.5 5.5v-1a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v4a2 2 0 0 0 2 2h1"
        stroke="currentColor"
        strokeWidth="1.5"
      />
    </svg>
  );
}

function LinkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.5 9.5 9.5 6.5M6 4.5 7.5 3a2.9 2.9 0 0 1 4 4L10 8.5M10 11.5 8.5 13a2.9 2.9 0 0 1-4-4L6 7.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function MenuBasic() {
  return (
    <div className="flex flex-wrap items-start gap-3">
      <Menu
        trigger={
          <Button variant="outline" color="secondary">
            Share
          </Button>
        }
      >
        <MenuGroup label="Copy">
          <MenuItem startIcon={<LinkIcon />} shortcut="⌘L">
            Copy link
          </MenuItem>
          <MenuItem startIcon={<CopyIcon />} description="Includes the current filters">
            Copy as Markdown
          </MenuItem>
        </MenuGroup>
        <MenuSeparator />
        <MenuGroup label="Open">
          {/* A menu of links has to be links — `href` renders a real anchor, so
              a middle click opens a tab and a right click offers to copy it. */}
          <MenuItem href="https://neba.cdget.com" target="_blank">
            Documentation
          </MenuItem>
          <MenuItem href="https://github.com/jooy2/neba" target="_blank">
            Repository
          </MenuItem>
        </MenuGroup>
        <MenuSeparator />
        <MenuItem disabled>Export as PDF</MenuItem>
      </Menu>

      <Menu
        color="danger"
        trigger={
          <Button variant="outline" color="danger">
            Danger zone
          </Button>
        }
      >
        <MenuItem color="secondary">Archive project</MenuItem>
        <MenuSeparator />
        <MenuItem color="danger" description="Members lose access immediately">
          Delete project
        </MenuItem>
      </Menu>
    </div>
  );
}

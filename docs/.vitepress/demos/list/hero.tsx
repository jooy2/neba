import { List, ListItem } from 'neba';

function FolderIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M1.75 4.25A1.5 1.5 0 0 1 3.25 2.75h2.4l1.2 1.5h5.9a1.5 1.5 0 0 1 1.5 1.5v6a1.5 1.5 0 0 1-1.5 1.5H3.25a1.5 1.5 0 0 1-1.5-1.5v-7.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ImageIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect x="2" y="3" width="12" height="10" rx="1.5" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="6" cy="6.5" r="1.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m3 11.5 3-2.5 3 2 2-1.5 2 2" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function FileIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4 2.75h5L12.5 6v7.25H4V2.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M9 2.75V6h3.5" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
    </svg>
  );
}

export default function ListHero() {
  return (
    <div className="w-full max-w-96">
      <List>
        <ListItem startIcon={<FolderIcon />} description="12 items">
          Documents
        </ListItem>
        <ListItem startIcon={<ImageIcon />} description="248 items">
          Pictures
        </ListItem>
        <ListItem startIcon={<FileIcon />} description="Edited yesterday">
          Notes.md
        </ListItem>
      </List>
    </div>
  );
}

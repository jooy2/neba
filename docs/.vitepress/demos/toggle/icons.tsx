import { Toggle } from 'neba';

function BoldIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4.5 3h4a2.5 2.5 0 0 1 0 5h-4V3Zm0 5h4.5a2.5 2.5 0 0 1 0 5H4.5V8Z"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ItalicIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M10 3H6.5m3 10H6m3.5-10L7 13" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  );
}

function UnderlineIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4.5 2.5v5a3.5 3.5 0 0 0 7 0v-5M3.5 14h9"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function ToggleIcons() {
  return (
    <div className="flex items-center gap-2">
      <Toggle variant="text" aria-label="Bold" defaultPressed startIcon={<BoldIcon />} />
      <Toggle variant="text" aria-label="Italic" startIcon={<ItalicIcon />} />
      <Toggle variant="text" aria-label="Underline" startIcon={<UnderlineIcon />} />
    </div>
  );
}

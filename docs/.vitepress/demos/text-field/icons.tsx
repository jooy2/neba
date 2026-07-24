import { TextField } from 'neba';

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.5 10.5 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export default function TextFieldIcons() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <TextField startIcon={<SearchIcon />} placeholder="Search" fullWidth />
      <TextField loading defaultValue="Checking…" label="loading" fullWidth />
    </div>
  );
}

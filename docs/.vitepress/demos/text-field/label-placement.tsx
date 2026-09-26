import { TextField } from 'neba';

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.5 10.5 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export default function TextFieldLabelPlacement() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 items-end gap-x-4 gap-y-6 sm:grid-cols-3">
      <TextField label="Top" placeholder="you@example.com" fullWidth />
      <TextField labelPlacement="notch" label="Notch" placeholder="you@example.com" fullWidth />
      <TextField labelPlacement="float" label="Float" placeholder="you@example.com" fullWidth />
      <TextField
        labelPlacement="notch"
        label="Email"
        startIcon={<SearchIcon />}
        placeholder="you@example.com"
        fullWidth
      />
      <TextField labelPlacement="float" label="Name" defaultValue="Ada Lovelace" fullWidth />
      <TextField labelPlacement="float" label="Message" multiline rows={2} fullWidth />
    </div>
  );
}

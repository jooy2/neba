import { TextField } from 'neba';

export default function TextFieldStates() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <TextField label="Normal" defaultValue="Value" fullWidth />
      <TextField label="Read-only" defaultValue="Value" readOnly fullWidth />
      <TextField label="Disabled" defaultValue="Value" disabled fullWidth />
      <TextField
        label="Invalid"
        defaultValue="not-an-email"
        error="Enter a valid address."
        fullWidth
      />
    </div>
  );
}

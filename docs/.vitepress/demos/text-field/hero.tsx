import { TextField } from 'neba';

export default function TextFieldHero() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <TextField label="Email" placeholder="jane@example.com" fullWidth />
      <TextField
        label="Display name"
        defaultValue="Jane"
        description="Shown on your public profile."
        fullWidth
      />
      <TextField
        label="Password"
        type="password"
        defaultValue="secret"
        error="Must be at least 8 characters."
        fullWidth
      />
      <TextField label="About" multiline rows={2} placeholder="A sentence or two." fullWidth />
    </div>
  );
}

import { TextField } from 'neba';

export default function TextFieldVariants() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      <TextField variant="solid" label="solid" placeholder="Type here" fullWidth />
      <TextField variant="outline" label="outline" placeholder="Type here" fullWidth />
      <TextField variant="text" label="text" placeholder="Type here" fullWidth />
    </div>
  );
}

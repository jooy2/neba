import { TextField } from 'neba';

export default function TextFieldMultiline() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <TextField
        multiline
        rows={1}
        label="rows 1"
        placeholder="Same height as an input"
        fullWidth
      />
      <TextField
        multiline
        rows={4}
        label="rows 4"
        description="Drag the corner — vertical only."
        fullWidth
      />
      <TextField
        multiline
        rows={3}
        resize="none"
        label='resize="none"'
        placeholder="A fixed box"
        fullWidth
      />
      <TextField
        multiline
        rows={3}
        variant="solid"
        label="solid"
        defaultValue={'Two lines of\nexisting content'}
        fullWidth
      />
    </div>
  );
}

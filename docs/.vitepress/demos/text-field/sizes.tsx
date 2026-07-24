import { Button, TextField } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function TextFieldSizes() {
  return (
    <div className="flex flex-col gap-3">
      {SIZES.map((size) => (
        <div key={size} className="flex flex-wrap items-center gap-2">
          <TextField size={size} placeholder={`size ${size}`} />
          <TextField size={size} density="compact" placeholder="compact" />
          <Button size={size} variant="outline" color="secondary">
            Same height
          </Button>
        </div>
      ))}
    </div>
  );
}

import { Fieldset, TextField } from 'neba';

const sizes = ['sm', 'md', 'lg'] as const;

export default function FieldsetSizes() {
  return (
    <div className="grid w-full max-w-3xl grid-cols-1 gap-6 sm:grid-cols-3">
      {sizes.map((size) => (
        <Fieldset key={size} size={size} legend={size} description="Legend and gap.">
          <TextField size={size} label="Street" name={`${size}-street`} />
          <TextField size={size} label="City" name={`${size}-city`} />
        </Fieldset>
      ))}
    </div>
  );
}

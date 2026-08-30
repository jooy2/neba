import { Button, Form, TextField } from 'neba';

const modes = ['onSubmit', 'onBlur', 'onChange'] as const;

export default function FormValidationMode() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-6 sm:grid-cols-3">
      {modes.map((mode) => (
        <Form key={mode} size="sm" validationMode={mode} onSubmit={() => {}}>
          <TextField
            size="sm"
            label={mode}
            name="email"
            type="email"
            required
            placeholder="you@example.com"
          />
          <Button size="sm" type="submit">
            Submit
          </Button>
        </Form>
      ))}
    </div>
  );
}

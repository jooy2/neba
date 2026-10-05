import { Form, TextField } from 'neba';

function Fields({ id }: { id: string }) {
  return (
    <>
      <TextField label="Email" name={`${id}-email`} type="email" placeholder="you@example.com" />
      <TextField label="Password" name={`${id}-password`} type="password" />
      <TextField label="Team" name={`${id}-team`} description="You can change it later." />
    </>
  );
}

export default function FormSpacing() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-8 sm:grid-cols-2">
      {/* The gap `size` picks: 0.75rem at md. */}
      <Form aria-label="Default spacing">
        <Fields id="default" />
      </Form>

      {/* An exact gap: 7 is 1.75rem. */}
      <Form aria-label="Spacing 7" spacing={7}>
        <Fields id="wide" />
      </Form>
    </div>
  );
}

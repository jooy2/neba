import { useState } from 'react';
import { Button, Form, TextField } from 'neba';

/** Stands in for a server that already knows this address. */
const TAKEN = 'taken@example.com';

export default function FormErrors() {
  const [errors, setErrors] = useState<Record<string, string>>({});

  return (
    <Form
      className="w-full max-w-sm"
      errors={errors}
      onSubmit={(values) =>
        setErrors(values.email === TAKEN ? { email: 'That address is already taken.' } : {})
      }
    >
      <TextField
        label="Email"
        name="email"
        type="email"
        required
        defaultValue={TAKEN}
        description={`Submit as ${TAKEN} to see the server answer.`}
      />
      <Button type="submit">Check</Button>
    </Form>
  );
}

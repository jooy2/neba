import { useState } from 'react';
import { Button, Form, TextField, Typography } from 'neba';

export default function FormHero() {
  const [submitted, setSubmitted] = useState<string | null>(null);

  return (
    <Form
      className="w-full max-w-sm"
      onSubmit={(values) => setSubmitted(String(values.email ?? ''))}
    >
      <TextField label="Email" name="email" type="email" required placeholder="you@example.com" />
      <TextField label="Password" name="password" type="password" required minLength={8} />
      <Button type="submit" fullWidth>
        Create account
      </Button>
      {submitted ? <Typography level="caption">Submitted as {submitted}.</Typography> : null}
    </Form>
  );
}

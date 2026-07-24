import { useState } from 'react';
import { TextField } from 'neba';

export default function TextFieldControlled() {
  const [email, setEmail] = useState('');
  const valid = email === '' || /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);

  return (
    <div className="w-full max-w-sm">
      <TextField
        label="Email"
        value={email}
        onChange={(event) => setEmail(event.target.value)}
        error={valid ? undefined : 'Enter a valid address.'}
        description={valid ? `${email.length} characters` : undefined}
        placeholder="jane@example.com"
        fullWidth
      />
    </div>
  );
}

import { useState } from 'react';
import { AnimateShake, Button, TextField } from 'neba';

export default function AnimateShakeHero() {
  const [value, setValue] = useState('');
  const [wrong, setWrong] = useState(0);

  return (
    <form
      className="flex w-full max-w-sm items-end gap-2"
      onSubmit={(event) => {
        event.preventDefault();
        if (value !== 'neba') setWrong((n) => n + 1);
      }}
    >
      {/* A new `key` on every rejection, which is what rewinds the shake so the
          second wrong answer moves as much as the first did. */}
      <AnimateShake key={wrong} play={wrong > 0} className="flex-1">
        <TextField
          label="Passphrase"
          value={value}
          onChange={(event) => setValue(event.target.value)}
          error={wrong > 0 ? 'That is not it. Try \u201cneba\u201d.' : undefined}
          fullWidth
        />
      </AnimateShake>

      <Button type="submit">Unlock</Button>
    </form>
  );
}

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
      {/* The count of wrong answers, so every rejection replays the shake
          without remounting the field, and the focus stays in it. */}
      <AnimateShake play={wrong} className="flex-1">
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

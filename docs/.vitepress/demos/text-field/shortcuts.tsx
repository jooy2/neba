import { useState } from 'react';
import { Chip, Shortcut, TextField, Typography } from 'neba';

export default function TextFieldShortcuts() {
  const [draft, setDraft] = useState('');
  const [sent, setSent] = useState<string[]>([]);

  const send = () => {
    if (draft.trim() === '') return;
    setSent((all) => [...all, draft.trim()]);
    setDraft('');
  };

  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <TextField
        label="Message"
        placeholder="Write something"
        multiline
        rows={2}
        fullWidth
        value={draft}
        onChange={(event) => setDraft(event.currentTarget.value)}
        shortcuts={{
          'Mod+Enter': (event) => {
            event.preventDefault();
            send();
          },
          Escape: () => setDraft('')
        }}
        description={
          <span className="inline-flex items-center gap-1.5">
            <Shortcut size="xs" keys="Mod+Enter" /> to send, <Shortcut size="xs" keys="Esc" /> to
            clear
          </span>
        }
      />

      {sent.length > 0 ? (
        <div className="flex flex-wrap gap-1.5">
          {sent.map((message, index) => (
            <Chip key={index} size="sm">
              {message}
            </Chip>
          ))}
        </div>
      ) : (
        <Typography level="caption" className="text-(--neba-muted-fg)">
          Nothing sent yet.
        </Typography>
      )}
    </div>
  );
}

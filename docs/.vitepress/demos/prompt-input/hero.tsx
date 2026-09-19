import { useState } from 'react';
import { Chip, ContextWindow, IconButton, PromptInput, Select } from 'neba';

function ClipIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M10.5 5.5 6.2 9.8a1.9 1.9 0 0 0 2.7 2.7l4.6-4.6a3.4 3.4 0 0 0-4.8-4.8L3.6 8.2a4.9 4.9 0 0 0 7 7l3.2-3.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function PromptInputHero() {
  const [value, setValue] = useState('');
  const [sent, setSent] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  return (
    <div className="flex w-full max-w-xl flex-col gap-3">
      {sent === null ? null : (
        <p className="m-0 text-[0.8125rem] text-[var(--vp-c-text-2)]">Sent: {sent}</p>
      )}
      <PromptInput
        label="Message"
        placeholder="Ask about the design language…"
        value={value}
        onValueChange={setValue}
        submitting={submitting}
        onStop={() => setSubmitting(false)}
        onSubmit={(text) => {
          setSent(text);
          setValue('');
          setSubmitting(true);
          setTimeout(() => setSubmitting(false), 2400);
        }}
        onFiles={() => {}}
        start={
          <>
            <IconButton
              icon={<ClipIcon />}
              label="Attach a file"
              size="sm"
              variant="text"
              color="secondary"
            />
            <Select
              size="sm"
              variant="text"
              defaultValue="opus"
              aria-label="Model"
              items={[
                { value: 'opus', label: 'Opus' },
                { value: 'sonnet', label: 'Sonnet' }
              ]}
            />
          </>
        }
        end={<ContextWindow size="xs" max={200_000} used={48_000} breakdown={false} />}
      >
        <div className="flex flex-wrap gap-1.5">
          <Chip size="sm" onDelete={() => {}}>
            design-language.md
          </Chip>
        </div>
      </PromptInput>
    </div>
  );
}

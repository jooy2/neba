import { useState } from 'react';
import { PromptInput, StreamingText } from 'neba';

export default function PromptInputSubmitting() {
  const [answer, setAnswer] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const ask = () => {
    setAnswer('');
    setSubmitting(true);
    setTimeout(() => {
      setAnswer('The send button became a stop button without moving.');
      setSubmitting(false);
    }, 2000);
  };

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <StreamingText streaming={submitting} lines={2}>
        {answer}
      </StreamingText>
      <PromptInput
        label="Message"
        placeholder="Press send, then press stop"
        submitting={submitting}
        onSubmit={ask}
        onStop={() => setSubmitting(false)}
        defaultValue="Tell me about the send button"
      />
    </div>
  );
}

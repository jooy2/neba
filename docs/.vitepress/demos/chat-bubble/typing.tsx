import { useEffect, useState } from 'react';
import { Avatar, ChatBubble } from 'neba';

export default function ChatBubbleTyping() {
  const [typing, setTyping] = useState(true);

  // A message that never arrives is a demo of half the prop.
  useEffect(() => {
    const timer = setInterval(() => setTyping((current) => !current), 2600);

    return () => clearInterval(timer);
  }, []);

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble avatar={<Avatar name="Jane Doe" size="sm" />} name="Jane" typing={typing}>
        Found it — the alias was pointing at the old path.
      </ChatBubble>
    </div>
  );
}

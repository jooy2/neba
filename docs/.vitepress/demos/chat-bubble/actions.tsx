import { Avatar, ChatBubble, IconButton, Menu, MenuItem, MenuSeparator } from 'neba';

function MoreIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="3.5" r="1.15" fill="currentColor" />
      <circle cx="8" cy="8" r="1.15" fill="currentColor" />
      <circle cx="8" cy="12.5" r="1.15" fill="currentColor" />
    </svg>
  );
}

function MessageMenu() {
  return (
    <Menu
      trigger={<IconButton icon={<MoreIcon />} label="Message options" variant="text" size="sm" />}
    >
      <MenuItem>Reply</MenuItem>
      <MenuItem>Forward</MenuItem>
      <MenuItem>Copy</MenuItem>
      <MenuSeparator />
      <MenuItem color="danger">Delete</MenuItem>
    </Menu>
  );
}

export default function ChatBubbleActions() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        avatar={<Avatar name="Jane Doe" size="sm" />}
        name="Jane"
        actions={<MessageMenu />}
      >
        Hover this row, or tab into it.
      </ChatBubble>

      <ChatBubble side="end" variant="solid" status="read" actions={<MessageMenu />}>
        The handle sits on the other side here.
      </ChatBubble>
    </div>
  );
}

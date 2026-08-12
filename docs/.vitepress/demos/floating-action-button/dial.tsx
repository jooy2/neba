import { useState } from 'react';
import { FloatingAction, FloatingActionButton, Typography } from 'neba';

function LinkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M6.5 9.5a2.75 2.75 0 0 0 4 .25l1.75-1.75a2.75 2.75 0 0 0-3.9-3.9L7.75 5.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 6.5a2.75 2.75 0 0 0-4-.25L3.75 8a2.75 2.75 0 0 0 3.9 3.9l.6-.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function MailIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <rect
        x="2.25"
        y="3.75"
        width="11.5"
        height="8.5"
        rx="1.5"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path
        d="m2.75 5 5.25 3.75L13.25 5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function PrintIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M4.75 6.5v-3.5h6.5V6.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <rect
        x="2.25"
        y="6.5"
        width="11.5"
        height="5"
        rx="1.5"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path
        d="M4.75 9.5h6.5v3.75h-6.5V9.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ShareIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M8 10.5V2.75m0 0L5.25 5.5M8 2.75 10.75 5.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M3.25 9.5v3.25h9.5V9.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function FloatingActionButtonDial() {
  const [last, setLast] = useState('nothing yet');

  return (
    <div className="relative h-64 w-full max-w-sm overflow-hidden rounded-(--neba-radius-md) border [border-color:var(--neba-border)] p-4">
      <Typography level="caption" className="text-(--neba-muted-fg)">
        Last action: {last}
      </Typography>

      <FloatingActionButton position="absolute" icon={<ShareIcon />} label="Share">
        <FloatingAction
          icon={<LinkIcon />}
          label="Copy link"
          onClick={() => setLast('Copy link')}
        />
        <FloatingAction icon={<MailIcon />} label="Email" onClick={() => setLast('Email')} />
        <FloatingAction icon={<PrintIcon />} label="Print" onClick={() => setLast('Print')} />
      </FloatingActionButton>
    </div>
  );
}

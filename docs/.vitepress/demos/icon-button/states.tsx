import { useState } from 'react';
import { IconButton, Typography } from 'neba';

function RefreshIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M13 8a5 5 0 1 1-1.6-3.7"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M13 2v3h-3"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** Every Button state is here unchanged, including the spinner. */
export default function IconButtonStates() {
  const [loading, setLoading] = useState(false);

  return (
    <div className="flex flex-wrap items-center gap-4">
      <div className="flex flex-col items-center gap-2">
        <IconButton
          icon={<RefreshIcon />}
          label="Refresh"
          loading={loading}
          onClick={() => {
            setLoading(true);
            setTimeout(() => setLoading(false), 1600);
          }}
        />
        <Typography level="caption">press me</Typography>
      </div>

      <div className="flex flex-col items-center gap-2">
        <IconButton icon={<RefreshIcon />} label="Refresh" disabled />
        <Typography level="caption">disabled</Typography>
      </div>

      <div className="flex flex-col items-center gap-2">
        <IconButton icon={<RefreshIcon />} label="Refresh" readOnly />
        <Typography level="caption">readOnly</Typography>
      </div>

      <div className="flex flex-col items-center gap-2">
        <IconButton icon={<RefreshIcon />} label="Refresh" elevation={2} />
        <Typography level="caption">elevation 2</Typography>
      </div>
    </div>
  );
}

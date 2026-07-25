import { Button, ButtonGroup, Tooltip, TooltipProvider } from 'neba';

function BoldIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M5 3h4a2.5 2.5 0 0 1 0 5H5zm0 5h4.5a2.5 2.5 0 0 1 0 5H5z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ItalicIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M10 3H6.5m3 10H6m3.5-10L7 13"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function UnderlineIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4.5 3v4.5a3.5 3.5 0 0 0 7 0V3M4 13.5h8"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * One delay shared across the row: once any of these has opened, its
 * neighbours open instantly, and the wait comes back after a pause.
 */
export default function TooltipGrouped() {
  return (
    <TooltipProvider delay={400}>
      <ButtonGroup variant="outline" color="secondary">
        <Tooltip content="Bold">
          <Button startIcon={<BoldIcon />} />
        </Tooltip>
        <Tooltip content="Italic">
          <Button startIcon={<ItalicIcon />} />
        </Tooltip>
        <Tooltip content="Underline">
          <Button startIcon={<UnderlineIcon />} />
        </Tooltip>
      </ButtonGroup>
    </TooltipProvider>
  );
}

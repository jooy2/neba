import { Pill } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

function NoteIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M6 12V4l6-1.5v8"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="4.5" cy="12" r="1.75" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="10.5" cy="10.5" r="1.75" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

export default function PillHero() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <Pill startIcon={<DotIcon />} color="danger" endIcon={<span className="pe-2">02:14</span>}>
        Recording
      </Pill>

      <Pill startIcon={<NoteIcon />} variant="outline" color="primary">
        Neba — Acrylic
      </Pill>
    </div>
  );
}

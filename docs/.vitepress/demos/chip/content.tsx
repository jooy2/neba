import { Chip } from 'neba';

function BranchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M5 3v10M5 8h4a2 2 0 0 0 2-2V4"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <circle cx="5" cy="3" r="1.6" fill="currentColor" />
      <circle cx="11" cy="3" r="1.6" fill="currentColor" />
      <circle cx="5" cy="13" r="1.6" fill="currentColor" />
    </svg>
  );
}

export default function ChipContent() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Chip>Text only</Chip>
      <Chip startIcon={<BranchIcon />}>main</Chip>
      <Chip count={4}>Comments</Chip>
      <Chip variant="solid" color="danger" count={99}>
        Failing
      </Chip>
      <Chip startIcon={<BranchIcon />} count={2} color="info">
        release/1.2
      </Chip>
    </div>
  );
}

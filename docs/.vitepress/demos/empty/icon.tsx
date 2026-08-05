import { Empty } from 'neba';

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7.25" cy="7.25" r="4.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m10.6 10.6 2.65 2.65"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function EmptyIcon() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      <Empty variant="outline" title="Default" />

      <Empty variant="outline" icon={<SearchIcon />} title="Your own glyph" />

      <Empty variant="outline" icon={false} title="No glyph at all" />
    </div>
  );
}

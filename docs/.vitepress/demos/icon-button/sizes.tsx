import { Button, IconButton, Typography } from 'neba';

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.25 10.25 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

/**
 * The same control heights everything else uses, so a disc drops into a row of
 * buttons without the row losing its baseline.
 */
export default function IconButtonSizes() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end gap-4">
        {SIZES.map((size) => (
          <div key={size} className="flex flex-col items-center gap-2">
            <IconButton icon={<SearchIcon />} label={`Search, ${size}`} size={size} />
            <Typography level="caption">{size}</Typography>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <Button variant="outline">Filter</Button>
        <IconButton icon={<SearchIcon />} label="Search" variant="outline" />
        <Typography level="caption">Same height, different shape.</Typography>
      </div>
    </div>
  );
}

import { Chip } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ChipSizes() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      {SIZES.map((size) => (
        <Chip key={size} size={size} count={9}>
          {size}
        </Chip>
      ))}
    </div>
  );
}

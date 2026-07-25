import { Pagination } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function PaginationSizes() {
  return (
    <div className="flex flex-col gap-4">
      {SIZES.map((size) => (
        <Pagination key={size} size={size} count={9} defaultPage={4} />
      ))}
    </div>
  );
}

import { Box } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function BoxSizes() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-start gap-3">
        {SIZES.map((size) => (
          <Box key={size} size={size}>
            size {size}
          </Box>
        ))}
      </div>
      <div className="flex flex-wrap items-start gap-3">
        {SIZES.map((size) => (
          <Box key={size} size={size} density="compact">
            compact {size}
          </Box>
        ))}
      </div>
    </div>
  );
}

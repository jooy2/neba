import { Box, ScrollArea, Typography } from 'neba';

const sizes = ['xs', 'md', 'xl'] as const;
const LINES = Array.from({ length: 12 }, (_, index) => `Row ${index + 1}`);

export default function ScrollAreaSizes() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      {sizes.map((size) => (
        <Box key={size} variant="outline">
          <Typography level="caption" className="mb-2 block">
            {size}
          </Typography>
          <ScrollArea size={size} height={120} color="secondary">
            <div className="flex flex-col gap-1 pe-3">
              {LINES.map((line) => (
                <Typography key={line} level="body">
                  {line}
                </Typography>
              ))}
            </div>
          </ScrollArea>
        </Box>
      ))}
    </div>
  );
}

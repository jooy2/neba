import { Box, ScrollArea, Typography } from 'neba';

const LINES = Array.from({ length: 14 }, (_, index) => `Line ${index + 1}`);

export default function ScrollAreaFade() {
  return (
    <div className="grid w-full max-w-lg grid-cols-1 gap-4 sm:grid-cols-2">
      {[false, true].map((fade) => (
        <Box key={String(fade)} variant="outline">
          <Typography level="caption" className="mb-2 block">
            {fade ? 'fade' : 'no fade'}
          </Typography>
          <ScrollArea height={140} fade={fade}>
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

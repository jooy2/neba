import { Box, Chip, ScrollArea } from 'neba';

const TAGS = [
  'react',
  'typescript',
  'tailwind',
  'base-ui',
  'design-system',
  'components',
  'accessibility',
  'esm',
  'tree-shaking',
  'dark-mode'
];

export default function ScrollAreaOrientation() {
  return (
    <Box variant="outline" className="w-full max-w-sm">
      <ScrollArea orientation="horizontal" fade>
        <div className="flex w-max items-center gap-2 pb-3">
          {TAGS.map((tag) => (
            <Chip key={tag} size="sm">
              {tag}
            </Chip>
          ))}
        </div>
      </ScrollArea>
    </Box>
  );
}

import { Box, Container } from 'neba';

const WIDTHS = ['xs', 'sm', 'md', 'none'] as const;

export default function ContainerMaxWidth() {
  return (
    <div className="flex w-full flex-col gap-3">
      {WIDTHS.map((maxWidth) => (
        <div
          key={maxWidth}
          className="w-full rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft-press)]"
        >
          <Container maxWidth={maxWidth} size="sm">
            <Box size="sm" className="text-center">
              maxWidth {maxWidth}
            </Box>
          </Container>
        </div>
      ))}
    </div>
  );
}

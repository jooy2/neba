import { Box, Container } from 'neba';

export default function ContainerPlain() {
  return (
    <div className="flex w-full flex-col gap-3">
      {/* No gutter, but still centred and still measured. */}
      <div className="w-full rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft-press)]">
        <Container maxWidth="sm" padded={false}>
          <Box size="sm" className="text-center">
            padded={'{false}'}
          </Box>
        </Container>
      </div>

      {/* Measured, but held against the start edge instead of centred. */}
      <div className="w-full rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft-press)]">
        <Container maxWidth="sm" centered={false} size="sm">
          <Box size="sm" className="text-center">
            centered={'{false}'}
          </Box>
        </Container>
      </div>

      {/* Any element you like — a page's real `<main>`. */}
      <div className="w-full rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft-press)]">
        <Container render={<main />} size="sm">
          <Box size="sm" className="text-center">
            render={'{<main />}'}
          </Box>
        </Container>
      </div>
    </div>
  );
}

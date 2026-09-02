import { Box, Container } from 'neba';

export default function ContainerResponsive() {
  return (
    <div className="w-full rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft-press)]">
      {/* Full width on a phone, held at 48rem from md, at 64rem from lg.
          Resize the window and the sheet stops growing twice. */}
      <Container maxWidth={{ xs: 'none', md: 'md', lg: 'lg' }} size="sm">
        <Box size="sm" className="text-center">
          none · md 48rem · lg 64rem
        </Box>
      </Container>
    </div>
  );
}

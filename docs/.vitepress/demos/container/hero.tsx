import { Box, Container } from 'neba';

export default function ContainerHero() {
  return (
    <div className="w-full rounded-(--neba-radius-md) bg-[var(--neba-primary-soft-press)]">
      <Container>
        <Box>The tinted band is the page. The gutter either side of me is the Container.</Box>
      </Container>
    </div>
  );
}

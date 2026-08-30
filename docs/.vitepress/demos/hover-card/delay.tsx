import { HoverCard, TextLink, Typography } from 'neba';

export default function HoverCardDelay() {
  return (
    <div className="flex flex-col items-center gap-4">
      <Typography level="body">
        <HoverCard
          delay={0}
          trigger={<TextLink href="#now">Opens at once</TextLink>}
          title="delay 0"
        >
          The card is up on the first frame the pointer is over the link.
        </HoverCard>
      </Typography>
      <Typography level="body">
        <HoverCard
          delay={700}
          closeDelay={400}
          trigger={<TextLink href="#later">Waits 700ms</TextLink>}
          title="delay 700"
        >
          Long enough that crossing a paragraph of links opens none of them.
        </HoverCard>
      </Typography>
    </div>
  );
}

import { Avatar, Chip, HoverCard, TextLink, Typography } from 'neba';

export default function HoverCardHero() {
  return (
    <Typography level="body" className="max-w-md text-center">
      Reviewed by{' '}
      <HoverCard
        trigger={<TextLink href="#nadiarowan">@nadiarowan</TextLink>}
        title="Nadia Rowan"
        description="Seoul · joined 2019"
      >
        <div className="flex items-center gap-3">
          <Avatar src="/samples/people/nadia-rowan.jpg" name="Nadia Rowan" size="lg" />
          <div className="flex flex-wrap gap-1.5">
            <Chip size="xs">Maintainer</Chip>
            <Chip size="xs" color="info">
              214 commits
            </Chip>
          </div>
        </div>
      </HoverCard>{' '}
      on 12 March.
    </Typography>
  );
}

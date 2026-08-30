import { Avatar, Chip, HoverCard, TextLink, Typography } from 'neba';

export default function HoverCardHero() {
  return (
    <Typography level="body" className="max-w-md text-center">
      Reviewed by{' '}
      <HoverCard
        trigger={<TextLink href="#jooy2">@jooy2</TextLink>}
        title="Jooy Lee"
        description="Seoul · joined 2019"
      >
        <div className="flex items-center gap-3">
          <Avatar name="Jooy Lee" size="lg" />
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

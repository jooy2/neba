import { Box, Button, Card, TextField } from 'neba';

/**
 * The home page's hero object.
 *
 * Not a screenshot and not a logo — the four components the library ships,
 * assembled into one thing, floating over the blurred blob VitePress puts
 * behind the hero image. That blob is the point: acrylic has nothing to show
 * over a flat page, and this is the first surface a visitor sees.
 *
 * The two accents are absolutely positioned and hidden below `sm`, where the
 * hero image area is a fixed square and they would collide with the card.
 */
export default function HomeHero() {
  return (
    <div className="relative w-full max-w-[21rem]">
      <Box
        className="absolute -top-7 -left-10 z-10 hidden sm:block"
        size="sm"
        variant="solid"
        color="info"
        elevation={2}
      >
        <div className="text-[0.6875rem] leading-none font-medium">@base-ui/react</div>
      </Box>

      <Card
        dividers
        elevation={3}
        title="Create account"
        subtitle="No credit card required."
        footer={<Button fullWidth>Continue</Button>}
      >
        <div className="flex flex-col gap-3">
          <TextField label="Email" defaultValue="jane@example.com" fullWidth />
          <TextField label="Password" type="password" defaultValue="acrylic" fullWidth />
        </div>
      </Card>

      <div className="absolute -right-8 -bottom-6 z-10 hidden gap-2 sm:flex">
        <Button size="sm" color="success" elevation={2}>
          Deployed
        </Button>
      </div>
    </div>
  );
}

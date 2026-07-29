import { Box, Button, Card, Chip, Select, Switch, TextField } from 'neba';

const REGIONS = [
  { value: 'icn', label: 'Seoul' },
  { value: 'nrt', label: 'Tokyo' },
  { value: 'fra', label: 'Frankfurt' },
  { value: 'iad', label: 'Washington DC' }
];

/**
 * The home page's hero object.
 *
 * Not a screenshot and not a logo — a settings panel, the screen almost every
 * app ends up with, assembled out of the components the library ships and
 * floating over the blurred blob VitePress puts behind the hero image. That
 * blob is the point: acrylic has nothing to show over a flat page, and this is
 * the first surface a visitor sees.
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
        color="success"
        elevation={2}
      >
        <div className="text-[0.6875rem] leading-none font-medium">All changes saved</div>
      </Box>

      <Card
        dividers
        elevation={3}
        title="Project settings"
        subtitle="Applies to every environment."
        footer={<Button fullWidth>Save changes</Button>}
      >
        <div className="flex flex-col gap-3">
          <TextField label="Project name" defaultValue="Acme Web" fullWidth />
          <Select items={REGIONS} label="Region" defaultValue="icn" fullWidth />
          <Switch label="Email alerts" defaultChecked />
        </div>
      </Card>

      <div className="absolute -right-8 -bottom-6 z-10 hidden gap-2 sm:flex">
        <Chip variant="solid" color="primary" elevation={2}>
          Production
        </Chip>
        <Chip elevation={2}>Staging</Chip>
      </div>
    </div>
  );
}

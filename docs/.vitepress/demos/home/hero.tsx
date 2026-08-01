import { Button, Card, Select, Statistic, Switch, TextField } from 'neba';

const REGIONS = [
  { value: 'icn', label: 'Seoul' },
  { value: 'nrt', label: 'Tokyo' },
  { value: 'fra', label: 'Frankfurt' },
  { value: 'iad', label: 'Washington DC' }
];

/**
 * The home page's hero object.
 *
 * Not a screenshot and not a logo — two rows of a real product screen,
 * assembled out of the components the library ships and floating over the
 * blurred blob VitePress puts behind the hero image. That blob is the point:
 * acrylic has nothing to show over a flat page, and this is the first surface a
 * visitor sees.
 *
 * Two rows rather than one card, because one card only shows the half of the
 * library that takes input. The settings panel is the screen almost every app
 * ends up with; the band under it is what the same page reports back.
 *
 * The two grids inside reflow on `@container` and not on `sm:`, because a
 * viewport breakpoint answers the wrong question here. The hero's image slot is
 * whatever is left after a 592px column of type, so between 960px and about
 * 1180px the viewport is wide while this column is 240px — and a `sm:`
 * two-column grid would hold a min-content width the column cannot give it and
 * lay the panel over the heading. Sized against the container, it stacks.
 */
export default function HomeHero() {
  return (
    <div className="@container flex w-full max-w-[32rem] flex-col gap-3">
      <Card
        dividers
        elevation={3}
        title="Project settings"
        subtitle="Applies to every environment."
        footer={<Button fullWidth>Save changes</Button>}
      >
        <div className="flex flex-col gap-3">
          <div className="grid gap-3 @md:grid-cols-2">
            <TextField label="Project name" defaultValue="Acme Web" fullWidth />
            <Select items={REGIONS} label="Region" defaultValue="icn" fullWidth />
          </div>
          <Switch label="Email alerts" defaultChecked />
        </div>
      </Card>

      <div className="grid gap-3 @xs:grid-cols-3">
        <Statistic size="sm" elevation={2} label="Deploys" value={128} previousValue={112} />
        <Statistic size="sm" elevation={2} label="p95" value="84ms" />
        <Statistic
          size="sm"
          elevation={2}
          label="Error rate"
          value={0.0021}
          format={{ style: 'percent', maximumFractionDigits: 2 }}
          previousValue={0.0034}
          betterWhen="down"
        />
      </div>
    </div>
  );
}

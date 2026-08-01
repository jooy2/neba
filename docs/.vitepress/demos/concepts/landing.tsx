import { useState, type ReactNode } from 'react';
import {
  Accordion,
  AccordionItem,
  Avatar,
  Blockquote,
  Button,
  Card,
  Chip,
  Container,
  Divider,
  Grid,
  GridContainer,
  Highlight,
  Icon,
  IconButton,
  List,
  ListItem,
  Pill,
  ProgressLinear,
  Segment,
  SegmentedButton,
  Statistic,
  Tab,
  TabPanel,
  Table,
  Tabs,
  TextField,
  Toolbar,
  Tooltip,
  Typography,
  type TableColumn
} from 'neba';

/**
 * A marketing page for a product that does not exist.
 *
 * A landing page is the case the component library is least obviously for — it
 * is mostly type, space and one repeated call to action — so it is the one that
 * says most about whether the parts compose. Everything here is a Neba
 * component; nothing is a one-off div pretending to be one.
 *
 * The copy stays in English in both locales: it is a code sample, and the prose
 * explaining it lives in the Markdown around the preview.
 */

function LogoIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 1.5 14 5v6l-6 3.5L2 11V5l6-3.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8 8v6.5M8 8l6-3M8 8 2 5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function BoltIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M9 1.5 3.5 9H8l-1 5.5L12.5 7H8l1-5.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ShieldIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 1.75 13 3.5v4.25c0 3-2.1 5.2-5 6.5-2.9-1.3-5-3.5-5-6.5V3.5L8 1.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="m5.75 7.75 1.75 1.75L10.5 6.5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function GraphIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M2.5 13.5h11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path
        d="M3.5 10.5 6.5 7l2.5 2.5 4-5.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function PlugIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M6 1.5v3.5M10 1.5v3.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M4 5h8v2.5A4 4 0 0 1 8 11.5 4 4 0 0 1 4 7.5V5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8 11.5v3" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m3.5 8.5 3 3 6-7"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ArrowIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3.5 8h9m-3.5-4 4 4-4 4"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function GithubIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
      <path d="M8 .5a7.5 7.5 0 0 0-2.37 14.62c.37.07.5-.16.5-.36v-1.3c-2.09.46-2.53-1-2.53-1-.34-.87-.83-1.1-.83-1.1-.68-.47.05-.46.05-.46.75.05 1.15.78 1.15.78.67 1.15 1.76.82 2.19.63.07-.49.26-.82.48-1.01-1.67-.19-3.42-.84-3.42-3.72 0-.82.29-1.5.77-2.02-.08-.19-.34-.95.07-1.98 0 0 .63-.2 2.06.77a7.1 7.1 0 0 1 3.75 0c1.43-.97 2.06-.77 2.06-.77.41 1.03.15 1.79.08 1.98.48.52.77 1.2.77 2.02 0 2.89-1.76 3.53-3.43 3.71.27.24.51.69.51 1.39v2.06c0 .2.13.44.51.36A7.5 7.5 0 0 0 8 .5Z" />
    </svg>
  );
}

const NAV = ['Product', 'Integrations', 'Docs', 'Pricing'];

const TRUSTED_BY = ['Northwind', 'Acme Rail', 'Kite & Co', 'Belltower', 'Ordinary Coffee'];

const FEATURES = [
  {
    icon: <BoltIcon />,
    color: 'primary' as const,
    title: 'Answers in one second',
    body: 'Queries run against a columnar store built for the shape of product data, so a funnel over a year of events comes back before you look away.'
  },
  {
    icon: <GraphIcon />,
    color: 'info' as const,
    title: 'Funnels without SQL',
    body: 'Pick the steps, set the window, read the drop-off. Every chart keeps the query that made it, so anyone can open it up and change one step.'
  },
  {
    icon: <ShieldIcon />,
    color: 'success' as const,
    title: 'Yours, and only yours',
    body: 'SOC 2 Type II, per-region storage and a retention window you set. No third-party pixels, no reselling, no exceptions.'
  },
  {
    icon: <PlugIcon />,
    color: 'secondary' as const,
    title: 'Wired up in an afternoon',
    body: 'SDKs for the six runtimes you actually ship, a warehouse sync both ways, and an HTTP endpoint for everything else.'
  }
];

/** `caption` is per figure, since the last one has nothing to compare against. */
const STATS = [
  {
    label: 'Events ingested daily',
    value: 4.2,
    unit: 'B',
    previousValue: 3.1,
    caption: 'vs. last year'
  },
  {
    label: 'Median query time',
    value: 240,
    unit: 'ms',
    previousValue: 410,
    betterWhen: 'down' as const,
    caption: 'vs. last year'
  },
  { label: 'Teams on board', value: 12400, previousValue: 9800, caption: 'vs. last year' },
  { label: 'Uptime, trailing year', value: '99.98%', caption: 'Measured externally' }
];

interface PlanRow {
  id: string;
  feature: string;
  free: ReactNode;
  team: ReactNode;
  scale: ReactNode;
}

const yes = <Icon icon={<CheckIcon />} size="sm" color="success" label="Included" />;
const no = (
  <Typography level="caption" className="text-(--neba-muted-fg)">
    —
  </Typography>
);

const PLAN_ROWS: PlanRow[] = [
  { id: 'events', feature: 'Monthly events', free: '50k', team: '5M', scale: 'Unlimited' },
  { id: 'retention', feature: 'Retention', free: '30 days', team: '2 years', scale: 'Custom' },
  { id: 'seats', feature: 'Seats', free: '3', team: 'Unlimited', scale: 'Unlimited' },
  { id: 'warehouse', feature: 'Warehouse sync', free: no, team: yes, scale: yes },
  { id: 'sso', feature: 'SAML SSO', free: no, team: no, scale: yes },
  { id: 'sla', feature: 'Support SLA', free: no, team: 'Next business day', scale: '1 hour' }
];

const PLAN_COLUMNS: TableColumn<PlanRow>[] = [
  { key: 'feature', label: '', width: 220 },
  { key: 'free', label: 'Free', align: 'center', width: 120 },
  { key: 'team', label: 'Team', align: 'center', width: 160 },
  { key: 'scale', label: 'Scale', align: 'center', width: 160 }
];

const PLANS = [
  {
    id: 'free',
    name: 'Free',
    monthly: 0,
    tagline: 'For the first prototype.',
    features: ['50k events a month', '3 seats', '30-day retention', 'Community support'],
    color: 'secondary' as const,
    variant: 'outline' as const
  },
  {
    id: 'team',
    name: 'Team',
    monthly: 49,
    tagline: 'For a product with users.',
    features: [
      '5M events a month',
      'Unlimited seats',
      '2-year retention',
      'Warehouse sync both ways'
    ],
    color: 'primary' as const,
    variant: 'solid' as const,
    featured: true
  },
  {
    id: 'scale',
    name: 'Scale',
    monthly: 199,
    tagline: 'For a product with customers.',
    features: ['Unlimited events', 'SAML SSO and SCIM', 'Custom retention', '1-hour support SLA'],
    color: 'secondary' as const,
    variant: 'outline' as const
  }
];

const FAQ = [
  {
    value: 'migrate',
    title: 'Can we bring our existing events with us?',
    body: 'Yes. Point the importer at an S3 prefix or a warehouse table and it backfills in the background; the workspace stays usable while it runs.'
  },
  {
    value: 'sampling',
    title: 'Do you sample?',
    body: 'Never on ingest. Every event you send is stored and queryable. Sampling is something you can turn on per query when you want a faster answer to a rough question.'
  },
  {
    value: 'self-host',
    title: 'Is there a self-hosted option?',
    body: 'On the Scale plan. It runs on your own Kubernetes cluster and object storage, and updates on the same weekly train as the hosted build.'
  },
  {
    value: 'leaving',
    title: 'What happens to our data if we leave?',
    body: 'A full export in Parquet, on demand, at any point — including after the account is closed. There is no lock-in worth having.'
  }
];

const FOOTER = [
  { heading: 'Product', links: ['Overview', 'Funnels', 'Cohorts', 'Warehouse sync', 'Changelog'] },
  { heading: 'Developers', links: ['Documentation', 'SDKs', 'HTTP API', 'Status'] },
  { heading: 'Company', links: ['About', 'Careers', 'Blog', 'Security', 'Contact'] }
];

export default function LandingConcept() {
  const [yearly, setYearly] = useState(true);
  const [email, setEmail] = useState('');
  const [signedUp, setSignedUp] = useState(false);

  const emailValid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);

  const price = (monthly: number) => (yearly ? Math.round(monthly * 0.8) : monthly);

  return (
    <div className="flex flex-col">
      {/* The announcement bar: the one live-ish readout above the fold, in the
        shape that exists for exactly that. */}
      <Pill
        color="primary"
        variant="text"
        size="sm"
        className="mx-auto"
        startIcon={<BoltIcon />}
        title="Kestrel 2.0 — funnels, retention and paths in one query"
        endIcon={<ArrowIcon />}
        onClick={() => {}}
      />

      <Container maxWidth="xl" render={<main />}>
        <div className="flex flex-col gap-16 py-6">
          {/* A marketing header is a landmark like any other, so it says so. */}
          <Toolbar
            render={<header />}
            variant="text"
            density="compact"
            start={
              <>
                <Icon icon={<LogoIcon />} size="lg" color="primary" label="Kestrel" />
                <Typography level="h6">Kestrel</Typography>
                <div className="ms-3 hidden items-center gap-1 md:flex">
                  {NAV.map((item) => (
                    <Button key={item} size="sm" variant="text" color="secondary">
                      {item}
                    </Button>
                  ))}
                </div>
              </>
            }
            end={
              <>
                <Tooltip content="Star us on GitHub">
                  <IconButton
                    icon={<GithubIcon />}
                    label="GitHub"
                    size="sm"
                    variant="text"
                    color="secondary"
                  />
                </Tooltip>
                <Button size="sm" variant="text" color="secondary">
                  Sign in
                </Button>
                <Button size="sm" endIcon={<ArrowIcon />}>
                  Start free
                </Button>
              </>
            }
          />

          {/* Hero. Type does the work; the only decoration is the chip. */}
          <section className="flex flex-col items-center gap-5 pt-6 text-center">
            <Chip size="sm" variant="outline" color="primary" startIcon={<BoltIcon />}>
              Now with warehouse sync
            </Chip>
            <Typography level="h1" align="center" className="max-w-[22ch]">
              Product analytics that answer back
            </Typography>
            <Typography level="lead" align="center" className="max-w-[56ch] text-(--neba-muted-fg)">
              <Highlight query={['one second', 'without SQL']}>
                Kestrel keeps every event you send and answers questions about them in one second,
                without SQL and without a data team standing between you and the number.
              </Highlight>
            </Typography>
            <div className="flex flex-wrap items-center justify-center gap-2">
              <Button size="lg" endIcon={<ArrowIcon />}>
                Start free
              </Button>
              <Button size="lg" variant="outline" color="secondary">
                Book a walkthrough
              </Button>
            </div>
            <div className="flex items-center gap-2">
              <div className="flex -space-x-2">
                {['Ada Bell', 'Jun Park', 'Mira Osei', 'Tom Vale'].map((person) => (
                  <Avatar
                    key={person}
                    size="sm"
                    name={person}
                    color="secondary"
                    className="ring-2 ring-(--neba-bg)"
                  />
                ))}
              </div>
              <Typography level="caption" className="text-(--neba-muted-fg)">
                12,400 teams, no credit card
              </Typography>
            </div>
          </section>

          {/* The trust strip. A divider with content in it is the whole section. */}
          <section className="flex flex-col gap-5">
            <Divider size="sm">
              <Typography level="overline" className="text-(--neba-muted-fg)">
                Trusted by
              </Typography>
            </Divider>
            <div className="flex flex-wrap items-center justify-center gap-x-8 gap-y-3">
              {TRUSTED_BY.map((name) => (
                <Typography key={name} level="h6" className="text-(--neba-muted-fg)">
                  {name}
                </Typography>
              ))}
            </div>
          </section>

          {/* The numbers, on the grid — which arranges and draws nothing. */}
          <section>
            <GridContainer spacing={3} padded={false}>
              {STATS.map((stat) => (
                <Grid key={stat.label} span={{ xs: 6, md: 3 }}>
                  <Statistic
                    label={stat.label}
                    value={stat.value}
                    unit={stat.unit}
                    previousValue={stat.previousValue}
                    betterWhen={stat.betterWhen}
                    caption={stat.caption}
                    className="h-full"
                  />
                </Grid>
              ))}
            </GridContainer>
          </section>

          {/* Features. Four cards on the same grid, each one a Card doing what a
            Card does — a heading, a body and an icon in the header slot. */}
          <section className="flex flex-col gap-6">
            <div className="flex flex-col items-center gap-2 text-center">
              <Typography level="overline" color="primary">
                Why Kestrel
              </Typography>
              <Typography level="h2" align="center">
                Everything the question needs, nothing it does not
              </Typography>
            </div>
            <GridContainer spacing={3} padded={false}>
              {FEATURES.map((feature) => (
                <Grid key={feature.title} span={{ xs: 12, md: 6 }}>
                  <Card
                    variant="outline"
                    className="h-full"
                    title={feature.title}
                    headerAction={<Icon icon={feature.icon} size="lg" color={feature.color} />}
                  >
                    <Typography level="body" className="text-(--neba-muted-fg)">
                      {feature.body}
                    </Typography>
                  </Card>
                </Grid>
              ))}
            </GridContainer>
          </section>

          {/* The product tour: one tab per capability, each showing the thing
            rather than describing it. */}
          <section className="flex flex-col gap-6">
            <div className="flex flex-col items-center gap-2 text-center">
              <Typography level="overline" color="primary">
                A look inside
              </Typography>
              <Typography level="h2" align="center">
                The same events, asked three ways
              </Typography>
            </div>
            <Tabs defaultValue="funnels" size="sm">
              <Tab value="funnels">Funnels</Tab>
              <Tab value="retention">Retention</Tab>
              <Tab value="paths">Paths</Tab>

              <TabPanel value="funnels">
                <Card variant="solid" title="Signup → first query" subtitle="Last 30 days">
                  <div className="flex flex-col gap-4">
                    {[
                      { step: 'Visited pricing', value: 100, count: '38,204' },
                      { step: 'Created account', value: 41, count: '15,663' },
                      { step: 'Sent first event', value: 26, count: '9,932' },
                      { step: 'Ran first query', value: 19, count: '7,258' }
                    ].map((step) => (
                      <ProgressLinear
                        key={step.step}
                        value={step.value}
                        label={`${step.step} · ${step.count}`}
                        showValue
                        color="primary"
                      />
                    ))}
                  </div>
                </Card>
              </TabPanel>

              <TabPanel value="retention">
                <Card variant="solid" title="Weekly retention" subtitle="Cohorts by signup week">
                  <div className="flex flex-col gap-4">
                    {[
                      { step: 'Week 1', value: 100 },
                      { step: 'Week 2', value: 62 },
                      { step: 'Week 4', value: 48 },
                      { step: 'Week 8', value: 44 }
                    ].map((step) => (
                      <ProgressLinear
                        key={step.step}
                        value={step.value}
                        label={step.step}
                        showValue
                        color="success"
                      />
                    ))}
                  </div>
                </Card>
              </TabPanel>

              <TabPanel value="paths">
                <Card variant="solid" title="Where people go next" subtitle="After the first query">
                  <List variant="text" size="sm" dividers>
                    <ListItem
                      description="34% of sessions"
                      action={
                        <Chip size="xs" variant="text" color="success">
                          Saved
                        </Chip>
                      }
                    >
                      Saved the query to a dashboard
                    </ListItem>
                    <ListItem
                      description="28% of sessions"
                      action={
                        <Chip size="xs" variant="text" color="info">
                          Shared
                        </Chip>
                      }
                    >
                      Invited a teammate
                    </ListItem>
                    <ListItem
                      description="19% of sessions"
                      action={
                        <Chip size="xs" variant="text" color="warning">
                          Dropped
                        </Chip>
                      }
                    >
                      Left without saving
                    </ListItem>
                  </List>
                </Card>
              </TabPanel>
            </Tabs>
          </section>

          {/* One quote, attributed. A Blockquote is the component for it. */}
          <section className="flex justify-center">
            <Blockquote
              variant="outline"
              size="lg"
              author="Mira Osei"
              source="Head of Product, Belltower"
              className="max-w-[64ch]"
            >
              We replaced two dashboards and a weekly export with one saved query. The part nobody
              expected is that support now answers their own questions.
            </Blockquote>
          </section>

          {/* Pricing. The toggle is a SegmentedButton because it is a choice of
            one from a small set, which is the shape's whole job. */}
          <section className="flex flex-col gap-6">
            <div className="flex flex-col items-center gap-3 text-center">
              <Typography level="overline" color="primary">
                Pricing
              </Typography>
              <Typography level="h2" align="center">
                Priced by events, not by seats
              </Typography>
              <SegmentedButton
                size="sm"
                aria-label="Billing period"
                value={yearly ? 'yearly' : 'monthly'}
                onValueChange={(value) => setYearly(value === 'yearly')}
              >
                <Segment value="monthly">Monthly</Segment>
                <Segment value="yearly">Yearly · save 20%</Segment>
              </SegmentedButton>
            </div>

            <GridContainer spacing={3} padded={false}>
              {PLANS.map((plan) => (
                <Grid key={plan.id} span={{ xs: 12, md: 4 }}>
                  <Card
                    className="h-full"
                    variant={plan.variant}
                    color={plan.color}
                    elevation={plan.featured ? 2 : 0}
                    title={plan.name}
                    subtitle={plan.tagline}
                    headerAction={
                      plan.featured ? (
                        <Chip size="xs" variant="solid" color="primary">
                          Most picked
                        </Chip>
                      ) : undefined
                    }
                    footer={
                      <Button
                        fullWidth
                        color={plan.featured ? 'primary' : 'secondary'}
                        variant={plan.featured ? 'solid' : 'outline'}
                      >
                        {plan.monthly === 0 ? 'Start free' : `Choose ${plan.name}`}
                      </Button>
                    }
                  >
                    <div className="flex flex-col gap-4">
                      <div className="flex items-baseline gap-1">
                        <Typography level="h2">${price(plan.monthly)}</Typography>
                        <Typography level="caption" className="text-(--neba-muted-fg)">
                          / month
                        </Typography>
                      </div>
                      <List variant="text" size="sm" density="compact">
                        {plan.features.map((feature) => (
                          <ListItem
                            key={feature}
                            startIcon={
                              <Icon
                                icon={<CheckIcon />}
                                size="sm"
                                color={plan.featured ? 'primary' : 'success'}
                              />
                            }
                          >
                            {feature}
                          </ListItem>
                        ))}
                      </List>
                    </div>
                  </Card>
                </Grid>
              ))}
            </GridContainer>

            {/* The comparison table. Rendered from a column list, so the
              headings and the cells cannot drift apart. */}
            <Table
              headers={PLAN_COLUMNS}
              items={PLAN_ROWS}
              getRowKey={(row) => row.id}
              size="sm"
              hoverable
            />
          </section>

          {/* FAQ — the accordion's actual use, not a decorative one. */}
          <section className="flex flex-col gap-6">
            <Typography level="h2" align="center">
              Questions people ask first
            </Typography>
            <Accordion variant="outline" className="mx-auto w-full max-w-[64rem]">
              {FAQ.map((item) => (
                <AccordionItem key={item.value} value={item.value} title={item.title}>
                  {item.body}
                </AccordionItem>
              ))}
            </Accordion>
          </section>

          {/* The last call to action, and the only field on the page. */}
          <section>
            <Card variant="solid" color="primary" elevation={2} className="text-center">
              <div className="mx-auto flex max-w-[44rem] flex-col items-center gap-4 py-6">
                <Typography level="h2" align="center">
                  Send your first event today
                </Typography>
                <Typography level="body" align="center" className="text-(--neba-muted-fg)">
                  The free plan does not expire and does not ask for a card. Most teams have a
                  funnel on screen inside an hour.
                </Typography>
                <form
                  className="flex w-full max-w-[28rem] flex-wrap items-start gap-2"
                  onSubmit={(event) => {
                    event.preventDefault();
                    if (emailValid) {
                      setSignedUp(true);
                    }
                  }}
                >
                  <TextField
                    className="grow"
                    type="email"
                    placeholder="you@company.com"
                    aria-label="Work email"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    error={!email || emailValid ? undefined : 'Enter a valid address.'}
                  />
                  <Button type="submit" endIcon={<ArrowIcon />}>
                    {signedUp ? 'Check your inbox' : 'Start free'}
                  </Button>
                </form>
              </div>
            </Card>
          </section>

          {/* Footer. Three link columns and a rule, and the rule is a Divider. */}
          <footer className="flex flex-col gap-6">
            <Divider />
            <GridContainer spacing={3} padded={false}>
              <Grid span={{ xs: 12, md: 3 }}>
                <div className="flex flex-col gap-2">
                  <div className="flex items-center gap-2">
                    <Icon icon={<LogoIcon />} size="md" color="primary" label="Kestrel" />
                    <Typography level="h6">Kestrel</Typography>
                  </div>
                  <Typography level="caption" className="text-(--neba-muted-fg)">
                    Product analytics for teams who would rather read the answer than write the
                    query.
                  </Typography>
                </div>
              </Grid>
              {FOOTER.map((column) => (
                <Grid key={column.heading} span={{ xs: 6, md: 3 }}>
                  <div className="flex flex-col gap-2">
                    <Typography level="overline" className="text-(--neba-muted-fg)">
                      {column.heading}
                    </Typography>
                    <List variant="text" size="sm" density="compact">
                      {column.links.map((link) => (
                        <ListItem key={link} href="#">
                          {link}
                        </ListItem>
                      ))}
                    </List>
                  </div>
                </Grid>
              ))}
            </GridContainer>
            <Divider />
            <div className="flex flex-wrap items-center justify-between gap-3">
              <Typography level="caption" className="text-(--neba-muted-fg)">
                © 2026 Kestrel Analytics. A fictional product, built out of Neba components.
              </Typography>
              <div className="flex items-center gap-1">
                <Button size="xs" variant="text" color="secondary">
                  Privacy
                </Button>
                <Button size="xs" variant="text" color="secondary">
                  Terms
                </Button>
                <Button size="xs" variant="text" color="secondary">
                  Status
                </Button>
              </div>
            </div>
          </footer>
        </div>
      </Container>
    </div>
  );
}

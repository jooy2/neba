import { useState, type ReactNode } from 'react';
import {
  Accordion,
  AccordionItem,
  Alert,
  Badge,
  Box,
  Button,
  ButtonGroup,
  Card,
  Checkbox,
  Chip,
  ContextMenu,
  Dialog,
  DialogClose,
  Divider,
  FilePicker,
  List,
  ListItem,
  Menu,
  MenuCheckboxItem,
  MenuGroup,
  MenuItem,
  MenuSeparator,
  MenuSubmenu,
  Pagination,
  ProgressBox,
  ProgressCircular,
  ProgressLinear,
  Radio,
  RadioGroup,
  Select,
  Slider,
  Switch,
  Tab,
  Table,
  TabPanel,
  Tabs,
  TextField,
  ToastProvider,
  Tooltip,
  Typography,
  useToast,
  type TableColumn
} from 'neba';

/**
 * One sample screen rather than a grid of specimens: every component in the
 * library appears once, doing the job it exists for, on a page that could
 * plausibly ship. The acrylic only means anything over real content, so the
 * parts are arranged as a product screen would arrange them.
 *
 * The copy stays in English in both locales — it is a sample application, and
 * the prose explaining it lives in the Markdown around the preview.
 */

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function BellIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M4 6.5a4 4 0 0 1 8 0c0 3 1 4 1 4H3s1-1 1-4Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M6.5 13a1.5 1.5 0 0 0 3 0" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.5 10.5 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

const STATS = [
  { label: 'Deploys', value: '128', color: 'primary' as const },
  { label: 'Review apps', value: '9', color: 'info' as const },
  { label: 'Failing', value: '2', color: 'danger' as const }
];

const REGIONS = [
  { value: 'icn', label: 'Seoul' },
  { value: 'nrt', label: 'Tokyo' },
  { value: 'fra', label: 'Frankfurt' },
  { value: 'iad', label: 'Washington DC' }
];

interface Deploy {
  id: string;
  environment: string;
  status: 'Live' | 'Building' | 'Failed';
  duration: string;
}

const DEPLOYS: Deploy[] = [
  { id: '1', environment: 'production', status: 'Live', duration: '4m 02s' },
  { id: '2', environment: 'staging', status: 'Building', duration: '1m 48s' },
  { id: '3', environment: 'preview/1284', status: 'Failed', duration: '0m 51s' }
];

const DEPLOY_COLUMNS: TableColumn<Deploy>[] = [
  { key: 'environment', label: 'Environment', width: 200 },
  {
    key: 'status',
    label: 'Status',
    width: 130,
    render: (row) => (
      <Chip
        size="xs"
        variant="text"
        color={row.status === 'Live' ? 'success' : row.status === 'Failed' ? 'danger' : 'info'}
      >
        {row.status}
      </Chip>
    )
  },
  { key: 'duration', label: 'Duration', align: 'end' }
];

function Caption({ children }: { children: ReactNode }) {
  return (
    <div className="text-[0.6875rem] tracking-wide text-[var(--neba-muted-fg)] uppercase">
      {children}
    </div>
  );
}

export default function Showcase() {
  // The provider has to be above whatever calls `useToast`, so the screen is
  // the host and its body is a child.
  return (
    <ToastProvider position="bottom-end">
      <ShowcaseBody />
    </ToastProvider>
  );
}

function ShowcaseBody() {
  const toast = useToast();
  const [name, setName] = useState('Jane Doe');
  const [email, setEmail] = useState('jane@example.com');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [region, setRegion] = useState<string | number | null>('icn');
  const [tags, setTags] = useState(['react', 'tailwind', 'base-ui']);
  const [page, setPage] = useState(1);
  const [attachments, setAttachments] = useState<File[]>([]);

  const emailValid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);

  const save = () => {
    if (!emailValid) {
      return;
    }
    setSaving(true);
    setSaved(false);
    setTimeout(() => {
      setSaving(false);
      setSaved(true);
      toast.add({ color: 'success', title: 'Profile saved', description: 'Just now' });
    }, 900);
  };

  return (
    <div className="flex flex-col gap-8">
      {/* Toolbar — the controls that run a screen, all on one baseline. */}
      <section className="flex flex-col gap-3">
        <Caption>Button · ButtonGroup · TextField · Select · Tooltip · Menu · Badge</Caption>
        <div className="flex flex-wrap items-center gap-2">
          <TextField size="sm" startIcon={<SearchIcon />} placeholder="Search projects" />
          <Select
            size="sm"
            items={REGIONS}
            value={region}
            onValueChange={setRegion}
            placeholder="Region"
          />
          <ButtonGroup size="sm" variant="outline" color="secondary">
            <Button>Day</Button>
            <Button>Week</Button>
            <Button>Month</Button>
          </ButtonGroup>
          <div className="grow" />

          {/* A badge is the one component that overlaps its neighbour, so the
              row still measures as if it were not there. */}
          <Badge content={3} color="danger" label="3 failing builds">
            <Button size="sm" variant="outline" color="secondary" startIcon={<BellIcon />} />
          </Badge>

          <Tooltip content="Import from a Git provider">
            <Button size="sm" variant="outline" color="secondary">
              Import
            </Button>
          </Tooltip>

          <Menu
            size="sm"
            trigger={
              <Button size="sm" variant="outline" color="secondary">
                View
              </Button>
            }
          >
            <MenuGroup label="Columns">
              <MenuCheckboxItem defaultChecked>Status</MenuCheckboxItem>
              <MenuCheckboxItem defaultChecked>Duration</MenuCheckboxItem>
              <MenuCheckboxItem>Commit</MenuCheckboxItem>
            </MenuGroup>
            <MenuSeparator />
            <MenuSubmenu label="Group by">
              <MenuItem>Environment</MenuItem>
              <MenuItem>Author</MenuItem>
            </MenuSubmenu>
            <MenuSeparator />
            <MenuItem color="danger" shortcut="⌫">
              Reset view
            </MenuItem>
          </Menu>

          <Button size="sm" startIcon={<PlusIcon />}>
            New project
          </Button>
        </div>
      </section>

      {/* Boxes as the plainest surface there is: they group, and nothing else. */}
      <section className="flex flex-col gap-3">
        <Caption>Box · Typography</Caption>
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          {STATS.map((stat) => (
            <Box key={stat.label} variant="solid" color={stat.color}>
              <Typography level="h3">{stat.value}</Typography>
              <Typography level="caption">{stat.label}</Typography>
            </Box>
          ))}
        </div>
      </section>

      {/* What is happening right now, and what just went wrong. */}
      <section className="flex flex-col gap-3">
        <Caption>Alert · ProgressLinear · ProgressCircular · ProgressBox</Caption>
        <Alert
          color="warning"
          title="One region is near its quota"
          action={
            <Button size="xs" variant="outline" color="warning">
              Review
            </Button>
          }
          onClose={() => {}}
        >
          Frankfurt is at 90% of its build minutes for this billing period.
        </Alert>
        <Box variant="solid">
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-3 sm:items-center">
            <ProgressLinear value={64} label="Uploading assets" showValue />
            <ProgressCircular label="Indexing" />
            <div className="flex items-center gap-3">
              <ProgressBox color="info" />
              <Typography level="caption">Draining the queue</Typography>
            </div>
          </div>
        </Box>
      </section>

      {/* Data, rendered from a column list rather than written out row by row —
          inside the tab bar that switches between views of it, with the row of
          pages under it and a context menu on the whole thing. */}
      <section className="flex flex-col gap-3">
        <Caption>Tabs · Table · Chip · ContextMenu · Pagination</Caption>
        <Tabs defaultValue="deploys" size="sm">
          <Tab value="deploys" endIcon={<Badge content={DEPLOYS.length} size="xs" />}>
            Deploys
          </Tab>
          <Tab value="builds">Builds</Tab>
          <Tab value="logs" disabled>
            Logs
          </Tab>

          <TabPanel value="deploys">
            <div className="flex flex-col gap-3">
              <ContextMenu
                size="sm"
                content={
                  <>
                    <MenuItem shortcut="⌘R">Redeploy</MenuItem>
                    <MenuItem>Copy deploy URL</MenuItem>
                    <MenuSeparator />
                    <MenuItem color="danger">Cancel deploy</MenuItem>
                  </>
                }
              >
                <Table
                  headers={DEPLOY_COLUMNS}
                  items={DEPLOYS}
                  getRowKey={(row) => row.id}
                  size="sm"
                  hoverable
                />
              </ContextMenu>

              <div className="flex items-center justify-between gap-3">
                <Typography level="caption">Showing 1–3 of 34</Typography>
                <Pagination size="sm" count={12} page={page} onPageChange={setPage} />
              </div>
            </div>
          </TabPanel>

          <TabPanel value="builds">
            <Typography level="caption">Nothing building right now.</Typography>
          </TabPanel>
        </Tabs>
      </section>

      {/* A card holding controls — the composition the library is actually for. */}
      <section className="flex flex-col gap-3">
        <Caption>Card · TextField · Checkbox · List · Dialog · Toast</Caption>
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-[1.4fr_1fr]">
          <Card
            dividers
            title={<h3>Profile</h3>}
            subtitle="Shown on your public profile."
            footer={
              <>
                <Button variant="text" color="secondary">
                  Revert
                </Button>
                <Button className="ml-auto" loading={saving} onClick={save}>
                  {saved ? 'Saved' : 'Save changes'}
                </Button>
              </>
            }
          >
            <div className="flex flex-col gap-3">
              <TextField
                label="Name"
                value={name}
                onChange={(event) => setName(event.target.value)}
                fullWidth
              />
              <TextField
                label="Email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                error={emailValid ? undefined : 'Enter a valid address.'}
                fullWidth
              />
              <TextField
                multiline
                rows={3}
                label="About"
                placeholder="A sentence or two."
                description="Markdown is not supported."
                fullWidth
              />
              <Divider>Tags</Divider>
              <div className="flex flex-wrap items-center gap-2">
                {tags.map((tag) => (
                  <Chip
                    key={tag}
                    size="sm"
                    variant="text"
                    color="secondary"
                    onDelete={() => setTags(tags.filter((item) => item !== tag))}
                    deleteLabel={`Remove ${tag}`}
                  >
                    {tag}
                  </Chip>
                ))}
              </div>
              <Checkbox label="Show my email to other members" description="Members only." />
              <Divider>Files</Divider>
              <FilePicker
                multiple
                size="sm"
                density="compact"
                accept="image/*,.pdf"
                maxSize={5_000_000}
                maxFiles={3}
                title="Drop an avatar or a résumé"
                hint="PNG, JPG or PDF · up to 5 MB · 3 files"
                value={attachments}
                onFilesChange={setAttachments}
              />
            </div>
          </Card>

          <div className="flex flex-col gap-4">
            <Card
              variant="solid"
              color="secondary"
              title="Team"
              subtitle="Up to twelve seats"
              headerAction={
                <Chip size="xs" variant="outline" color="secondary">
                  Current plan
                </Chip>
              }
              footer={
                <Button size="sm" fullWidth variant="outline" color="secondary">
                  Change plan
                </Button>
              }
            >
              <RadioGroup size="sm" defaultValue="team" label="Billing">
                <Radio value="monthly" label="Monthly" />
                <Radio value="team" label="Yearly" description="Two months free." />
              </RadioGroup>
            </Card>

            <Card size="sm" title="Notifications">
              <div className="flex flex-col gap-3">
                <Switch size="sm" labelPlacement="start" label="Email alerts" defaultChecked />
                <Switch size="sm" labelPlacement="start" label="Deploy failures" defaultChecked />
                <Slider size="sm" label="Quiet hours" defaultValue={[22, 7]} max={24} showValue />
              </div>
            </Card>

            <Card size="sm" title="Environments" dividers>
              <List variant="text" size="sm" density="compact">
                <ListItem
                  onClick={() => {}}
                  selected
                  description="4m 02s ago"
                  action={
                    <Chip size="xs" variant="text" color="success">
                      Live
                    </Chip>
                  }
                >
                  production
                </ListItem>
                <ListItem
                  onClick={() => {}}
                  description="1m 48s ago"
                  action={
                    <Chip size="xs" variant="text" color="info">
                      Building
                    </Chip>
                  }
                >
                  staging
                </ListItem>
                <ListItem onClick={() => {}} description="Never deployed" disabled>
                  preview
                </ListItem>
              </List>
            </Card>

            <Card size="sm" title="Questions" dividers>
              <Accordion variant="text" size="sm" density="compact">
                <AccordionItem value="billing" title="How does billing work?">
                  Charged on the first for the seats held on the last day of the month.
                </AccordionItem>
                <AccordionItem value="regions" title="Where do builds run?">
                  In the region closest to the repository's default branch.
                </AccordionItem>
              </Accordion>
            </Card>

            <Card
              color="danger"
              size="sm"
              title="Danger zone"
              footer={
                <Dialog
                  size="sm"
                  color="danger"
                  trigger={
                    <Button size="sm" color="danger" variant="outline">
                      Delete workspace
                    </Button>
                  }
                  title="Delete this workspace?"
                  description="Every project, deploy and log inside it goes with it."
                  actions={
                    <>
                      <DialogClose
                        render={
                          <Button size="sm" variant="text" color="secondary">
                            Cancel
                          </Button>
                        }
                      />
                      <DialogClose
                        render={
                          <Button size="sm" color="danger">
                            Delete
                          </Button>
                        }
                      />
                    </>
                  }
                >
                  Members will lose access immediately.
                </Dialog>
              }
            >
              This cannot be undone.
            </Card>
          </div>
        </div>
      </section>

      {/* A box grouping cards: the box groups, the cards structure. */}
      <section className="flex flex-col gap-3">
        <Caption>Box + Card</Caption>
        <Box variant="text" padded={false}>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
            {(['primary', 'success', 'info'] as const).map((color) => (
              <Card key={color} size="sm" color={color} title={color} subtitle="A card in a box">
                Grouped by the box around them.
              </Card>
            ))}
          </div>
        </Box>
      </section>
    </div>
  );
}

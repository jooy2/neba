import { useMemo, useState } from 'react';
import {
  Alert,
  Avatar,
  Badge,
  Breadcrumb,
  BreadcrumbItem,
  Button,
  Card,
  Checkbox,
  Chip,
  ContextMenu,
  DateRangePicker,
  Dialog,
  DialogClose,
  Divider,
  Grid,
  GridContainer,
  Icon,
  IconButton,
  List,
  ListItem,
  Menu,
  MenuItem,
  MenuSeparator,
  Pagination,
  Pane,
  Panes,
  Pill,
  ProgressCircular,
  ProgressLinear,
  Select,
  Statistic,
  Switch,
  Tab,
  TabPanel,
  Table,
  Tabs,
  TextField,
  Timeline,
  TimelineItem,
  ToastProvider,
  Toolbar,
  Tooltip,
  Typography,
  useToast,
  type DateRange,
  type TableColumn
} from 'neba';

/**
 * The back office of a shop that does not exist.
 *
 * An admin screen is dense by nature: a nav rail, a filter row, numbers, a
 * table with an action per row, and a drawer of settings — all on one page and
 * all at the same size. It is the arrangement that shows whether a size ladder
 * actually holds, so nothing here is scaled by hand.
 *
 * The copy stays in English in both locales: it is a code sample, and the prose
 * explaining it lives in the Markdown around the preview.
 */

function LogoIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect
        x="2.5"
        y="2.5"
        width="11"
        height="11"
        rx="3.5"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path d="M5.5 8h5M8 5.5v5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
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

function HomeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M2.5 7 8 2.5 13.5 7v6.5h-11V7Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function BagIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3 5h10l-.8 8.5H3.8L3 5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M5.75 5V3.75a2.25 2.25 0 0 1 4.5 0V5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function BoxIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 2 13.5 5v6L8 14 2.5 11V5L8 2Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M2.5 5 8 8l5.5-3M8 8v6" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function PeopleIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="6" cy="5.5" r="2.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M1.75 13c.4-2.2 2.2-3.5 4.25-3.5S9.85 10.8 10.25 13"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M10.75 3.5a2.5 2.5 0 0 1 0 5M11.5 9.75c1.6.35 2.5 1.6 2.75 3.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function ChartIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M2.5 13.5h11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path
        d="M4.5 11V7M8 11V3.5M11.5 11V8.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function GearIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="2.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M8 1.75v1.5M8 12.75v1.5M14.25 8h-1.5M3.25 8h-1.5M12.4 3.6l-1 1M4.6 11.4l-1 1M12.4 12.4l-1-1M4.6 4.6l-1-1"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

const NAV = [
  { id: 'overview', label: 'Overview', icon: <HomeIcon /> },
  { id: 'orders', label: 'Orders', icon: <BagIcon />, badge: 12 },
  { id: 'products', label: 'Products', icon: <BoxIcon /> },
  { id: 'customers', label: 'Customers', icon: <PeopleIcon /> },
  { id: 'reports', label: 'Reports', icon: <ChartIcon /> },
  { id: 'settings', label: 'Settings', icon: <GearIcon /> }
];

const CHANNELS = [
  { value: 'all', label: 'All channels' },
  { value: 'web', label: 'Online store' },
  { value: 'pos', label: 'Point of sale' },
  { value: 'market', label: 'Marketplaces' }
];

/** `caption` is per figure, since the last one has nothing to compare against. */
const STATS = [
  {
    label: 'Revenue',
    value: 48219,
    prefix: '$',
    previousValue: 41880,
    betterWhen: 'up' as const,
    caption: 'vs. previous period'
  },
  {
    label: 'Orders',
    value: 1284,
    previousValue: 1190,
    betterWhen: 'up' as const,
    caption: 'vs. previous period'
  },
  {
    label: 'Refund rate',
    value: 1.8,
    unit: '%',
    previousValue: 2.6,
    betterWhen: 'down' as const,
    caption: 'vs. previous period'
  },
  { label: 'Avg. fulfilment', value: '9h 12m', caption: 'Order paid to parcel collected' }
];

type OrderStatus = 'Paid' | 'Packing' | 'Shipped' | 'Refunded';

interface Order {
  id: string;
  reference: string;
  customer: string;
  channel: string;
  status: OrderStatus;
  total: string;
}

const ORDERS: Order[] = [
  {
    id: '1',
    reference: '#10482',
    customer: 'Ada Bell',
    channel: 'Online store',
    status: 'Paid',
    total: '$248.00'
  },
  {
    id: '2',
    reference: '#10481',
    customer: '김서연',
    channel: 'Marketplaces',
    status: 'Packing',
    total: '$92.50'
  },
  {
    id: '3',
    reference: '#10480',
    customer: 'Tom Vale',
    channel: 'Online store',
    status: 'Shipped',
    total: '$1,120.00'
  },
  {
    id: '4',
    reference: '#10479',
    customer: 'Mira Osei',
    channel: 'Point of sale',
    status: 'Paid',
    total: '$36.00'
  },
  {
    id: '5',
    reference: '#10478',
    customer: 'Jun Park',
    channel: 'Online store',
    status: 'Refunded',
    total: '$74.90'
  }
];

const STATUS_COLOR: Record<OrderStatus, 'success' | 'info' | 'primary' | 'danger'> = {
  Paid: 'success',
  Packing: 'info',
  Shipped: 'primary',
  Refunded: 'danger'
};

/** "1 order", "3 orders" — a count in a sentence still has to read as one. */
const orders = (count: number) => `${count} ${count === 1 ? 'order' : 'orders'}`;

const LOW_STOCK = [
  { name: 'Field Notebook, A5', left: 4, of: 60 },
  { name: 'Enamel Mug, 350ml', left: 9, of: 120 },
  { name: 'Canvas Tote, Natural', left: 12, of: 80 }
];

/** Midnight today, so a preset never carries the time the page happened to load. */
function today() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function shift(from: Date, days: number): Date {
  return new Date(from.getFullYear(), from.getMonth(), from.getDate() + days);
}

function lastDays(count: number): DateRange {
  const end = today();
  return { start: shift(end, -(count - 1)), end };
}

export default function DashboardConcept() {
  return (
    <ToastProvider position="bottom-end">
      <DashboardBody />
    </ToastProvider>
  );
}

function DashboardBody() {
  const toast = useToast();
  const [section, setSection] = useState('orders');
  const [channel, setChannel] = useState<string | number | null>('all');
  const [query, setQuery] = useState('');
  const [range, setRange] = useState<DateRange>(() => lastDays(30));
  const [page, setPage] = useState(1);
  const [selected, setSelected] = useState<string[]>([]);
  const [autoFulfil, setAutoFulfil] = useState(true);

  const rows = useMemo(() => {
    const needle = query.trim().toLowerCase();

    return ORDERS.filter((order) => {
      const inChannel =
        channel === 'all' ||
        CHANNELS.find((item) => item.value === channel)?.label === order.channel;
      const matches =
        !needle ||
        order.reference.toLowerCase().includes(needle) ||
        order.customer.toLowerCase().includes(needle);

      return inChannel && matches;
    });
  }, [channel, query]);

  const allSelected = rows.length > 0 && selected.length === rows.length;

  const toggleAll = (checked: boolean) => {
    setSelected(checked ? rows.map((row) => row.id) : []);
  };

  const toggleOne = (id: string, checked: boolean) => {
    setSelected((current) => (checked ? [...current, id] : current.filter((item) => item !== id)));
  };

  const columns: TableColumn<Order>[] = [
    {
      key: 'select',
      label: (
        <Checkbox
          size="sm"
          aria-label="Select every order"
          checked={allSelected}
          indeterminate={selected.length > 0 && !allSelected}
          onCheckedChange={toggleAll}
        />
      ),
      width: 44,
      render: (row) => (
        <Checkbox
          size="sm"
          aria-label={`Select ${row.reference}`}
          checked={selected.includes(row.id)}
          onCheckedChange={(checked) => toggleOne(row.id, checked)}
        />
      )
    },
    { key: 'reference', label: 'Order', width: 96 },
    {
      key: 'customer',
      label: 'Customer',
      width: 160,
      render: (row) => (
        <span className="flex items-center gap-2">
          <Avatar size="xs" name={row.customer} color="secondary" />
          {row.customer}
        </span>
      )
    },
    { key: 'channel', label: 'Channel', width: 130 },
    {
      key: 'status',
      label: 'Status',
      width: 120,
      render: (row) => (
        <Chip size="xs" variant="text" color={STATUS_COLOR[row.status]}>
          {row.status}
        </Chip>
      )
    },
    { key: 'total', label: 'Total', align: 'end', width: 96 },
    {
      key: 'actions',
      label: '',
      align: 'end',
      width: 48,
      render: (row) => (
        <Menu
          size="sm"
          trigger={
            <IconButton
              icon={<DotIcon />}
              label={`Actions for ${row.reference}`}
              size="xs"
              variant="text"
              color="secondary"
            />
          }
        >
          <MenuItem>Open order</MenuItem>
          <MenuItem>Print packing slip</MenuItem>
          <MenuSeparator />
          <MenuItem color="danger">Refund</MenuItem>
        </Menu>
      )
    }
  ];

  return (
    // The shell is a split, and the split is the layout: a rail that keeps its
    // width and a work area that takes what is left.
    <div className="h-[46rem]">
      <Panes>
        <Pane defaultSize="232px" minSize="72px" maxSize="40%">
          <div className="flex h-full flex-col gap-4 p-3">
            <div className="flex items-center gap-2 px-1">
              <Icon icon={<LogoIcon />} size="lg" color="primary" label="Grange" />
              <Typography level="h6">Grange</Typography>
            </div>

            <List variant="text" size="sm" density="compact" render={<nav />}>
              {NAV.map((item) => (
                <ListItem
                  key={item.id}
                  startIcon={<Icon icon={item.icon} size="sm" color="inherit" />}
                  selected={section === item.id}
                  onClick={() => setSection(item.id)}
                  action={
                    item.badge ? (
                      <Chip size="xs" variant="text" color="info">
                        {item.badge}
                      </Chip>
                    ) : undefined
                  }
                >
                  {item.label}
                </ListItem>
              ))}
            </List>

            <div className="grow" />

            {/* The one live readout in the shell, in the shape made for it. */}
            <Pill
              size="sm"
              color="info"
              variant="text"
              startIcon={<DotIcon />}
              title="Syncing inventory"
              description="2 of 3 warehouses"
            />

            <Card
              size="sm"
              variant="outline"
              color="secondary"
              title="Plan"
              subtitle="Standard · 8 seats"
            >
              <div className="flex flex-col gap-2">
                <ProgressLinear value={72} size="sm" label="Order quota" showValue />
                <Button size="xs" fullWidth variant="outline" color="secondary">
                  Upgrade
                </Button>
              </div>
            </Card>
          </div>
        </Pane>

        <Pane className="overflow-auto">
          <div className="flex flex-col gap-5 p-4">
            {/* The application bar, sticky, so the actions stay reachable while
              the table below it scrolls. */}
            <Toolbar
              render={<header />}
              variant="solid"
              density="compact"
              position="sticky"
              divider
              start={
                <Breadcrumb size="sm">
                  <BreadcrumbItem href="#home">Grange</BreadcrumbItem>
                  <BreadcrumbItem href="#store">Northwind Supply</BreadcrumbItem>
                  <BreadcrumbItem>Orders</BreadcrumbItem>
                </Breadcrumb>
              }
              end={
                <>
                  <Tooltip content="What changed in the last hour">
                    <Badge content={3} color="danger" label="3 new notifications">
                      <IconButton
                        icon={<BellIcon />}
                        label="Notifications"
                        size="sm"
                        variant="text"
                        color="secondary"
                      />
                    </Badge>
                  </Tooltip>
                  <Badge dot color="success" overlap="circle" label="Online">
                    <Avatar size="sm" src="/samples/people/helen-voss.jpg" name="Helen Voss" />
                  </Badge>
                </>
              }
            />

            <div className="flex flex-wrap items-end justify-between gap-3">
              <div className="flex flex-col gap-1">
                <Typography level="h3">Orders</Typography>
                <Typography level="caption" className="text-(--neba-muted-fg)">
                  Everything placed in the selected range, across every channel.
                </Typography>
              </div>
              <div className="flex items-center gap-2">
                <Button size="sm" variant="outline" color="secondary">
                  Export CSV
                </Button>
                <Button size="sm">Create order</Button>
              </div>
            </div>

            {/* One thing needs attention, so it is said once, at the top. */}
            <Alert
              color="warning"
              title="Three products are below their reorder point"
              action={
                <Button size="xs" variant="outline" color="warning">
                  Reorder
                </Button>
              }
              onClose={() => {}}
            >
              Stock levels were last synced 14 minutes ago.
            </Alert>

            {/* The numbers this screen opens with — two per row at every width,
              because the work area is narrower than the viewport the
              breakpoints are measured against. */}
            <GridContainer spacing={3} padded={false}>
              {STATS.map((stat) => (
                <Grid key={stat.label} span={6}>
                  <Statistic
                    label={stat.label}
                    value={stat.value}
                    prefix={stat.prefix}
                    unit={stat.unit}
                    previousValue={stat.previousValue}
                    betterWhen={stat.betterWhen}
                    caption={stat.caption}
                    className="h-full"
                  />
                </Grid>
              ))}
            </GridContainer>

            {/* The filter row. Every control on it is the same `size`, which is
              what keeps one baseline across four different components. */}
            <div className="flex flex-wrap items-center gap-2">
              <TextField
                size="sm"
                startIcon={<SearchIcon />}
                placeholder="Search order or customer"
                aria-label="Search orders"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
              <Select
                size="sm"
                items={CHANNELS}
                value={channel}
                onValueChange={setChannel}
                aria-label="Channel"
              />
              <DateRangePicker
                size="sm"
                value={range}
                onValueChange={setRange}
                startPlaceholder="From"
                endPlaceholder="To"
                aria-label="Date range"
                presets={[
                  { label: 'Last 7 days', value: () => lastDays(7) },
                  { label: 'Last 30 days', value: () => lastDays(30) },
                  { label: 'Last 90 days', value: () => lastDays(90) }
                ]}
              />
              <div className="grow" />
              {selected.length > 0 && (
                <>
                  <Typography level="caption" className="text-(--neba-muted-fg)">
                    {selected.length} selected
                  </Typography>
                  <Button
                    size="sm"
                    variant="outline"
                    color="secondary"
                    onClick={() => {
                      toast.add({
                        color: 'success',
                        title: 'Marked as fulfilled',
                        description: orders(selected.length)
                      });
                      setSelected([]);
                    }}
                  >
                    Fulfil
                  </Button>
                  <Dialog
                    size="sm"
                    color="danger"
                    trigger={
                      <Button size="sm" variant="outline" color="danger">
                        Cancel orders
                      </Button>
                    }
                    title={`Cancel ${orders(selected.length)}?`}
                    description="Payment is released back to the customer straight away."
                    actions={
                      <>
                        <DialogClose
                          render={
                            <Button size="sm" variant="text" color="secondary">
                              Keep them
                            </Button>
                          }
                        />
                        <DialogClose
                          render={
                            <Button size="sm" color="danger" onClick={() => setSelected([])}>
                              Cancel orders
                            </Button>
                          }
                        />
                      </>
                    }
                  >
                    This cannot be undone.
                  </Dialog>
                </>
              )}
            </div>

            {/* The table, under the tabs that switch which slice of it is shown,
              with the row actions on a context menu as well as the row menu. */}
            <Tabs defaultValue="open" size="sm">
              <Tab value="open" endIcon={<Badge content={rows.length} size="xs" />}>
                Open
              </Tab>
              <Tab value="fulfilled">Fulfilled</Tab>
              <Tab value="cancelled">Cancelled</Tab>

              <TabPanel value="open">
                <div className="flex flex-col gap-3">
                  <ContextMenu
                    size="sm"
                    content={
                      <>
                        <MenuItem shortcut="Mod+P">Print packing slips</MenuItem>
                        <MenuItem>Copy order numbers</MenuItem>
                        <MenuSeparator />
                        <MenuItem color="danger">Cancel selected</MenuItem>
                      </>
                    }
                  >
                    <Table
                      headers={columns}
                      items={rows}
                      getRowKey={(row) => row.id}
                      size="sm"
                      hoverable
                      stickyHeader
                      empty="No orders match those filters."
                    />
                  </ContextMenu>

                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <Typography level="caption" className="text-(--neba-muted-fg)">
                      Showing {rows.length} of 1,284
                    </Typography>
                    <Pagination size="sm" count={26} page={page} onPageChange={setPage} />
                  </div>
                </div>
              </TabPanel>

              <TabPanel value="fulfilled">
                <Typography level="caption" className="text-(--neba-muted-fg)">
                  Nothing fulfilled in this range yet.
                </Typography>
              </TabPanel>

              <TabPanel value="cancelled">
                <Typography level="caption" className="text-(--neba-muted-fg)">
                  Two orders were cancelled this week.
                </Typography>
              </TabPanel>
            </Tabs>

            <Divider />

            {/* The bottom row: what is running, what happened, what is set. */}
            <GridContainer spacing={3} padded={false}>
              <Grid span={{ xs: 12, md: 4 }}>
                <Card
                  size="sm"
                  className="h-full"
                  title="Low stock"
                  subtitle="Below the reorder point"
                  dividers
                >
                  <div className="flex flex-col gap-3">
                    {LOW_STOCK.map((item) => (
                      <ProgressLinear
                        key={item.name}
                        size="sm"
                        color={item.left < 6 ? 'danger' : 'warning'}
                        value={item.left}
                        max={item.of}
                        label={`${item.name} · ${item.left} of ${item.of} left`}
                      />
                    ))}
                  </div>
                </Card>
              </Grid>

              <Grid span={{ xs: 12, md: 4 }}>
                <Card size="sm" className="h-full" title="Today" subtitle="Warehouse activity">
                  <Timeline size="sm" density="compact" active={2} color="primary">
                    <TimelineItem title="Picking started" meta="08:10">
                      14 orders in the wave
                    </TimelineItem>
                    <TimelineItem title="Carrier collected" meta="11:45">
                      DHL · 9 parcels
                    </TimelineItem>
                    <TimelineItem title="Restock arriving" meta="16:00">
                      3 SKUs
                    </TimelineItem>
                  </Timeline>
                </Card>
              </Grid>

              <Grid span={{ xs: 12, md: 4 }}>
                <Card
                  size="sm"
                  className="h-full"
                  title="Automation"
                  subtitle="Applies to the whole store"
                  footer={
                    <div className="flex items-center gap-2">
                      <ProgressCircular size="xs" />
                      <Typography level="caption" className="text-(--neba-muted-fg)">
                        Rules running
                      </Typography>
                    </div>
                  }
                >
                  <div className="flex flex-col gap-3">
                    <Switch
                      size="sm"
                      labelPlacement="start"
                      label="Auto-fulfil paid orders"
                      checked={autoFulfil}
                      onCheckedChange={setAutoFulfil}
                    />
                    <Switch
                      size="sm"
                      labelPlacement="start"
                      label="Email the customer on dispatch"
                      defaultChecked
                    />
                    <Switch
                      size="sm"
                      labelPlacement="start"
                      label="Hold orders flagged as risky"
                      defaultChecked
                    />
                  </div>
                </Card>
              </Grid>
            </GridContainer>
          </div>
        </Pane>
      </Panes>
    </div>
  );
}

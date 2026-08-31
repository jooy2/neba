import { useState, type ReactNode } from 'react';
import {
  Accordion,
  AccordionItem,
  Alert,
  Anchor,
  AnimateAppear,
  AnimateBlink,
  AnimateFade,
  AnimateGrow,
  AnimateHeadline,
  AnimateLighting,
  AnimateMarquee,
  AnimateRotate,
  AnimateSlide,
  AnimateTyping,
  AnimateZoom,
  AppLogo,
  AreaChart,
  AspectRatio,
  Avatar,
  AvatarGroup,
  Badge,
  BarChart,
  Blockquote,
  BottomNavigation,
  BottomNavigationItem,
  Box,
  Breadcrumb,
  BreadcrumbItem,
  Button,
  ButtonGroup,
  Card,
  Carousel,
  ChatBubble,
  Checkbox,
  Chip,
  CodeBlock,
  ColorPicker,
  Combobox,
  CommandPalette,
  Collapsible,
  Container,
  DataList,
  DataListItem,
  DataTable,
  DatePicker,
  DateRangePicker,
  DateTimePicker,
  Dialog,
  DialogClose,
  Divider,
  Drawer,
  Empty,
  Fieldset,
  FilePicker,
  FloatingAction,
  FloatingActionButton,
  FloatingBottomNavigation,
  Footer,
  Form,
  GaugeChart,
  Grid,
  GridContainer,
  HeatmapChart,
  Header,
  Highlight,
  HoverCard,
  HowToSteps,
  Icon,
  IconButton,
  LineChart,
  List,
  ListItem,
  Menu,
  MenuItem,
  MenuSeparator,
  MenuSubmenu,
  Menubar,
  MenubarMenu,
  Meter,
  Mockup,
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NumberField,
  OtpField,
  Overlay,
  Pagination,
  PageLayout,
  Pane,
  Panes,
  PieChart,
  Pill,
  Popover,
  PopoverClose,
  ProgressBox,
  ProgressCircular,
  ProgressLinear,
  Radio,
  RadioGroup,
  Rating,
  ScatterChart,
  ScrollArea,
  ScrollZone,
  Segment,
  SegmentedButton,
  Select,
  Shortcut,
  Sidebar,
  Skeleton,
  Slider,
  Sparkline,
  Spoiler,
  Statistic,
  Switch,
  Tab,
  Table,
  TabPanel,
  Tabs,
  TextField,
  TextLink,
  TimePicker,
  Timeline,
  TimelineChart,
  TimelineItem,
  ToastProvider,
  Toggle,
  ToggleGroup,
  Toolbar,
  Tooltip,
  Tour,
  Transfer,
  TreeItem,
  TreeView,
  Typography,
  VisuallyHidden,
  WindowPane,
  useToast
} from 'neba';
import { DEFAULT_LOCALE, type Locale } from '../../data/i18n';

/**
 * The component index: one card per component, each holding a live instance of
 * the thing it links to. Chrome is drawn with VitePress's own palette variables
 * so the grid belongs to the docs, while what sits inside every card is the
 * real component on the real acrylic surface.
 *
 * Unlike the other demos this one is documentation rather than a code sample,
 * so it takes the locale `Demo.vue` passes in and localises its own copy.
 */

type Text = Record<Locale, string>;

/* The few glyphs the icon-shaped cards need. Neba ships no icon set, so the
   demos draw their own — which is also the honest way to show what Icon does. */

function GalleryPlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function GalleryStarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m8 2 1.8 3.9 4.2.5-3.1 2.9.8 4.2L8 11.4 4.3 13.5l.8-4.2L2 6.4l4.2-.5L8 2Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function GalleryBellIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
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

function GalleryDotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

function GalleryHomeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M2.5 7 8 2.5 13.5 7v6a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V7Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function GallerySearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.25 10.25 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function GalleryPersonIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="5.75" r="2.75" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M3 13.25a5 5 0 0 1 10 0"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/* Fixed dates, so a card looks the same in every screenshot and every locale.
   The pickers themselves default to today when they are handed nothing. */
const GALLERY_DAY = new Date(2026, 6, 27);
const GALLERY_DAY_LATER = new Date(2026, 7, 3);
const GALLERY_MOMENT = new Date(2026, 6, 27, 9, 30);

/** Opened from its own button, and never bound to a key inside the gallery. */
function GalleryCommandPalette() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button size="sm" variant="outline" onClick={() => setOpen(true)}>
        Open the palette
      </Button>
      <CommandPalette
        size="sm"
        shortcut={false}
        open={open}
        onOpenChange={setOpen}
        items={[
          { value: 'overview', label: 'Go to overview', group: 'Navigate', shortcut: 'G O' },
          { value: 'logs', label: 'Go to logs', group: 'Navigate' },
          { value: 'deploy', label: 'Deploy production', group: 'Actions', keywords: ['ship'] }
        ]}
      />
    </>
  );
}

/** The one preview that runs over the page, so it never draws the mask. */
function GalleryTour() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex flex-col items-center gap-3">
      <Chip id="gallery-tour-target" size="sm" variant="solid" color="success">
        Live
      </Chip>
      <Button size="sm" variant="outline" onClick={() => setOpen(true)}>
        Show me around
      </Button>
      <Tour
        size="sm"
        mask={false}
        open={open}
        onOpenChange={setOpen}
        steps={[
          {
            target: '#gallery-tour-target',
            title: 'The current state',
            content: 'Green means the last deploy is serving traffic.'
          }
        ]}
      />
    </div>
  );
}

interface Entry {
  name: string;
  summary: Text;
  /** Appended to the locale's base path. */
  path: string;
  preview: ReactNode;
}

interface Group {
  title: string;
  note: Text;
  entries: Entry[];
}

const GROUPS: Group[] = [
  {
    title: 'Inputs',
    note: {
      ko: '사용자가 값을 넣거나 액션을 실행하는 컨트롤',
      en: 'Controls that take a value or run an action'
    },
    entries: [
      {
        name: 'Button',
        summary: { ko: '액션을 실행하는 컨트롤', en: 'Runs an action' },
        path: '/components/inputs/button',
        preview: (
          <div className="flex flex-wrap items-center justify-center gap-2">
            <Button size="sm">Save</Button>
            <Button size="sm" variant="outline">
              Cancel
            </Button>
            <Button size="sm" variant="text">
              Details
            </Button>
          </div>
        )
      },
      {
        name: 'ButtonGroup',
        summary: {
          ko: '서로 붙어 있는 버튼들',
          en: 'A row of buttons that belong together'
        },
        path: '/components/inputs/button-group',
        preview: (
          <ButtonGroup size="sm" variant="outline" color="secondary">
            <Button>Day</Button>
            <Button>Week</Button>
            <Button>Month</Button>
          </ButtonGroup>
        )
      },
      {
        name: 'TextField',
        summary: {
          ko: '한 줄 또는 여러 줄 텍스트 입력',
          en: 'Single- or multi-line text input'
        },
        path: '/components/inputs/text-field',
        preview: (
          <div className="w-full max-w-52">
            <TextField size="sm" label="Email" placeholder="jane@example.com" fullWidth />
          </div>
        )
      },
      {
        name: 'Select',
        summary: {
          ko: '목록에서 값 하나를 고르기',
          en: 'One value chosen from a list'
        },
        path: '/components/inputs/select',
        preview: (
          <div className="w-full max-w-52">
            <Select
              size="sm"
              label="Region"
              fullWidth
              defaultValue="icn"
              items={[
                { value: 'icn', label: 'Seoul' },
                { value: 'nrt', label: 'Tokyo' }
              ]}
            />
          </div>
        )
      },
      {
        name: 'Checkbox',
        summary: { ko: '하나의 예/아니오', en: 'A single yes/no' },
        path: '/components/inputs/checkbox',
        preview: (
          <div className="flex flex-col gap-2">
            <Checkbox size="sm" label="Remember me" defaultChecked />
            <Checkbox size="sm" label="Send updates" />
          </div>
        )
      },
      {
        name: 'RadioGroup',
        summary: { ko: '여럿 중 정확히 하나', en: 'Exactly one of a set' },
        path: '/components/inputs/radio-group',
        preview: (
          <RadioGroup size="sm" defaultValue="team">
            <Radio value="starter" label="Starter" />
            <Radio value="team" label="Team" />
          </RadioGroup>
        )
      },
      {
        name: 'Switch',
        summary: { ko: '즉시 켜고 끄기', en: 'An immediate on/off' },
        path: '/components/inputs/switch',
        preview: (
          <div className="flex flex-col gap-2">
            <Switch size="sm" label="Email alerts" defaultChecked />
            <Switch size="sm" label="Previews" />
          </div>
        )
      },
      {
        name: 'Slider',
        summary: { ko: '범위 위에서 값 고르기', en: 'A value along a range' },
        path: '/components/inputs/slider',
        preview: (
          <div className="w-full max-w-52">
            <Slider size="sm" aria-label="Volume" defaultValue={65} />
          </div>
        )
      },
      {
        name: 'Menu',
        summary: {
          ko: '눌렀을 때 나타나는 액션 목록. 중첩됩니다',
          en: 'A list of actions that appears when something is pressed'
        },
        path: '/components/inputs/menu',
        preview: (
          <Menu
            size="sm"
            trigger={
              <Button size="sm" variant="outline" color="secondary">
                Actions
              </Button>
            }
          >
            <MenuItem shortcut="⌘E">Rename</MenuItem>
            <MenuSubmenu label="Move to">
              <MenuItem>Archive</MenuItem>
            </MenuSubmenu>
            <MenuSeparator />
            <MenuItem color="danger">Delete</MenuItem>
          </Menu>
        )
      },
      {
        name: 'FilePicker',
        summary: {
          ko: '끌어다 놓거나 눌러서 고르는 점선 상자',
          en: 'A dashed box you drop files on, or press to browse'
        },
        path: '/components/inputs/file-picker',
        preview: (
          <div className="w-full max-w-56">
            <FilePicker size="xs" density="compact" title="Drop files" hint="Up to 5 MB" />
          </div>
        )
      },
      {
        name: 'Pagination',
        summary: {
          ko: '페이지 번호가 늘어선 줄',
          en: 'A row of page numbers'
        },
        path: '/components/inputs/pagination',
        preview: <Pagination size="sm" count={9} defaultPage={4} />
      },
      {
        name: 'SegmentedButton',
        summary: {
          ko: '한 알약 안에서 정확히 하나',
          en: 'Exactly one, from inside one pill'
        },
        path: '/components/inputs/segmented-button',
        preview: (
          <SegmentedButton size="sm" aria-label="Range" defaultValue="week">
            <Segment value="day">Day</Segment>
            <Segment value="week">Week</Segment>
            <Segment value="month">Month</Segment>
          </SegmentedButton>
        )
      },
      {
        name: 'Combobox',
        summary: {
          ko: '직접 입력할 수도, 목록에서 고를 수도 있는 필드',
          en: 'A field you can type into and also choose from'
        },
        path: '/components/inputs/combobox',
        preview: (
          <div className="w-full max-w-52">
            <Combobox
              multiple
              fullWidth
              size="sm"
              items={[
                { value: 'bug', label: 'bug' },
                { value: 'docs', label: 'documentation' }
              ]}
              defaultValue={['bug']}
              placeholder="Add a label"
            />
          </div>
        )
      },
      {
        name: 'NumberField',
        summary: {
          ko: '숫자만 담는 필드',
          en: 'A field that only holds a number'
        },
        path: '/components/inputs/number-field',
        preview: (
          <div className="w-full max-w-40">
            <NumberField size="sm" fullWidth defaultValue={3} min={1} max={20} />
          </div>
        )
      },
      {
        name: 'IconButton',
        summary: {
          ko: '글리프 하나만 든 동그란 버튼',
          en: 'A round button with a glyph in it and nothing else'
        },
        path: '/components/inputs/icon-button',
        preview: (
          <div className="flex flex-wrap items-center justify-center gap-2">
            <IconButton icon={<GalleryPlusIcon />} label="Add" size="sm" />
            <IconButton icon={<GalleryStarIcon />} label="Star" size="sm" variant="outline" />
            <IconButton
              icon={<GalleryBellIcon />}
              label="Notifications"
              size="sm"
              variant="text"
              color="secondary"
            />
          </div>
        )
      },
      {
        name: 'DatePicker',
        summary: { ko: '달력에서 하루 고르기', en: 'One day, chosen from a calendar' },
        path: '/components/inputs/date-picker',
        preview: (
          <div className="w-full max-w-52">
            <DatePicker size="sm" label="Ships on" fullWidth defaultValue={GALLERY_DAY} />
          </div>
        )
      },
      {
        name: 'TimePicker',
        summary: { ko: '열에서 시각 고르기', en: 'A time of day, chosen from columns' },
        path: '/components/inputs/time-picker',
        preview: (
          <div className="w-full max-w-52">
            <TimePicker
              size="sm"
              label="Starts at"
              fullWidth
              minuteStep={15}
              defaultValue={GALLERY_MOMENT}
            />
          </div>
        )
      },
      {
        name: 'DateTimePicker',
        summary: { ko: '한 팝업 안의 날과 시각', en: 'A day and a time, in one popup' },
        path: '/components/inputs/date-time-picker',
        preview: (
          <div className="w-full max-w-56">
            <DateTimePicker
              size="sm"
              label="Publish at"
              fullWidth
              minuteStep={15}
              defaultValue={GALLERY_MOMENT}
            />
          </div>
        )
      },
      {
        name: 'DateRangePicker',
        summary: { ko: '두 날 사이의 구간', en: 'A span between two days' },
        path: '/components/inputs/date-range-picker',
        preview: (
          <div className="w-full max-w-56">
            <DateRangePicker
              size="sm"
              label="Stay"
              fullWidth
              defaultValue={{ start: GALLERY_DAY, end: GALLERY_DAY_LATER }}
            />
          </div>
        )
      },
      {
        name: 'OtpField',
        summary: {
          ko: '한 글자씩 들어가는 짧은 코드 입력란',
          en: 'A row of one-character slots for a short code'
        },
        path: '/components/inputs/otp-field',
        preview: <OtpField size="xs" length={6} groupSize={3} defaultValue="4417" />
      },
      {
        name: 'ColorPicker',
        summary: {
          ko: '눈으로 고르는 색. 사각형과 레일, 그리고 스와치',
          en: 'A colour chosen by eye — a square, two rails and a row of swatches'
        },
        path: '/components/inputs/color-picker',
        preview: <ColorPicker size="sm" defaultValue="#1a58d1" />
      },
      {
        name: 'Rating',
        summary: {
          ko: '별 한 줄로 매기는 점수',
          en: 'A score, as a row of stars'
        },
        path: '/components/inputs/rating',
        preview: <Rating size="sm" defaultValue={4} />
      },
      {
        name: 'BottomNavigation',
        summary: {
          ko: '창 아래 가장자리에 고정되는 목적지 줄',
          en: "A row of destinations held against the window's bottom edge"
        },
        path: '/components/inputs/bottom-navigation',
        preview: (
          <div className="w-full max-w-56">
            <BottomNavigation size="sm" position="static" defaultValue="home">
              <BottomNavigationItem value="home" icon={<GalleryHomeIcon />}>
                Home
              </BottomNavigationItem>
              <BottomNavigationItem value="search" icon={<GallerySearchIcon />}>
                Search
              </BottomNavigationItem>
              <BottomNavigationItem value="you" icon={<GalleryPersonIcon />}>
                You
              </BottomNavigationItem>
            </BottomNavigation>
          </div>
        )
      },
      {
        name: 'FloatingBottomNavigation',
        summary: {
          ko: '아래 가장자리에서 떠 있는 목적지 줄',
          en: 'A row of destinations floating clear of the bottom edge'
        },
        path: '/components/inputs/floating-bottom-navigation',
        preview: (
          <FloatingBottomNavigation size="sm" position="static" defaultValue="home">
            <BottomNavigationItem value="home" icon={<GalleryHomeIcon />}>
              Home
            </BottomNavigationItem>
            <BottomNavigationItem value="search" icon={<GallerySearchIcon />}>
              Search
            </BottomNavigationItem>
            <BottomNavigationItem value="you" icon={<GalleryPersonIcon />}>
              You
            </BottomNavigationItem>
          </FloatingBottomNavigation>
        )
      },
      {
        name: 'FloatingActionButton',
        summary: {
          ko: '화면 위에 떠 있는 하나의 액션, 그리고 펼쳐지는 다이얼',
          en: 'One action floating over a screen, and the dial that fans out of it'
        },
        path: '/components/inputs/floating-action-button',
        preview: (
          <div className="flex items-center justify-center gap-3">
            <FloatingActionButton position="static" size="md" label="Add" />
            <FloatingActionButton position="static" size="md" label="Compose" extended>
              <FloatingAction label="Note" />
            </FloatingActionButton>
          </div>
        )
      },
      {
        name: 'CommandPalette',
        summary: {
          ko: '애플리케이션이 할 수 있는 모든 것을 필드 하나 뒤에',
          en: 'Everything an application can do, behind one field'
        },
        path: '/components/inputs/command-palette',
        preview: <GalleryCommandPalette />
      },
      {
        name: 'Transfer',
        summary: {
          ko: '두 목록과 그 사이의 화살표',
          en: 'Two lists and the arrows between them'
        },
        path: '/components/inputs/transfer',
        preview: (
          <Transfer
            size="xs"
            height={92}
            className="max-w-64"
            items={[
              { value: 'status', label: 'Status' },
              { value: 'commit', label: 'Commit' },
              { value: 'author', label: 'Author' }
            ]}
            defaultValue={['status']}
          />
        )
      },
      {
        name: 'NavigationMenu',
        summary: {
          ko: '패널이 열리는 사이트 내비게이션',
          en: "A site's navigation, with panels that open"
        },
        path: '/components/inputs/navigation-menu',
        preview: (
          <NavigationMenu size="sm" aria-label="Gallery">
            <NavigationMenuItem label="Product">
              <NavigationMenuLink href="#analytics" title="Analytics" description="Every number." />
              <NavigationMenuLink href="#pipelines" title="Pipelines" />
            </NavigationMenuItem>
            <NavigationMenuItem label="Pricing" href="#pricing" />
          </NavigationMenu>
        )
      },
      {
        name: 'Menubar',
        summary: {
          ko: '애플리케이션 상단의 단어 띠',
          en: 'The strip of words at the top of an application'
        },
        path: '/components/inputs/menubar',
        preview: (
          <Menubar size="sm">
            <MenubarMenu label="File">
              <MenuItem shortcut="⌘N">New file</MenuItem>
              <MenuSeparator />
              <MenuItem>Open…</MenuItem>
            </MenubarMenu>
            <MenubarMenu label="Edit">
              <MenuItem shortcut="⌘Z">Undo</MenuItem>
            </MenubarMenu>
            <MenubarMenu label="View">
              <MenuItem>Sidebar</MenuItem>
            </MenubarMenu>
          </Menubar>
        )
      },
      {
        name: 'Form',
        summary: {
          ko: '어느 field가 잘못되었는지 아는 form',
          en: 'A form that knows which of its fields is wrong'
        },
        path: '/components/inputs/form',
        preview: (
          <Form size="sm" className="w-full max-w-56" onSubmit={() => {}}>
            <TextField size="sm" label="Email" name="email" type="email" required />
            <Button size="sm" type="submit" fullWidth>
              Sign up
            </Button>
          </Form>
        )
      },
      {
        name: 'Fieldset',
        summary: {
          ko: '하나의 질문에 함께 답하는 컨트롤 묶음',
          en: 'Controls that answer one question together'
        },
        path: '/components/inputs/fieldset',
        preview: (
          <Fieldset size="sm" legend="Billing address" className="w-full max-w-56">
            <TextField size="sm" label="Street" name="gallery-street" />
            <TextField size="sm" label="City" name="gallery-city" />
          </Fieldset>
        )
      },
      {
        name: 'Toggle',
        summary: { ko: '눌린 채로 머무는 버튼', en: 'A button that stays down' },
        path: '/components/inputs/toggle',
        preview: (
          <div className="flex flex-wrap items-center justify-center gap-2">
            <Toggle size="sm" defaultPressed>
              Bold
            </Toggle>
            <Toggle size="sm">Italic</Toggle>
            <Toggle size="sm" variant="text" defaultPressed>
              Grid
            </Toggle>
          </div>
        )
      },
      {
        name: 'ToggleGroup',
        summary: {
          ko: '하나의 상태를 공유하는 토글 묶음',
          en: 'A set of toggles that share one state'
        },
        path: '/components/inputs/toggle-group',
        preview: (
          <ToggleGroup size="sm" aria-label="Text alignment" defaultValue={['center']}>
            <Toggle value="left">Left</Toggle>
            <Toggle value="center">Center</Toggle>
            <Toggle value="right">Right</Toggle>
          </ToggleGroup>
        )
      }
    ]
  },
  {
    title: 'Layout',
    note: {
      ko: '아무것도 그리지 않고 나머지를 배치하는 것들',
      en: 'The pieces that arrange everything else and draw nothing themselves'
    },
    entries: [
      {
        name: 'PageLayout',
        summary: {
          ko: 'header·footer·사이드바를 자리에 놓는 페이지의 뼈대',
          en: "A page's skeleton: header, footer and sidebars, each in its place"
        },
        path: '/components/layout/page-layout',
        preview: (
          <div className="h-32 w-full max-w-56 overflow-hidden rounded-lg border border-(--neba-border)">
            <PageLayout
              height="auto"
              scroll="content"
              collapseBelow="none"
              skipLink={false}
              mainId="gallery-page-layout"
              header={
                <Header size="xs" padded brand={<AppLogo name="Neba" size="xs" showName />} />
              }
              sidebar={<Sidebar size="xs" width={64} label="Sections" />}
            >
              <div className="p-2 text-[0.6875rem] text-(--neba-muted-fg)">main</div>
            </PageLayout>
          </div>
        )
      },
      {
        name: 'Header',
        summary: {
          ko: '로고·탐색·행동으로 나뉜 맨 위 바',
          en: 'The bar at the top: brand, navigation, actions'
        },
        path: '/components/layout/header',
        preview: (
          <div className="w-full max-w-56">
            <Header
              size="xs"
              position="static"
              className="rounded-lg"
              brand={<AppLogo name="Neba" size="xs" showName />}
              actions={<Chip size="xs">Beta</Chip>}
            />
          </div>
        )
      },
      {
        name: 'Footer',
        summary: {
          ko: '문서가 끝났다고 말하는 맨 아래 시트',
          en: 'The sheet at the end that says the document is over'
        },
        path: '/components/layout/footer',
        preview: (
          <div className="w-full max-w-56">
            <Footer size="xs" className="rounded-lg">
              <Typography level="caption" color="secondary">
                © 2026 Neba
              </Typography>
            </Footer>
          </div>
        )
      },
      {
        name: 'Sidebar',
        summary: {
          ko: '내용 옆의 열, 창이 좁아지면 drawer',
          en: 'A column beside the content, a drawer once the window is narrow'
        },
        path: '/components/layout/sidebar',
        preview: (
          <div className="flex h-28 w-full max-w-56 overflow-hidden rounded-lg border border-(--neba-border)">
            <Sidebar size="xs" collapseBelow="none" width={88} label="Sections">
              <Typography level="caption">Overview</Typography>
              <Typography level="caption" color="secondary">
                Components
              </Typography>
            </Sidebar>
            <div className="flex-1 p-2 text-[0.6875rem] text-(--neba-muted-fg)">content</div>
          </div>
        )
      },
      {
        name: 'Container',
        summary: {
          ko: '좌우 여백, 그리고 원한다면 본문 폭',
          en: 'A gutter, and a measure if you want one'
        },
        path: '/components/layout/container',
        preview: (
          <div className="w-full max-w-56 rounded-lg bg-[var(--neba-primary-soft-press)]">
            <Container size="sm">
              <Box size="sm" className="text-center">
                Container
              </Box>
            </Container>
          </div>
        )
      },
      {
        name: 'GridContainer',
        summary: {
          ko: '칸 수와 거터를 정하는 그리드의 부모',
          en: 'The grid parent: how many columns, and how wide the gutters'
        },
        path: '/components/layout/grid',
        preview: (
          <GridContainer spacing={1} padded={false} className="w-full max-w-56">
            {[0, 1, 2, 3].map((cell) => (
              <Grid key={cell} span={3}>
                <Box size="xs" variant="solid" className="text-center">
                  3
                </Box>
              </Grid>
            ))}
          </GridContainer>
        )
      },
      {
        name: 'Grid',
        summary: {
          ko: '칸 하나. 너비일 뿐 표면이 아닙니다',
          en: 'One cell — a width, and no surface'
        },
        path: '/components/layout/grid',
        preview: (
          <GridContainer spacing={1} padded={false} className="w-full max-w-56">
            <Grid span={8}>
              <Box size="xs" className="text-center">
                span 8
              </Box>
            </Grid>
            <Grid span={4}>
              <Box size="xs" className="text-center">
                4
              </Box>
            </Grid>
            <Grid span={4} offset={4}>
              <Box size="xs" className="text-center">
                offset 4
              </Box>
            </Grid>
          </GridContainer>
        )
      },
      {
        name: 'Panes',
        summary: {
          ko: '끌어서 비율을 바꾸는 영역들',
          en: 'Regions whose proportions are dragged'
        },
        path: '/components/layout/panes',
        preview: (
          <div className="h-20 w-full max-w-56">
            <Panes size="sm">
              <Pane defaultSize={35} className="p-1.5">
                <Typography level="caption" color="secondary">
                  Files
                </Typography>
              </Pane>
              <Pane className="p-1.5">
                <Typography level="caption" color="secondary">
                  Editor
                </Typography>
              </Pane>
            </Panes>
          </div>
        )
      },
      {
        name: 'ScrollArea',
        summary: {
          ko: '자기 스크롤바를 가진 상자',
          en: 'A box with a scrollbar of its own'
        },
        path: '/components/layout/scroll-area',
        preview: (
          <ScrollArea height={104} fade className="w-full max-w-48" color="secondary">
            <div className="flex flex-col gap-1 pe-3">
              {['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven'].map((row) => (
                <span key={row} className="text-[0.8125rem]">
                  {row}
                </span>
              ))}
            </div>
          </ScrollArea>
        )
      },
      {
        name: 'ScrollZone',
        summary: {
          ko: '한 방향으로 늘어놓고 그 방향으로 스크롤하는 스트립',
          en: 'A strip laid out in one direction and scrolled in it'
        },
        path: '/components/layout/scroll-zone',
        preview: (
          <div className="w-full max-w-56">
            <ScrollZone size="xs" spacing={1.5} buttons="always">
              {['Design', 'Engineering', 'Research', 'Support', 'Finance'].map((team) => (
                <Chip key={team} size="sm" color="secondary">
                  {team}
                </Chip>
              ))}
            </ScrollZone>
          </div>
        )
      },
      {
        name: 'AspectRatio',
        summary: {
          ko: '어떤 너비를 받아도 비율을 지키는 상자',
          en: 'A box that keeps a proportion whatever width it gets'
        },
        path: '/components/layout/aspect-ratio',
        preview: (
          <div className="flex w-full max-w-56 gap-2">
            <AspectRatio ratio="16 / 9" rounded className="flex-1 bg-[var(--neba-primary-soft)]">
              <div className="flex size-full items-center justify-center text-[0.6875rem] text-[var(--neba-muted-fg)]">
                16 / 9
              </div>
            </AspectRatio>
            <AspectRatio ratio={1} rounded className="w-16 bg-[var(--neba-primary-soft-press)]">
              <div className="flex size-full items-center justify-center text-[0.6875rem] text-[var(--neba-muted-fg)]">
                1 / 1
              </div>
            </AspectRatio>
          </div>
        )
      },
      {
        name: 'Portal',
        summary: {
          ko: 'DOM의 다른 곳에 그려지는 children',
          en: 'Children rendered somewhere else in the DOM'
        },
        path: '/components/layout/portal',
        preview: (
          // Drawn rather than portalled: a card in a gallery of cards has
          // nowhere useful to escape to, and a preview that vanished out of its
          // own tile would be showing the mechanism instead of the idea.
          <div className="flex w-full max-w-56 flex-col gap-1.5">
            <div className="rounded-(--neba-radius-sm) border border-dashed border-[var(--neba-border)] p-2 text-[0.6875rem] text-[var(--neba-muted-fg)]">
              written here
            </div>
            <div className="text-center text-[0.6875rem] text-[var(--neba-muted-fg)]">↓</div>
            <div className="rounded-(--neba-radius-sm) bg-[var(--neba-primary-soft)] p-2 text-[0.6875rem] text-[var(--neba-fg)]">
              rendered on &lt;body&gt;
            </div>
          </div>
        )
      }
    ]
  },
  {
    title: 'Surfaces',
    note: {
      ko: '다른 것을 담아 두는 아크릴 시트',
      en: 'Sheets of acrylic that hold everything else'
    },
    entries: [
      {
        name: 'Box',
        summary: {
          ko: '가장 단순한 표면. 묶는 일만 합니다',
          en: 'The plainest surface — it groups, and that is all'
        },
        path: '/components/surfaces/box',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-2">
            <Box size="sm">outline</Box>
            <Box size="sm" variant="solid" color="info">
              solid
            </Box>
          </div>
        )
      },
      {
        name: 'Card',
        summary: {
          ko: '제목·본문·푸터가 놓인 Box',
          en: 'A Box with a title, a body and a footer on it'
        },
        path: '/components/surfaces/card',
        preview: (
          <div className="w-full max-w-56">
            <Card
              size="sm"
              title="Starter"
              subtitle="One project"
              footer={<Button size="xs">Choose</Button>}
            >
              Ready for real users.
            </Card>
          </div>
        )
      },
      {
        name: 'Accordion',
        summary: {
          ko: '접었다 펼 수 있는 섹션들의 더미',
          en: 'A stack of sections that fold'
        },
        path: '/components/surfaces/accordion',
        preview: (
          <div className="w-full max-w-56">
            <Accordion size="sm" defaultValue={['a']}>
              <AccordionItem value="a" title="Billing">
                Charged on the first.
              </AccordionItem>
              <AccordionItem value="b" title="Regions" />
            </Accordion>
          </div>
        )
      },
      {
        name: 'Tabs',
        summary: {
          ko: '한 번에 하나만 보이는 패널들',
          en: 'One set of panels, one of which is shown'
        },
        path: '/components/surfaces/tabs',
        preview: (
          <div className="w-full max-w-56">
            <Tabs size="sm" variant="solid" defaultValue="a">
              <Tab value="a">Overview</Tab>
              <Tab value="b">Usage</Tab>
              <TabPanel value="a">All green.</TabPanel>
              <TabPanel value="b">1,284 minutes.</TabPanel>
            </Tabs>
          </div>
        )
      },
      {
        name: 'Carousel',
        summary: {
          ko: '한 장씩 보이는 슬라이드 띠',
          en: 'A strip of slides, one of which is in view'
        },
        path: '/components/surfaces/carousel',
        preview: (
          <div className="w-full max-w-56">
            <Carousel size="sm" label="Gallery">
              {['One', 'Two', 'Three'].map((slide) => (
                <div key={slide} className="flex h-16 items-center justify-center">
                  {slide}
                </div>
              ))}
            </Carousel>
          </div>
        )
      },
      {
        name: 'Pill',
        summary: {
          ko: '정보 한 줌을 담고 떠 있는 로젠지',
          en: 'A floating lozenge holding a little live information'
        },
        path: '/components/surfaces/pill',
        preview: <Pill size="sm" color="danger" startIcon={<GalleryDotIcon />} title="Recording" />
      },
      {
        name: 'Toolbar',
        summary: {
          ko: '헤더나 액션 줄로 쓰는 컨트롤 바',
          en: 'A bar of controls — a header, an action row'
        },
        path: '/components/surfaces/toolbar',
        preview: (
          <div className="w-full max-w-56">
            <Toolbar
              size="sm"
              density="compact"
              start={<Typography level="h6">Files</Typography>}
              end={
                <Button size="xs" variant="text">
                  New
                </Button>
              }
            />
          </div>
        )
      },
      {
        name: 'ChatBubble',
        summary: {
          ko: '대화 속 메시지 하나',
          en: 'One message in a conversation'
        },
        path: '/components/surfaces/chat-bubble',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-2">
            <ChatBubble size="sm" avatar={<Avatar name="Jane Doe" size="xs" />}>
              Still on for 3?
            </ChatBubble>
            <ChatBubble size="sm" side="end" variant="solid" status="read">
              Yes
            </ChatBubble>
          </div>
        )
      },
      {
        name: 'HowToSteps',
        summary: {
          ko: '번호가 매겨진 단계를 하나씩 따라가는 안내서',
          en: 'A guide walked through one numbered step at a time'
        },
        path: '/components/surfaces/how-to-steps',
        preview: (
          <div className="w-full max-w-64">
            <HowToSteps
              size="xs"
              density="compact"
              variant="text"
              navigation={false}
              railWidth={96}
              steps={[
                { title: 'Install', content: 'One package.' },
                { title: 'Import', content: 'One stylesheet.' },
                { title: 'Ship', content: 'Nothing else.' }
              ]}
            />
          </div>
        )
      },
      {
        name: 'Spoiler',
        summary: {
          ko: '요청하기 전까지 덮여 있는 내용',
          en: 'Content that stays covered until it is asked for'
        },
        path: '/components/surfaces/spoiler',
        preview: (
          <div className="w-full max-w-56">
            <Spoiler size="sm" description={false}>
              <Typography level="caption">The butler did it</Typography>
            </Spoiler>
          </div>
        )
      },
      {
        name: 'Drawer',
        summary: {
          ko: '창의 한 변에 붙는 패널. 열거나, 고정하거나',
          en: 'A panel attached to one edge — opened, or simply there'
        },
        path: '/components/surfaces/drawer',
        preview: (
          <Drawer
            size="sm"
            trigger={
              <Button size="sm" variant="outline">
                Open navigation
              </Button>
            }
            title="Workspace"
            description="Everything this account can reach."
          >
            <List density="compact">
              <ListItem>Overview</ListItem>
              <ListItem>Projects</ListItem>
              <ListItem>Members</ListItem>
            </List>
          </Drawer>
        )
      },
      {
        name: 'HoverCard',
        summary: {
          ko: '포인터가 머무를 때 열리는, 그 너머의 미리보기',
          en: 'A preview of what is on the other side, opened by resting on it'
        },
        path: '/components/surfaces/hover-card',
        preview: (
          <HoverCard
            size="sm"
            trigger={<TextLink href="#jooy2">@jooy2</TextLink>}
            title="Jooy Lee"
            description="Maintainer"
          >
            214 commits this year.
          </HoverCard>
        )
      },
      {
        name: 'Popover',
        summary: {
          ko: '자신을 연 컨트롤 옆에 열리는 시트',
          en: 'A sheet that opens beside the control that opened it'
        },
        path: '/components/surfaces/popover',
        preview: (
          <Popover
            size="sm"
            trigger={
              <Button size="sm" variant="outline">
                Share
              </Button>
            }
            title="Share this page"
            description="Anyone with the link can read it."
          >
            <PopoverClose render={<Button size="sm">Copy link</Button>} />
          </Popover>
        )
      },
      {
        name: 'Mockup',
        summary: {
          ko: '화면에 무엇이든 올릴 수 있는 기기',
          en: 'A device with a screen you can put anything on'
        },
        path: '/components/surfaces/mockup',
        preview: (
          <div className="flex w-full items-end justify-center gap-3">
            <Mockup device="desktop" hardware="laptop" width={132} />
            <Mockup device="mobile" width={44} />
          </div>
        )
      },
      {
        name: 'WindowPane',
        summary: {
          ko: '네 가지 OS 중 하나가 창을 그리는 방식으로',
          en: 'Drawn the way one of four systems draws a window'
        },
        path: '/components/surfaces/window-pane',
        preview: (
          <div className="w-full max-w-56">
            <WindowPane size="xs" title="Notes" elevation={1} height={96}>
              <div className="p-2">
                <Typography level="caption" color="secondary">
                  Anything at all, in a window.
                </Typography>
              </div>
            </WindowPane>
          </div>
        )
      },
      {
        name: 'Collapsible',
        summary: {
          ko: '혼자 서 있는 접이식 섹션 하나',
          en: 'One section that folds, standing on its own'
        },
        path: '/components/surfaces/collapsible',
        preview: (
          <div className="w-full max-w-56">
            <Collapsible size="sm" title="What is in the box">
              A sled, mostly.
            </Collapsible>
          </div>
        )
      }
    ]
  },
  {
    title: 'Display',
    note: {
      ko: '데이터를 읽히는 형태로 내놓는 것들',
      en: 'The things that put data in front of a reader'
    },
    entries: [
      {
        name: 'Typography',
        summary: {
          ko: '라이브러리의 타입 스케일',
          en: "The library's type scale, on its own"
        },
        path: '/components/display/typography',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-1">
            <Typography level="overline">Changelog</Typography>
            <Typography level="h4">Cut acrylic</Typography>
            <Typography level="caption">Updated 2 minutes ago</Typography>
          </div>
        )
      },
      {
        name: 'AppLogo',
        summary: {
          ko: '이미지든 글자든, 제품의 마크를 제대로 그리는 것',
          en: "A product's mark, whether it is a file or a single letter"
        },
        path: '/components/display/app-logo',
        preview: (
          <div className="flex items-center gap-4">
            <AppLogo name="Neba" />
            <AppLogo name="Neba" shape="app" />
            <AppLogo name="Neba" shape="circle" color="secondary" />
          </div>
        )
      },
      {
        name: 'VisuallyHidden',
        summary: {
          ko: '화면에는 없고 스크린 리더에는 있는 내용',
          en: 'Content a screen reader has and the screen does not'
        },
        path: '/components/display/visually-hidden',
        preview: (
          <div className="flex w-full max-w-56 flex-col items-center gap-2">
            <Button variant="text">
              <span aria-hidden="true">7</span>
              <VisuallyHidden>7 unread messages</VisuallyHidden>
            </Button>
            <span className="text-center text-[0.6875rem] text-[var(--neba-muted-fg)]">
              reads “7 unread messages”
            </span>
          </div>
        )
      },
      {
        name: 'Divider',
        summary: { ko: '두 가지 사이의 선', en: 'A rule between two things' },
        path: '/components/display/divider',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-3">
            <Divider />
            <Divider>OR</Divider>
          </div>
        )
      },
      {
        name: 'Chip',
        summary: {
          ko: '태그·필터·상태를 담는 작은 토큰',
          en: 'A compact token: tag, filter, status'
        },
        path: '/components/display/chip',
        preview: (
          <div className="flex flex-wrap items-center justify-center gap-2">
            <Chip size="sm">design-system</Chip>
            <Chip size="sm" variant="solid" color="success">
              Live
            </Chip>
            <Chip size="sm" color="danger" count={12}>
              Errors
            </Chip>
          </div>
        )
      },
      {
        name: 'CodeBlock',
        summary: {
          ko: '문법 하이라이팅과 복사 버튼이 있는 코드 뷰어',
          en: 'A code viewer with syntax highlighting and a copy button'
        },
        path: '/components/display/code-block',
        preview: (
          <div className="w-full max-w-64">
            <CodeBlock
              size="xs"
              language="bash"
              prompt="$"
              showLanguage={false}
              code={'npm install neba'}
            />
          </div>
        )
      },
      {
        name: 'DataTable',
        summary: {
          ko: '수만 행을 렉 없이 다루는 표',
          en: 'A table that keeps up with tens of thousands of rows'
        },
        path: '/components/display/data-table',
        preview: (
          <div className="w-full max-w-56">
            <DataTable
              size="xs"
              height={92}
              striped
              sortable
              selectionMode="single"
              defaultSelected={['b']}
              getRowKey={(row) => row.id}
              headers={[
                { key: 'sensor', label: 'Sensor' },
                { key: 'c', label: '°C', width: 52, align: 'end' }
              ]}
              items={[
                { id: 'a', sensor: 'S-0041', c: 21.4 },
                { id: 'b', sensor: 'S-0042', c: 19.8 },
                { id: 'c', sensor: 'S-0043', c: 24.1 },
                { id: 'd', sensor: 'S-0044', c: 20.6 }
              ]}
            />
          </div>
        )
      },
      {
        name: 'Table',
        summary: {
          ko: '열과 행 데이터로 그려지는 표',
          en: 'A grid rendered from columns and rows'
        },
        path: '/components/display/table',
        preview: (
          <div className="w-full max-w-56">
            <Table
              size="xs"
              headers={[
                { key: 'env', label: 'Env' },
                { key: 'time', label: 'Time', align: 'end' }
              ]}
              items={[
                { env: 'production', time: '4m' },
                { env: 'staging', time: '2m' }
              ]}
            />
          </div>
        )
      },
      {
        name: 'List',
        summary: {
          ko: '반복되는 것을 담는 행의 묶음',
          en: 'A stack of rows, for anything that repeats'
        },
        path: '/components/display/list',
        preview: (
          <div className="w-full max-w-56">
            <List size="sm" dividers>
              <ListItem onClick={() => {}} selected>
                production
              </ListItem>
              <ListItem onClick={() => {}}>staging</ListItem>
            </List>
          </div>
        )
      },
      {
        name: 'Badge',
        summary: {
          ko: '다른 것의 모서리에 걸리는 작은 표식',
          en: 'A small mark in the corner of something else'
        },
        path: '/components/display/badge',
        preview: (
          <div className="flex items-center gap-6">
            <Badge content={4} label="4 unread">
              <Button size="sm" variant="outline" color="secondary">
                Inbox
              </Button>
            </Badge>
            <Badge dot color="success" overlap="circle" label="Online">
              <Avatar name="Jane Doe" />
            </Badge>
          </div>
        )
      },
      {
        name: 'Avatar',
        summary: {
          ko: '사람이나 사물의 그림. 없으면 이니셜이 대신 섭니다',
          en: 'A picture of a person or a thing, with initials standing in'
        },
        path: '/components/display/avatar',
        preview: (
          <div className="flex items-center gap-3">
            <Avatar name="Jane Doe" size="lg" />
            <Avatar name="Sam Park" size="lg" variant="solid" color="success" />
            <Avatar name="홍길동" size="lg" variant="outline" color="info" />
            <Avatar size="lg" shape="square" color="secondary" />
          </div>
        )
      },
      {
        name: 'Icon',
        summary: {
          ko: '정해진 크기와 색으로 그려지는 글리프',
          en: 'A glyph at a known size, in a known colour'
        },
        path: '/components/display/icon',
        preview: (
          <div className="flex items-end gap-4">
            <Icon icon={<GalleryStarIcon />} size="sm" color="warning" label="Small" />
            <Icon icon={<GalleryStarIcon />} size="lg" color="warning" label="Large" />
            <Icon icon={<GalleryBellIcon />} size="lg" color="info" label="Notifications" />
          </div>
        )
      },
      {
        name: 'Blockquote',
        summary: {
          ko: '내 말과 구분해 놓은 남의 말',
          en: "Somebody else's words, set apart from your own"
        },
        path: '/components/display/blockquote',
        preview: (
          <div className="w-full max-w-64">
            <Blockquote size="xs" author="Saint-Exupéry">
              Perfection is achieved when there is nothing left to take away.
            </Blockquote>
          </div>
        )
      },
      {
        name: 'Shortcut',
        summary: {
          ko: '키보드 키, 또는 키 조합',
          en: 'A keyboard key, or a combination of them'
        },
        path: '/components/display/shortcut',
        preview: (
          <div className="flex flex-col items-center gap-2">
            <Shortcut size="sm" keys="Mod+K" />
            <Shortcut size="sm" keys="Mod+Shift+P" />
          </div>
        )
      },
      {
        name: 'Highlight',
        summary: {
          ko: '찾고 있던 단어에 표시하기',
          en: 'Marks the words a reader is looking for'
        },
        path: '/components/display/highlight',
        preview: (
          <div className="max-w-56 text-center text-[0.75rem]/[1.6]">
            <Highlight query="acrylic">
              A sheet of cut acrylic, not a moulded plastic key.
            </Highlight>
          </div>
        )
      },
      {
        name: 'Timeline',
        summary: {
          ko: '일어나는 순서대로 놓인 단계들',
          en: 'A sequence of steps, in the order they happen'
        },
        path: '/components/display/timeline',
        preview: (
          <div className="w-full max-w-56">
            <Timeline size="sm" active={1}>
              <TimelineItem title="Packed" meta="Mon" />
              <TimelineItem title="In transit" meta="Tue" />
              <TimelineItem title="Delivered" />
            </Timeline>
          </div>
        )
      },
      {
        name: 'TreeView',
        summary: {
          ko: '접었다 펼 수 있는 계층 목록',
          en: 'A hierarchy of rows that open and shut'
        },
        path: '/components/display/tree-view',
        preview: (
          <div className="w-full max-w-56">
            <TreeView size="sm" lines="folder" defaultExpanded={['src']} label="Files">
              <TreeItem value="src" label="src">
                <TreeItem value="index" label="index.ts" />
                <TreeItem value="types" label="types.ts" />
              </TreeItem>
              <TreeItem value="readme" label="README.md" />
            </TreeView>
          </div>
        )
      },
      {
        name: 'Anchor',
        summary: {
          ko: '지금 읽고 있는 페이지의 제목 목록',
          en: 'The list of headings on the page being read'
        },
        path: '/components/display/anchor',
        preview: (
          <Anchor
            size="sm"
            activeHref="#gallery-anchor-b"
            label="On this page"
            items={[
              { href: '#gallery-anchor-a', label: 'Overview' },
              { href: '#gallery-anchor-b', label: 'Installation' },
              { href: '#gallery-anchor-c', label: 'Configuration', depth: 1 }
            ]}
          />
        )
      },
      {
        name: 'DataList',
        summary: {
          ko: '어떤 것들과 그것들의 이름',
          en: 'A list of things and what they are called'
        },
        path: '/components/display/data-list',
        preview: (
          <DataList size="sm" density="compact" className="w-full max-w-56">
            <DataListItem label="Status">Live</DataListItem>
            <DataListItem label="Region">Frankfurt</DataListItem>
            <DataListItem label="Commit">8f2c1a</DataListItem>
          </DataList>
        )
      },
      {
        name: 'AvatarGroup',
        summary: {
          ko: '겹쳐 쌓인 아바타와, 남은 수',
          en: 'A stack of avatars, and the count that did not fit'
        },
        path: '/components/display/avatar-group',
        preview: (
          <AvatarGroup size="sm" max={3} total={12}>
            <Avatar name="Jane Doe" />
            <Avatar name="Kim Minji" />
            <Avatar name="Alex Park" />
            <Avatar name="Sam Lee" />
          </AvatarGroup>
        )
      },
      {
        name: 'Breadcrumb',
        summary: {
          ko: '지금 페이지 위쪽의 경로',
          en: 'The trail of pages above this one'
        },
        path: '/components/display/breadcrumb',
        preview: (
          <Breadcrumb size="sm">
            <BreadcrumbItem href="#home">Home</BreadcrumbItem>
            <BreadcrumbItem href="#projects">Projects</BreadcrumbItem>
            <BreadcrumbItem>Neba</BreadcrumbItem>
          </Breadcrumb>
        )
      },
      {
        name: 'TextLink',
        summary: {
          ko: '문장 안에서든 혼자서든 쓰는 링크',
          en: 'A link, in a sentence or on its own'
        },
        path: '/components/display/text-link',
        preview: (
          <div className="flex flex-col items-center gap-2">
            <TextLink href="#components" size="sm">
              Components
            </TextLink>
            <TextLink href="#getting-started" size="sm" newTab color="primary">
              Getting started
            </TextLink>
          </div>
        )
      }
    ]
  },
  {
    title: 'Charts',
    note: {
      ko: '숫자를 그림으로 보여 주는 것들',
      en: 'The things that draw numbers'
    },
    entries: [
      {
        name: 'Statistic',
        summary: {
          ko: '이름이 붙은 숫자와, 그것이 얼마나 움직였는지',
          en: 'A number with its name on it, and how far it moved'
        },
        path: '/components/charts/statistic',
        preview: (
          <div className="w-full max-w-56">
            <Statistic
              size="sm"
              label="Active users"
              value={1284}
              previousValue={1102}
              caption="vs. last month"
            />
          </div>
        )
      },
      {
        name: 'Sparkline',
        summary: {
          ko: '축도 범례도 없는, 단어 크기의 추세 그림',
          en: 'A word-sized picture of a trend, with no axes and no legend'
        },
        path: '/components/charts/sparkline',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-3">
            <Sparkline
              data={[18, 22, 19, 27, 24, 31, 29, 36, 34, 41, 38, 47]}
              label="Signups"
              endDot
            />
            <Sparkline
              data={[8, 6, 11, 7, 4, 9, 5, 2, 6, 3, 4, 2]}
              shape="bar"
              color="danger"
              label="Errors"
            />
          </div>
        )
      },
      {
        name: 'LineChart',
        summary: {
          ko: '순서가 있는 축 위의 값들, 선으로 이어서',
          en: 'Values along an ordered axis, joined into a line'
        },
        path: '/components/charts/line-chart',
        preview: (
          <div className="w-full">
            <LineChart
              size="xs"
              height={110}
              legend={false}
              label="Sessions by platform"
              categories={['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']}
              series={[
                { name: 'Web', data: [18, 22, 27, 25, 31, 36] },
                { name: 'Mobile', data: [9, 13, 15, 19, 22, 28] }
              ]}
            />
          </div>
        )
      },
      {
        name: 'AreaChart',
        summary: {
          ko: '선 아래를 채워, 합해서 의미가 있는 양을',
          en: 'A line with the space under it filled, for a quantity that adds up'
        },
        path: '/components/charts/area-chart',
        preview: (
          <div className="w-full">
            <AreaChart
              size="xs"
              height={110}
              legend={false}
              stacked
              curve="smooth"
              label="Storage by tier"
              categories={['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']}
              series={[
                { name: 'Hot', data: [12, 14, 15, 17, 18, 21] },
                { name: 'Archive', data: [30, 34, 39, 44, 51, 58] }
              ]}
            />
          </div>
        )
      },
      {
        name: 'BarChart',
        summary: {
          ko: 'category 사이의 길이를 견주는 것',
          en: 'Lengths, compared across categories'
        },
        path: '/components/charts/bar-chart',
        preview: (
          <div className="w-full">
            <BarChart
              size="xs"
              height={110}
              legend={false}
              label="Deploys per team"
              categories={['Platform', 'Payments', 'Growth', 'Mobile']}
              series={[{ name: 'Deploys', data: [318, 264, 197, 152] }]}
            />
          </div>
        )
      },
      {
        name: 'ScatterChart',
        summary: {
          ko: '두 값을 서로에 대해 찍어, 함께 움직이는지를',
          en: 'Two measures against each other, for whether they move together'
        },
        path: '/components/charts/scatter-chart',
        preview: (
          <div className="w-full">
            <ScatterChart
              size="xs"
              height={110}
              legend={false}
              label="Pages read against session length"
              series={[
                {
                  name: 'Visits',
                  data: [
                    { x: 22, y: 2 },
                    { x: 41, y: 3 },
                    { x: 68, y: 4 },
                    { x: 90, y: 5 },
                    { x: 112, y: 8 },
                    { x: 141, y: 10 },
                    { x: 166, y: 9 },
                    { x: 203, y: 11 }
                  ]
                }
              ]}
            />
          </div>
        )
      },
      {
        name: 'HeatmapChart',
        summary: {
          ko: '셀마다 크기를 하나씩, 색으로',
          en: 'A magnitude per cell, coloured rather than measured'
        },
        path: '/components/charts/heatmap-chart',
        preview: (
          <div className="w-full">
            <HeatmapChart
              size="xs"
              height={110}
              legend={false}
              label="Sessions by hour and weekday"
              categories={['00', '04', '08', '12', '16', '20']}
              series={[
                { name: 'Mon', data: [4, 3, 24, 38, 51, 18] },
                { name: 'Wed', data: [3, 2, 29, 43, 58, 21] },
                { name: 'Fri', data: [5, 3, 25, 37, 48, 26] },
                { name: 'Sun', data: [8, 3, 9, 19, 25, 21] }
              ]}
            />
          </div>
        )
      },
      {
        name: 'TimelineChart',
        summary: {
          ko: '시간 위의 기간들 — 한 행에 하나씩',
          en: 'Work against time, a row per thing'
        },
        path: '/components/charts/timeline-chart',
        preview: (
          <div className="w-full">
            <TimelineChart
              size="xs"
              height={110}
              label="Release plan"
              series={[
                {
                  name: 'Design',
                  data: [
                    { start: new Date('2026-01-06'), end: new Date('2026-02-24'), label: 'Design' }
                  ]
                },
                {
                  name: 'Build',
                  data: [
                    { start: new Date('2026-02-10'), end: new Date('2026-04-21'), label: 'Build' }
                  ]
                },
                {
                  name: 'Launch',
                  data: [
                    { start: new Date('2026-04-07'), end: new Date('2026-05-19'), label: 'Launch' }
                  ]
                }
              ]}
            />
          </div>
        )
      },
      {
        name: 'GaugeChart',
        summary: {
          ko: '미리 정해진 범위 위의 값 하나를 계기판으로',
          en: 'One number on a known scale, drawn as a dial'
        },
        path: '/components/charts/gauge-chart',
        preview: (
          <GaugeChart
            size="sm"
            height={96}
            padded={false}
            className="w-full max-w-40"
            label="Memory"
            caption="Memory"
            value={82}
            thresholds={[
              { from: 70, color: 'warning' },
              { from: 90, color: 'danger' }
            ]}
          />
        )
      },
      {
        name: 'PieChart',
        summary: {
          ko: '전체에 대한 부분을, 한눈에',
          en: 'Parts of a whole, at a glance'
        },
        path: '/components/charts/pie-chart',
        preview: (
          <div className="w-full">
            <PieChart
              size="xs"
              height={110}
              shape="donut"
              legend={false}
              label="Traffic by source"
              categories={['Organic', 'Direct', 'Paid', 'Referral']}
              data={[18420, 9260, 6140, 3080]}
            />
          </div>
        )
      }
    ]
  },
  {
    title: 'Feedback',
    note: {
      ko: '무슨 일이 일어났는지, 또는 일어나는 중인지 말해 주는 것들',
      en: 'The things that say what happened, or what is still happening'
    },
    entries: [
      {
        name: 'Alert',
        summary: {
          ko: '페이지 안에 놓이는 알림',
          en: 'A message set into the page it is about'
        },
        path: '/components/feedback/alert',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-2">
            <Alert size="sm" color="success">
              Deployed
            </Alert>
            <Alert size="sm" color="danger" variant="text">
              Build failed
            </Alert>
          </div>
        )
      },
      {
        name: 'Dialog',
        summary: {
          ko: '답할 때까지 페이지를 가져가는 시트',
          en: 'A sheet that takes the page away'
        },
        path: '/components/feedback/dialog',
        preview: (
          <Dialog
            size="sm"
            trigger={<Button size="sm">Delete workspace</Button>}
            title="Delete this workspace?"
            description="This cannot be undone."
            actions={<DialogClose render={<Button size="sm">Cancel</Button>} />}
          />
        )
      },
      {
        name: 'Overlay',
        summary: {
          ko: '페이지를 쓰지 못하게 덮는 한 겹',
          en: 'A sheet over the page that stops it being used'
        },
        path: '/components/feedback/overlay',
        preview: <OverlayButton />
      },
      {
        name: 'Skeleton',
        summary: {
          ko: '아직 불러오지 않은 것의 형태',
          en: 'The shape of something that has not loaded yet'
        },
        path: '/components/feedback/skeleton',
        preview: (
          <div className="flex w-full max-w-56 items-center gap-3">
            <Skeleton shape="circle" size="lg" />
            <Skeleton lines={3} className="flex-1" />
          </div>
        )
      },
      {
        name: 'Tour',
        summary: {
          ko: '이미 있는 페이지 위를 걸으며 안내하는 것',
          en: 'A guided walk over a page that already exists'
        },
        path: '/components/feedback/tour',
        preview: <GalleryTour />
      },
      {
        name: 'Meter',
        summary: {
          ko: '미리 정해진 범위 안에서 어떤 양이 얼마나 되는지',
          en: 'How much of something there is, on a known scale'
        },
        path: '/components/feedback/meter',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-3">
            <Meter size="sm" value={38} label="Storage" showValue />
            <Meter
              size="sm"
              value={92}
              label="Seats"
              showValue
              thresholds={[
                { from: 70, color: 'warning' },
                { from: 90, color: 'danger' }
              ]}
            />
          </div>
        )
      },
      {
        name: 'Empty',
        summary: {
          ko: '내용이 있었어야 할 자리에 대신 서는 것',
          en: 'What stands where content would have been'
        },
        path: '/components/feedback/empty',
        preview: (
          <Empty size="sm" density="compact" title="No results">
            Nothing matched that filter.
          </Empty>
        )
      },
      {
        name: 'Confirm',
        summary: {
          ko: '기다릴 수 있는 "정말 하시겠습니까?"',
          en: '“Are you sure?” as something you await'
        },
        path: '/components/feedback/confirm',
        preview: (
          // Drawn rather than raised: a card that took the whole gallery away
          // to show itself would be demonstrating the wrong thing.
          <div className="flex w-full max-w-56 flex-col gap-2 rounded-(--neba-radius-md) border border-[var(--neba-border)] bg-[var(--neba-surface)] p-3">
            <span className="text-[0.8125rem] font-medium text-[var(--neba-fg)]">
              Delete the project?
            </span>
            <span className="text-[0.6875rem] text-[var(--neba-muted-fg)]">
              Everything in it goes too.
            </span>
            <div className="flex justify-end gap-1.5">
              <Button size="xs" variant="text" color="secondary">
                Cancel
              </Button>
              <Button size="xs" color="danger">
                Delete
              </Button>
            </div>
          </div>
        )
      },
      {
        name: 'Toast',
        summary: {
          ko: '스스로 도착하는 알림',
          en: 'A message that arrives on its own'
        },
        path: '/components/feedback/toast',
        preview: (
          <ToastProvider position="bottom-center" width={280}>
            <ToastButton />
          </ToastProvider>
        )
      },
      {
        name: 'Tooltip',
        summary: {
          ko: '마우스를 올리면 뜨는 짧은 설명',
          en: 'A short label on hover'
        },
        path: '/components/feedback/tooltip',
        preview: (
          <Tooltip content="Copy the deploy URL" delay={0}>
            <Button size="sm" variant="outline" color="secondary">
              Hover me
            </Button>
          </Tooltip>
        )
      },
      {
        name: 'ProgressLinear',
        summary: { ko: '차오르는 막대', en: 'A bar that fills' },
        path: '/components/feedback/progress-linear',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-4">
            <ProgressLinear value={64} />
            <ProgressLinear color="secondary" />
          </div>
        )
      },
      {
        name: 'ProgressCircular',
        summary: { ko: '차오르는 고리', en: 'A ring that fills' },
        path: '/components/feedback/progress-circular',
        preview: (
          <div className="flex items-center gap-4">
            <ProgressCircular value={72} size="lg" />
            <ProgressCircular size="lg" color="secondary" />
          </div>
        )
      },
      {
        name: 'ProgressBox',
        summary: {
          ko: '차례로 불이 들어오는 아크릴 판',
          en: 'Acrylic plates that light up'
        },
        path: '/components/feedback/progress-box',
        preview: (
          <div className="flex flex-col items-center gap-4">
            <ProgressBox size="lg" />
            <ProgressBox size="lg" value={62} color="info" />
          </div>
        )
      }
    ]
  },
  {
    title: 'Transitions',
    note: {
      ko: '무엇이든 감싸 움직이게 하는 래퍼',
      en: 'Wrappers that make anything move'
    },
    entries: [
      {
        name: 'AnimateFade',
        summary: { ko: '불투명도만으로 나타나고 사라짐', en: 'Arriving on opacity alone' },
        path: '/components/transitions/animate-fade',
        preview: (
          <AnimateFade duration={1400} repeat="infinite" alternate>
            <Chip>Fade</Chip>
          </AnimateFade>
        )
      },
      {
        name: 'AnimateGrow',
        summary: { ko: '한 점에서 펼쳐짐', en: 'Unfolding from a point' },
        path: '/components/transitions/animate-grow',
        preview: (
          <AnimateGrow duration={1400} repeat="infinite" alternate origin="bottom left">
            <Chip color="info">Grow</Chip>
          </AnimateGrow>
        )
      },
      {
        name: 'AnimateZoom',
        summary: { ko: '가운데에서 다가옴', en: 'Coming forward from the middle' },
        path: '/components/transitions/animate-zoom',
        preview: (
          <AnimateZoom duration={1400} repeat="infinite" alternate>
            <Chip color="success">Zoom</Chip>
          </AnimateZoom>
        )
      },
      {
        name: 'AnimateSlide',
        summary: { ko: '한쪽 변에서 미끄러져 들어옴', en: 'Travelling in from one edge' },
        path: '/components/transitions/animate-slide',
        preview: (
          <div className="overflow-hidden">
            <AnimateSlide from="left" duration={1400} repeat="infinite" alternate>
              <Chip color="secondary">Slide</Chip>
            </AnimateSlide>
          </div>
        )
      },
      {
        name: 'AnimateRotate',
        summary: { ko: '한 점을 축으로 회전', en: 'Turning about a point' },
        path: '/components/transitions/animate-rotate',
        preview: (
          <AnimateRotate
            from={0}
            to={360}
            duration={3200}
            repeat="infinite"
            easing="linear"
            fade={false}
          >
            <Icon icon={<GalleryStarIcon />} size="xl" color="warning" label="Rotating" />
          </AnimateRotate>
        )
      },
      {
        name: 'AnimateBlink',
        summary: { ko: '정해진 바닥값까지 맥동', en: 'Pulsing down to a floor' },
        path: '/components/transitions/animate-blink',
        preview: (
          <AnimateBlink min={0.3} duration={1200}>
            <Chip color="danger" variant="solid">
              Live
            </Chip>
          </AnimateBlink>
        )
      },
      {
        name: 'AnimateAppear',
        summary: { ko: '하나씩 차례로 내려앉음', en: 'Settling into place one after another' },
        path: '/components/transitions/animate-appear',
        preview: (
          <AnimateAppear stagger={220} duration={600} repeat="infinite" className="flex gap-2">
            <Chip size="sm">One</Chip>
            <Chip size="sm">Two</Chip>
            <Chip size="sm">Three</Chip>
          </AnimateAppear>
        )
      },
      {
        name: 'AnimateTyping',
        summary: { ko: '한 글자씩 쓰이는 텍스트', en: 'Text typed one character at a time' },
        path: '/components/transitions/animate-typing',
        preview: (
          <AnimateTyping
            className="font-mono text-sm text-[var(--vp-c-text-1)]"
            text="Typing…"
            repeat="infinite"
            erase
            speed={10}
          />
        )
      },
      {
        name: 'AnimateLighting',
        summary: { ko: '바깥을 도는 빛', en: 'A light travelling around the outside' },
        path: '/components/transitions/animate-lighting',
        preview: (
          <AnimateLighting size="md" arc={70} duration={2400}>
            <Box size="md" density="compact">
              <Typography level="caption">Working</Typography>
            </Box>
          </AnimateLighting>
        )
      },
      {
        name: 'AnimateMarquee',
        summary: { ko: '끝없이 흘러가는 띠', en: 'A strip scrolling steadily past' },
        path: '/components/transitions/animate-marquee',
        preview: (
          <AnimateMarquee className="w-full max-w-56" speed={35} gap="1rem">
            {['Northwind', 'Contoso', 'Initech'].map((name) => (
              <Chip key={name} size="sm">
                {name}
              </Chip>
            ))}
          </AnimateMarquee>
        )
      },
      {
        name: 'AnimateHeadline',
        summary: { ko: '아래에서 올라오며 교체되는 줄', en: 'One line replacing the one above it' },
        path: '/components/transitions/animate-headline',
        preview: (
          <AnimateHeadline interval={1800} className="text-base font-semibold">
            <span>faster</span>
            <span>quieter</span>
            <span>yours</span>
          </AnimateHeadline>
        )
      }
    ]
  }
];

/** An overlay has no trigger of its own, so the card holds the state instead. */
function OverlayButton() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button size="sm" variant="outline" onClick={() => setOpen(true)}>
        Block the page
      </Button>
      <Overlay open={open} onOpenChange={setOpen} dismissible tone="blur" label="Working">
        <div className="flex flex-col items-center gap-3">
          <ProgressCircular size="lg" />
          <Button size="sm" onClick={() => setOpen(false)}>
            Done
          </Button>
        </div>
      </Overlay>
    </>
  );
}

/** The toast card needs a hook, and a hook needs a component of its own. */
function ToastButton() {
  const toast = useToast();

  return (
    <Button
      size="sm"
      onClick={() => toast.add({ color: 'success', title: 'Deployed', timeout: 2500 })}
    >
      Raise a toast
    </Button>
  );
}

function EntryCard({ entry, locale, base }: { entry: Entry; locale: Locale; base: string }) {
  return (
    <a
      href={`${base}${entry.path}`}
      className="flex flex-col overflow-hidden rounded-xl border border-[var(--vp-c-divider)] transition-colors hover:border-[var(--vp-c-brand-1)]"
    >
      <div className="flex min-h-36 flex-1 items-center justify-center bg-[var(--vp-c-bg-soft)] p-5">
        {entry.preview}
      </div>
      <div className="flex flex-col gap-0.5 border-t border-[var(--vp-c-divider)] bg-[var(--vp-c-bg)] px-4 py-3">
        <span className="text-[0.875rem] font-semibold text-[var(--vp-c-text-1)]">
          {entry.name}
        </span>
        <span className="text-[0.75rem] text-[var(--vp-c-text-2)]">{entry.summary[locale]}</span>
      </div>
    </a>
  );
}

export default function AllComponents({
  locale = DEFAULT_LOCALE,
  base = ''
}: {
  locale?: Locale;
  /** URL prefix of the locale this page is in — `''` at the root, `/ko` otherwise. */
  base?: string;
}) {
  return (
    <div className="flex flex-col gap-10">
      {GROUPS.map((group) => (
        <section key={group.title} className="flex flex-col gap-4">
          <div className="flex flex-col gap-1">
            <span className="text-[0.8125rem] font-semibold tracking-wide text-[var(--vp-c-text-1)] uppercase">
              {group.title}
            </span>
            <span className="text-[0.8125rem] text-[var(--vp-c-text-2)]">{group.note[locale]}</span>
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {group.entries.map((entry) => (
              <EntryCard key={entry.name} entry={entry} locale={locale} base={base} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}

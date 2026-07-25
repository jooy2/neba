import type { ReactNode } from 'react';
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
  Dialog,
  DialogClose,
  Divider,
  FilePicker,
  List,
  ListItem,
  Menu,
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
              <span className="flex size-8 items-center justify-center rounded-full bg-(--n-soft-press) text-[0.75rem] font-semibold text-(--neba-fg)">
                JD
              </span>
            </Badge>
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
  }
];

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

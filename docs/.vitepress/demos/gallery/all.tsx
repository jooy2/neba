import { useState, type ReactNode } from 'react';
import {
  Accordion,
  AccordionItem,
  Alert,
  Badge,
  Blockquote,
  Box,
  Button,
  ButtonGroup,
  Card,
  Carousel,
  Checkbox,
  Chip,
  Combobox,
  Container,
  DatePicker,
  DateRangePicker,
  DateTimePicker,
  Dialog,
  DialogClose,
  Divider,
  FilePicker,
  Grid,
  GridContainer,
  Highlight,
  Icon,
  IconButton,
  List,
  ListItem,
  Menu,
  MenuItem,
  MenuSeparator,
  MenuSubmenu,
  NumberField,
  Overlay,
  Pagination,
  Pill,
  ProgressBox,
  ProgressCircular,
  ProgressLinear,
  Radio,
  RadioGroup,
  Segment,
  SegmentedButton,
  Select,
  Shortcut,
  Slider,
  Statistic,
  Switch,
  Tab,
  Table,
  TabPanel,
  Tabs,
  TextField,
  TimePicker,
  Timeline,
  TimelineItem,
  ToastProvider,
  Toolbar,
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

/* Fixed dates, so a card looks the same in every screenshot and every locale.
   The pickers themselves default to today when they are handed nothing. */
const GALLERY_DAY = new Date(2026, 6, 27);
const GALLERY_DAY_LATER = new Date(2026, 7, 3);
const GALLERY_MOMENT = new Date(2026, 6, 27, 9, 30);

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
        preview: (
          <Pill size="sm" color="danger" startIcon={<GalleryDotIcon />}>
            Recording
          </Pill>
        )
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
        name: 'Statistic',
        summary: {
          ko: '이름이 붙은 숫자와, 그것이 얼마나 움직였는지',
          en: 'A number with its name on it, and how far it moved'
        },
        path: '/components/display/statistic',
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

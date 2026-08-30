/**
 * The props tables, as data.
 *
 * They live here rather than as Markdown tables for three reasons: the shared
 * vocabulary (`variant`, `size`, `color`, `density`, `elevation`) is written
 * once and reused with per-component defaults, a union type like
 * `'solid' | 'outline' | 'text'` does not have to be escaped one pipe at a
 * time, and both locales come off one row — a Korean and an English table
 * cannot drift into listing different props.
 *
 * Rendered by `theme/components/PropsTable.vue`.
 */

import type { Locale } from './i18n';

/** Every human-readable string in here is written twice, once per locale. */
type Text = Record<Locale, string>;

export interface PropRow {
  name: string;
  type: string;
  /** Omitted when the prop has no default — rendered as `—`. */
  default?: string;
  required?: boolean;
  /** Part of the shared vocabulary in `src/types.ts`; tagged in the table. */
  shared?: boolean;
  description: Text;
}

const SIZE = "'xs' | 'sm' | 'md' | 'lg' | 'xl'";
const COLOR = "'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'";
const VARIANT = "'solid' | 'outline' | 'text'";
const DENSITY = "'default' | 'compact'";
const ELEVATION = '0 | 1 | 2 | 3';
const ORIENTATION = "'horizontal' | 'vertical'";
const SIDE = "'top' | 'right' | 'bottom' | 'left'";
const POSITION = "'static' | 'sticky' | 'fixed'";
const BREAKPOINT = "'xs' | 'sm' | 'md' | 'lg' | 'xl'";
const RESPONSIVE = 'number | Partial<Record<NebaBreakpoint, number>>';
const JUSTIFY_CONTENT =
  "'start' | 'center' | 'end' | 'space-between' | 'space-around' | 'space-evenly' | 'stretch'";
const ALIGN_ITEMS = "'start' | 'center' | 'end' | 'stretch' | 'baseline'";
const ALIGN_SELF = "'auto' | 'start' | 'center' | 'end' | 'stretch' | 'baseline'";

/** The padding pair the three layout components share. */
const layoutPaddingProps: PropRow[] = [
  {
    name: 'size',
    type: SIZE,
    default: "'md'",
    shared: true,
    description: {
      ko: '여백의 크기. Box에서와 같이 높이도 타입 스케일도 건드리지 않으며, 거터를 정하는 spacing과는 별개입니다',
      en: "The padding's scale. As on Box it never touches a height or the type scale, and it is not the gutter — that is spacing"
    }
  },
  {
    name: 'density',
    type: DENSITY,
    default: "'default'",
    shared: true,
    description: {
      ko: '여백만 바꿉니다',
      en: 'Padding only'
    }
  }
];

/** The escape hatch every layout component offers, spelled the same way. */
function renderProp(example: string): PropRow {
  return {
    name: 'render',
    type: 'useRender.RenderProp',
    description: {
      ko: `div 대신 다른 요소로 렌더링합니다 (${example}). Base UI의 render prop 그대로`,
      en: `Renders something other than a div (${example}). Base UI's own escape hatch`
    }
  };
}

/** `size` and `color` alone, for the controls that have no surface to weigh. */
function scaleProps(size: string, color = "'primary'", colorDescription?: Text): PropRow[] {
  return [
    {
      name: 'size',
      type: SIZE,
      default: size,
      shared: true,
      description: { ko: '높이와 타입 스케일', en: 'Height and type scale' }
    },
    {
      name: 'color',
      type: COLOR,
      default: color,
      shared: true,
      description: colorDescription ?? {
        ko: '의미론적 색 역할. 임의 색상값은 받지 않습니다',
        en: 'Semantic colour role. Arbitrary colour values are not accepted'
      }
    }
  ];
}

/** The four slots a form control puts around itself. */
const fieldProps: PropRow[] = [
  {
    name: 'label',
    type: 'ReactNode',
    description: {
      ko: '컨트롤과 연결되는 라벨. Base UI Field가 묶어 줍니다',
      en: "The label, wired to the control by Base UI's Field"
    }
  },
  {
    name: 'description',
    type: 'ReactNode',
    description: { ko: '보조 설명', en: 'Helper text' }
  },
  {
    name: 'error',
    type: 'ReactNode',
    description: {
      ko: '오류 메시지. 값이 있으면 invalid 상태도 함께 켜지고 색 계열이 danger로 넘어갑니다',
      en: 'Error message. Its presence turns the control invalid and re-points the colour family at danger'
    }
  },
  {
    name: 'invalid',
    type: 'boolean',
    default: '!!error',
    description: {
      ko: '메시지 없이 invalid만 켭니다. 외부 폼 라이브러리가 유효성을 가질 때',
      en: 'Forces the invalid state without a message, for when a form library owns validity'
    }
  }
];

/** The two inert states, spelled the same way on every control. */
const inertProps: PropRow[] = [
  {
    name: 'readOnly',
    type: 'boolean',
    default: 'false',
    description: {
      ko: '값은 보이지만 바꿀 수 없음. 색과 가장자리는 유지한 채 채도만 빠집니다',
      en: 'Shown but not changeable. Keeps its colour and edge, drains the saturation'
    }
  },
  {
    name: 'disabled',
    type: 'boolean',
    default: 'false',
    description: {
      ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
      en: 'Unavailable. Drops the colour family for neutral grey'
    }
  }
];

interface SharedOptions {
  variant: string;
  size: string;
  color?: string;
  density?: string;
  elevation?: string;
  variantDescription?: Text;
  sizeDescription?: Text;
  colorDescription?: Text;
  densityDescription?: Text;
  elevationDescription?: Text;
}

/** The four `NebaStyleProps` axes plus `elevation`, with per-component defaults. */
function sharedProps(options: SharedOptions): PropRow[] {
  return [
    {
      name: 'variant',
      type: VARIANT,
      default: options.variant,
      shared: true,
      description: options.variantDescription ?? {
        ko: '표면의 무게. 채움 / 하이라인 / 없음',
        en: 'Weight of the surface: filled, hairline, or none'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: options.size,
      shared: true,
      description: options.sizeDescription ?? {
        ko: '높이와 타입 스케일',
        en: 'Height and type scale'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: options.color ?? "'primary'",
      shared: true,
      description: options.colorDescription ?? {
        ko: '의미론적 색 역할. 임의 색상값은 받지 않습니다',
        en: 'Semantic colour role. Arbitrary colour values are not accepted'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: options.density ?? "'default'",
      shared: true,
      description: options.densityDescription ?? {
        ko: '여백만 바꿉니다. 높이와 글자 크기는 그대로',
        en: 'Padding only — never the height, never the type scale'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: options.elevation ?? '0',
      shared: true,
      description: options.elevationDescription ?? {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 means no shadow at all'
      }
    }
  ];
}

/**
 * What the three progress indicators share. The same rows, three tables, so a
 * reader on the ProgressBox page does not have to go and look at the bar's.
 */
function progressProps(sizeDescription: Text): PropRow[] {
  return [
    {
      name: 'value',
      type: 'number | null',
      default: 'null',
      description: {
        ko: 'min과 max 사이의 진행도. null(기본값)은 미정 상태입니다 — 값을 듣지 못한 표시기는 빈 막대를 그리는 대신 모른다고 말해야 합니다',
        en: 'How far along, between min and max. null — the default — is indeterminate: an indicator that has not been told a value should say so rather than draw an empty bar'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '범위의 시작', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '범위의 끝', en: 'The top of the range' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: sizeDescription
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇을 기다리는지. 값과 함께 스크린 리더가 읽습니다',
        en: 'A name for what is loading. Read out with the value by a screen reader'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '도형 옆에 값을 글자로 보여 줍니다. format이 없으면 범위에 대한 백분율입니다',
        en: 'Shows the value as text beside the shape. Percentage of the range unless format says otherwise'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 어떻게 쓸지. 없으면 min…max에 대한 백분율 — 설명되지 않은 범위에서 유일하게 성립하는 표기입니다',
        en: 'How to write the value. Without it the value is a percentage of min…max, the only formatting that holds for a range nobody described'
      }
    }
  ];
}

const WEEKDAY = '0 | 1 | 2 | 3 | 4 | 5 | 6';

/**
 * The rows the four pickers share.
 *
 * They are one control in four shapes, and the whole point of writing them once
 * is that a reader who has learned DatePicker's table has learned the other
 * three. Only the defaults and a couple of descriptions genuinely differ, which
 * is what the options are for.
 */
interface PickerOptions {
  /** What the popup closing after a choice means for this one. */
  closeOnSelect: string;
  closeOnSelectDescription: Text;
  /** How the hidden input spells the value. */
  submitted: Text;
  /** Left out by DateRangePicker, which has one placeholder per end. */
  placeholder?: boolean;
}

function pickerProps(options: PickerOptions): PropRow[] {
  return [
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팝업이 열려 있는지. onOpenChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether the popup is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음에 열린 채로 시작', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when the popup opens or closes' }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 월·요일 이름, 헤더의 연/월 버튼 순서, 트리거의 표기를 정합니다. 기본값은 브라우저의 로케일',
        en: "BCP 47 tag deciding the month and weekday names, the order of the header's two buttons, and how the trigger writes the value. Defaults to the browser's"
      }
    },
    {
      name: 'format',
      type: 'Intl.DateTimeFormatOptions',
      description: {
        ko: '트리거가 값을 쓰는 방식. Intl에 그대로 넘어갑니다',
        en: 'How the trigger writes the value. Passed straight to Intl'
      }
    },
    ...(options.placeholder === false
      ? []
      : [
          {
            name: 'placeholder',
            type: 'ReactNode',
            description: {
              ko: '아무것도 고르지 않았을 때 트리거에 보이는 내용',
              en: 'Shown in the trigger while nothing is chosen'
            }
          } satisfies PropRow
        ]),
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 비우는 ×를 트리거에 답니다',
        en: 'Offers the × that empties the control'
      }
    },
    {
      name: 'closeOnSelect',
      type: 'boolean',
      default: options.closeOnSelect,
      description: options.closeOnSelectDescription
    },
    {
      name: 'labels',
      type: 'Partial<PickerLabels>',
      description: {
        ko: '스크린 리더가 듣는 문자열들. 열여덟 개가 한 벌이라 프롭 하나로 받습니다 — 날짜 이름은 여기 없고 Intl이 만듭니다',
        en: 'The strings a screen reader hears. One object rather than eighteen props, because they are a set — the date names are not among them, those come from Intl'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: options.submitted
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    ...fieldProps,
    ...inertProps
  ];
}

/** The three rows every calendar-bearing picker offers, plus its bounds. */
function calendarProps(minMax: Text): PropRow[] {
  return [
    {
      name: 'defaultMonth',
      type: 'Date',
      description: {
        ko: '값이 없을 때 달력이 열리는 달. 기본값은 이번 달',
        en: 'Which month the calendar opens on when there is no value. Defaults to this one'
      }
    },
    { name: 'minDate', type: 'Date | null', description: minMax },
    {
      name: 'maxDate',
      type: 'Date | null',
      description: {
        ko: 'minDate의 반대쪽 끝',
        en: 'The other end of the same span'
      }
    },
    {
      name: 'shouldDisableDate',
      type: '(date: Date) => boolean',
      description: {
        ko: '범위 안이지만 고를 수 없는 날 — 주말, 공휴일, 이미 예약된 방. 셀은 목록에 남은 채 비활성이 됩니다',
        en: 'Blocks individual days inside the range — weekends, holidays, a room already booked. The cell stays in the grid, unavailable'
      }
    },
    {
      name: 'weekStartsOn',
      type: WEEKDAY,
      shared: true,
      description: {
        ko: '주가 시작하는 요일. 일요일이 0입니다. 기본값은 로케일이 말하는 것',
        en: 'Which day the week starts on, Sunday being 0. Defaults to whatever the locale says'
      }
    }
  ];
}

/** And the six the clock offers. */
const clockProps: PropRow[] = [
  {
    name: 'hour12',
    type: 'boolean',
    description: {
      ko: '12시간 다이얼과 오전/오후 열. 기본값은 로케일이 하는 대로',
      en: 'A 12-hour dial with an AM/PM column. Defaults to whatever the locale does'
    }
  },
  {
    name: 'showSeconds',
    type: 'boolean',
    default: 'false',
    description: { ko: '초 열을 추가합니다', en: 'Adds the seconds column' }
  },
  {
    name: 'hourStep',
    type: 'number',
    default: '1',
    description: { ko: '시 열의 간격', en: 'How far apart the rows of the hour column are' }
  },
  {
    name: 'minuteStep',
    type: 'number',
    default: '1',
    description: { ko: '분 열의 간격', en: 'The same, for minutes' }
  },
  {
    name: 'secondStep',
    type: 'number',
    default: '1',
    description: { ko: '초 열의 간격', en: 'The same, for seconds' }
  },
  {
    name: 'shouldDisableTime',
    type: "(value: Date, unit: 'hour' | 'minute' | 'second' | 'meridiem') => boolean",
    description: {
      ko: '개별 행을 막습니다. 열마다 행마다 한 번씩, 그 행이 만들 순간과 어느 열인지를 받습니다',
      en: 'Blocks individual rows. Called once per row per column with the instant that row would produce and the column it is in'
    }
  }
];

/* ---------------------------------------------------------------------------
 * Animation
 * ------------------------------------------------------------------------- */

const ANIMATE_TRIGGER = "'mount' | 'visible' | 'hover' | 'manual'";
const ANIMATE_REPEAT = "number | 'infinite'";
const ANIMATE_MODE = "'in' | 'out'";

/** The `transition` row, on every component that displays rather than acts. */
function transitionProp(example: string): PropRow {
  return {
    name: 'transition',
    type: 'NebaTransition',
    shared: true,
    description: {
      ko: `mount 시 한 번 실행되는 등장 애니메이션 (${example}). 트리거나 반복이 필요하면 Animate* 컴포넌트로 감싸세요`,
      en: `An entrance animation, run once on mount (${example}). Wrap it in an Animate* component for a trigger or a replay`
    }
  };
}

interface AnimateOptions {
  /** Milliseconds, as the component's own default. */
  duration: string;
  repeat?: string;
  /** Left out by the four that write their own motion. */
  mode?: boolean;
}

/**
 * The rows every `Animate*` takes.
 *
 * Written once for the same reason the picker rows are: eleven components share
 * a vocabulary, and a reader who has learned `trigger` on AnimateFade has
 * learned it everywhere. Only the durations and a couple of defaults differ.
 */
function animateProps(options: AnimateOptions): PropRow[] {
  return [
    ...(options.mode === false
      ? []
      : [
          {
            name: 'mode',
            type: ANIMATE_MODE,
            default: "'in'",
            shared: true,
            description: {
              ko: '들어오는지 나가는지. out은 같은 애니메이션을 거꾸로 재생하고 그 자리에서 멈춥니다',
              en: 'Whether the content arrives or leaves. out is the same animation run backwards, and it is held there'
            }
          } satisfies PropRow
        ]),
    {
      name: 'duration',
      type: 'number',
      default: options.duration,
      shared: true,
      description: { ko: '한 번 재생되는 시간(ms)', en: 'How long one run takes, in milliseconds' }
    },
    {
      name: 'delay',
      type: 'number',
      default: '0',
      shared: true,
      description: { ko: '시작 전 대기(ms)', en: 'How long before it starts, in milliseconds' }
    },
    {
      name: 'easing',
      type: 'string',
      description: {
        ko: 'CSS 이징 곡선. 기본값은 라이브러리의 곡선',
        en: 'The easing curve, as CSS writes it. Defaults to the house curve'
      }
    },
    {
      name: 'repeat',
      type: ANIMATE_REPEAT,
      default: options.repeat ?? '1',
      shared: true,
      description: { ko: '반복 횟수', en: 'How many times it runs' }
    },
    {
      name: 'alternate',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: {
        ko: '한 번 걸러 거꾸로 재생합니다. 반복이 처음으로 튀지 않고 되돌아옵니다',
        en: 'Runs every other pass backwards, so a repeat returns instead of jumping'
      }
    },
    {
      name: 'trigger',
      type: ANIMATE_TRIGGER,
      default: "'mount'",
      shared: true,
      description: {
        ko: '무엇이 재생을 시작하는지. visible은 화면에 들어올 때, hover는 포인터가 올라올 때(포커스 포함), manual은 play가 정합니다',
        en: 'What starts it. visible is on scrolling into view, hover is under the pointer (focus counts), manual is whatever play says'
      }
    },
    {
      name: 'play',
      type: 'boolean',
      description: {
        ko: 'trigger가 manual일 때 재생합니다. false → true 될 때마다 처음부터 다시 시작합니다',
        en: 'Runs it when trigger is manual. Each false → true starts it over'
      }
    },
    {
      name: 'once',
      type: 'boolean',
      default: 'true',
      shared: true,
      description: {
        ko: 'trigger가 visible일 때 처음 한 번만 재생할지. 끄면 화면에 들어올 때마다 다시 재생됩니다',
        en: 'With trigger="visible", whether it runs only the first time. Off, it runs again on every return'
      }
    },
    {
      name: 'threshold',
      type: 'number',
      default: '0.2',
      shared: true,
      description: {
        ko: 'trigger가 visible일 때 화면에 얼마나 들어와야 하는지, 0에서 1 사이',
        en: 'With trigger="visible", how much of the element has to be on screen, from 0 to 1'
      }
    },
    {
      name: 'paused',
      type: 'boolean',
      default: 'false',
      shared: true,
      description: { ko: '있는 자리에 붙들어 둡니다', en: 'Holds the animation where it is' }
    }
  ];
}

const CHART_CURVE = "'linear' | 'smooth' | 'step'";
const CHART_MARKERS = "'none' | 'auto' | 'all'";
const CHART_LABELS = "'none' | 'last' | 'extremes' | 'all'";

/**
 * What every chart takes. Written once and spread into five tables, for the
 * reason the component's own props are one interface: `height`, `legend`,
 * `tooltip` and `format` have to mean the same thing on all of them, and two
 * tables that describe them differently is how that stops being true.
 */
function chartBaseProps(options: { height: string; size?: string }): PropRow[] {
  return [
    ...sharedProps({
      variant: "'text'",
      size: options.size ?? "'md'",
      variantDescription: {
        ko: '표면의 무게. 차트는 시트가 아니라 그림이므로 기본값이 text입니다 — Card 안에 넣으면 가장자리가 겹치지 않습니다. 혼자 서는 차트에는 outline을 주세요',
        en: 'Weight of the surface. A chart is a drawing rather than a sheet, so this defaults to text and a chart inside a Card draws no second edge. Use outline for one that stands alone'
      },
      sizeDescription: {
        ko: '축 글자·선 두께·마커 크기, 그리고 height를 주지 않았을 때의 높이',
        en: 'Axis type, line weight, marker size — and the height, when none is given'
      },
      colorDescription: {
        ko: '시트의 색 계열. series의 색은 여기서 오지 않습니다 — 팔레트나 series.color가 정합니다',
        en: "The sheet's colour family. A series' colour does not come from here — the palette or series.color decides that"
      }
    }),
    {
      name: 'height',
      type: 'number | string',
      default: options.height,
      description: {
        ko: '그림의 높이. 축 라벨은 이 안에 그려지므로, 차트에 맞춘 카드는 차트가 들어가는 카드입니다',
        en: 'How tall the drawing is. The axis labels are drawn inside it, so a card sized to the chart is a card the chart fits in'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '차트의 접근 가능한 이름. 그림 대신 읽히고, 아래에 숨겨진 데이터 표의 caption이 됩니다',
        en: "The chart's accessible name. Read out in place of the drawing, and the caption of the hidden data table under it"
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자가 나타나는 모든 곳의 표기 — 축·tooltip·값 라벨·표. 없으면 만 이상은 축약됩니다(12.4K)',
        en: 'How numbers are written everywhere they appear — the axis, the tooltip, the value labels, the table. Without it, past ten thousand they are compacted (12.4K)'
      }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: '차트가 스스로 쓰는 말과 날짜의 언어',
        en: "The language of the chart's own words and dates"
      }
    },
    {
      name: 'legend',
      type: 'boolean | NebaChartLegend',
      default: 'series ≥ 2',
      description: {
        ko: 'series가 둘 이상이면 자동으로 나오고 하나면 나오지 않습니다 — 색 하나짜리 범례는 제목을 반복할 뿐입니다',
        en: 'Shown automatically from two series up and left off below that — a legend with one swatch restates the title'
      }
    },
    {
      name: 'tooltip',
      type: 'boolean | NebaChartTooltip',
      default: 'true',
      description: {
        ko: '포인터가 무엇을 드러낼지. tooltip에만 있는 값은 없습니다 — 모든 값이 숨겨진 표에도 있습니다',
        en: 'What the pointer uncovers. It never carries a value that is not also in the hidden table'
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      description: {
        ko: '그릴 것이 없을 때 대신 그릴 내용',
        en: 'What to draw when there is nothing to draw'
      }
    }
  ];
}

/** The two axes, and the `series` / `categories` pair that feeds them. */
const cartesianDataProps: PropRow[] = [
  {
    name: 'series',
    type: 'NebaChartSeries[]',
    required: true,
    description: {
      ko: '그릴 series. 색은 이 배열에서의 자리로 정해지므로, 범례에서 하나를 숨겨도 나머지 색은 그대로입니다',
      en: "The series. A colour is decided by a series' place in this array, so hiding one from the legend never repaints the survivors"
    }
  },
  {
    name: 'categories',
    type: '(string | number | Date)[]',
    description: {
      ko: 'category 축의 위치 이름. 대신 각 점이 x를 직접 들고 있어도 됩니다',
      en: "The category axis' labels. Points may carry their own x instead"
    }
  },
  {
    name: 'xAxis',
    type: 'NebaChartAxis',
    description: { ko: 'category 축', en: 'The category axis' }
  },
  {
    name: 'yAxis',
    type: 'NebaChartAxis',
    description: { ko: '값 축', en: 'The value axis' }
  }
];

export const propTables: Record<string, PropRow[]> = {
  NebaChartAxis: [
    {
      name: 'hidden',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '축을 그리지 않습니다 — 선도 눈금도 라벨도. 그 자리는 plot에 돌아갑니다',
        en: 'Leaves the axis undrawn — its rule, its ticks and its labels. The band goes back to the plot'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '축이 재는 것의 이름', en: 'A name for what the axis measures' }
    },
    {
      name: 'grid',
      type: 'boolean',
      default: '값 축은 true / true on the value axis',
      description: {
        ko: '이 축이 plot을 가로질러 긋는 격자선. 값 축은 켜져 있고 category 축은 꺼져 있습니다 — 양쪽 다 켜면 모눈종이가 됩니다',
        en: 'The gridlines this axis casts across the plot. On for the value axis and off for the category axis; both is graph paper'
      }
    },
    {
      name: 'min',
      type: 'number',
      description: {
        ko: '축이 시작하는 값. 생략하면 데이터에서 옵니다. BarChart와 AreaChart는 0을 남겨 두고, LineChart는 자릅니다',
        en: 'Where the scale starts. Taken from the data otherwise. A BarChart and an AreaChart keep zero; a LineChart crops'
      }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '축이 끝나는 값', en: 'Where the scale ends' }
    },
    {
      name: 'tickCount',
      type: 'number',
      default: '5',
      description: {
        ko: '눈금의 대략적인 개수. 실제 값은 읽기 좋은 수로 반올림됩니다',
        en: 'Roughly how many ticks. The scale still rounds to clean numbers'
      }
    },
    {
      name: 'tickFormat',
      type: '(value, index) => ReactNode',
      description: {
        ko: '눈금 하나를 어떻게 쓸지. 차트의 format보다 우선합니다',
        en: "How a tick is written, overriding the chart's own format"
      }
    },
    {
      name: 'thickness',
      type: 'number',
      description: {
        ko: '축이 눈금과 이름을 위해 잡아 두는 폭(px). 기본값은 눈금 글자에서 측정합니다 — 대시보드에서 두 차트의 plot을 맞출 때 쓰세요',
        en: 'How much room the axis keeps for its ticks and label, in pixels. Measured from the ticks otherwise; set it to line two charts up on a dashboard'
      }
    }
  ],

  NebaChartLegend: [
    {
      name: 'side',
      type: SIDE,
      default: "'bottom'",
      shared: true,
      description: { ko: 'plot의 어느 쪽에 놓을지', en: 'Which edge of the plot' }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 변에서의 위치', en: 'Where along that edge' }
    },
    {
      name: 'interactive',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '항목을 클릭하면 그 series를 숨기고, hover하면 나머지를 흐립니다',
        en: 'Clicking an entry hides its series; hovering one dims the rest'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이름 옆에 현재 category의 값을 함께 씁니다',
        en: "Draws each series' value at the active category beside its name"
      }
    }
  ],

  NebaChartTooltip: [
    {
      name: 'mode',
      type: "'index' | 'item' | 'none'",
      default: "'index'",
      description: {
        ko: 'index는 포인터가 있는 category의 모든 series를 crosshair와 함께, item은 가리킨 마크 하나만 보여 줍니다',
        en: 'index shows every series at the category under the pointer, with a crosshair; item shows the one mark being pointed at'
      }
    },
    {
      name: 'crosshair',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'index 모드에서 활성 category에 내리긋는 선. 숫자가 어느 열의 것인지를 말합니다',
        en: 'The line dropped through the plot at the active category, in index mode. It is what says which column the numbers belong to'
      }
    },
    {
      name: 'render',
      type: '(context) => ReactNode',
      description: {
        ko: '패널을 직접 그립니다. 없으면 차트가 자기 것을 그립니다',
        en: 'Draws the panel. Without it the chart draws its own'
      }
    }
  ],

  LineChart: [
    ...cartesianDataProps,
    {
      name: 'curve',
      type: CHART_CURVE,
      default: "'linear'",
      description: {
        ko: '점과 점 사이를 잇는 방식. smooth는 monotone cubic이라 양옆 값보다 아래로 내려가지 않고, step은 다음 측정까지 값을 유지합니다',
        en: 'How the line gets from one point to the next. smooth is a monotone cubic, so it never dips below a value both neighbours are above; step holds each value until the next reading'
      }
    },
    {
      name: 'markers',
      type: CHART_MARKERS,
      default: "'auto'",
      description: {
        ko: '점 위의 dot. auto는 점이 열넷 이하일 때만 그립니다. 포인터가 올라간 점에는 설정과 무관하게 항상 그려집니다',
        en: 'Dots on the points. auto draws them up to fourteen points. Whatever this says, the point under the pointer always gets one'
      }
    },
    {
      name: 'gradient',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선을 같은 hue의 옅은 단계에서 시작해 끝에서 원래 색이 되게 합니다 — 최근 쪽이 진해집니다',
        en: 'Fades the line from a paler step of its own hue at the start to the full colour at the end, so the recent end is the loud one'
      }
    },
    {
      name: 'connectNulls',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'null에서 끊지 않고 이어 그립니다. 결측이 수집 과정의 문제일 때만 — 이어진 구간은 차트가 지어낸 숫자입니다',
        en: 'Draws straight through a null instead of breaking at it. Only when the gap is an artefact of collection — a bridged gap is a number the chart made up'
      }
    },
    {
      name: 'valueLabels',
      type: CHART_LABELS,
      default: "'none'",
      description: {
        ko: '선 위에 쓸 값. last는 각 series의 도달점, extremes는 최고와 최저입니다. 모든 점에 숫자를 쓰는 것이 차트를 못 읽게 만드는 가장 확실한 방법이라 기본은 none입니다',
        en: 'Which values are written on the line. last names where each series ended up, extremes marks its own high and low. The default is none: a number beside every point is the most reliable way to make a chart unreadable'
      }
    },
    {
      name: 'stacked',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'series를 쌓습니다. 선 차트에서는 드물고, 쌓을 것이라면 AreaChart가 읽히는 모양입니다',
        en: 'Stacks the series. Rare on a line chart — an AreaChart is the shape that makes stacking legible'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  AreaChart: [
    ...cartesianDataProps,
    {
      name: 'stacked',
      type: "boolean | 'full'",
      default: 'false',
      description: {
        ko: 'true는 밴드를 쌓아 위 가장자리가 합계가 되게 하고, full은 각 category를 100%로 정규화해 크기가 아니라 비중의 차트로 만듭니다',
        en: 'true stacks the bands so the top edge is the total; full normalises every category to 100%, which makes the chart about the mix rather than the size'
      }
    },
    {
      name: 'curve',
      type: CHART_CURVE,
      default: "'linear'",
      description: {
        ko: '밴드 가장자리가 점과 점 사이를 잇는 방식',
        en: 'How the edge of the band gets from one point to the next'
      }
    },
    {
      name: 'markers',
      type: CHART_MARKERS,
      default: "'none'",
      description: {
        ko: '점 위의 dot. 채워진 밴드에는 이미 보이는 가장자리가 있으므로 기본이 none입니다',
        en: 'Dots on the points. none by default — a filled band already has a visible edge'
      }
    },
    {
      name: 'valueLabels',
      type: CHART_LABELS,
      default: "'none'",
      description: { ko: '밴드 위에 쓸 값', en: 'Which values are written on the band' }
    },
    {
      name: 'connectNulls',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'null을 가로질러 이어 그립니다. 선보다 여기서 더 위험합니다 — 채움은 없는 숫자를 더 넓은 면적에 칠합니다',
        en: 'Draws through a null instead of breaking at it. It matters more here than on a line: a fill paints a made-up number over a larger area'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  BarChart: [
    ...cartesianDataProps,
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'vertical'",
      shared: true,
      description: {
        ko: '막대가 자라는 방향. category 이름이 단어라면 horizontal이 정답입니다 — 세로 차트는 이름에 막대 하나만큼의 너비를 줍니다',
        en: 'Which way the bars run. horizontal is right whenever the category names are words: a vertical chart gives each name the width of one bar'
      }
    },
    {
      name: 'stacked',
      type: "boolean | 'full'",
      default: 'false',
      description: {
        ko: '묶인 막대는 "어느 series가 더 큰가"에, 쌓인 막대는 "이 합계가 무엇으로 되어 있나"에 답합니다. full은 비중을 묻습니다',
        en: 'Grouped bars answer "which series is bigger"; stacked bars answer "what is this total made of"; full asks about the mix'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '막대의 값 쪽 끝만 둥글게 깎습니다. 기준선 쪽은 각진 채로 — 둥근 발은 축을 물결치게 만듭니다',
        en: 'Cuts the corners off the data end of each bar. The baseline end stays square; a rounded foot makes the axis look scalloped'
      }
    },
    {
      name: 'barSize',
      type: 'number',
      default: 'size (md는 24px)',
      description: {
        ko: '막대 두께의 상한(px). 상한 아래에서는 밴드의 자기 몫을 채우고, 넘으면 남은 자리는 여백이 됩니다',
        en: 'How thick a bar may get, in pixels. Below the cap bars fill their share of the band; above it the leftover stays as air'
      }
    },
    {
      name: 'valueLabels',
      type: CHART_LABELS,
      default: "'none'",
      description: {
        ko: '막대 위에 쓸 값. 숫자가 붙은 막대 여덟 개는 차트이면서 표지만, 열두 개를 넘으면 둘 다 아니게 됩니다',
        en: 'Which values are written on the bars. Eight bars with their numbers on them is a chart and a table at once; past a dozen it is neither'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  ScatterChart: [
    {
      name: 'series',
      type: 'NebaChartSeries[]',
      required: true,
      description: {
        ko: '그릴 series. 각 점은 x와 y를 모두 숫자로 들고 있어야 하고, z가 있으면 그 점은 dot이 아니라 bubble이 됩니다',
        en: 'The series. Every point carries both an x and a y as numbers, and one that also carries a z is drawn as a bubble rather than a dot'
      }
    },
    {
      name: 'categories',
      type: '(number | Date)[]',
      description: {
        ko: '점이 x를 직접 들고 있지 않을 때 index로 찾아 쓰는 x 값. 문자열은 수직선 위의 자리가 아니므로 받지 않습니다',
        en: 'The x of a point that does not carry its own, found by index. A string is not a place on a number line, so it is not accepted here'
      }
    },
    {
      name: 'xAxis',
      type: 'NebaChartAxis',
      description: {
        ko: 'x 축. 여기서는 category 축이 아니라 두 번째 값 축이므로 눈금은 데이터가 아니라 반올림된 수에 놓이고, 격자선도 기본으로 켜집니다',
        en: 'The x axis. Here it is a second value axis rather than a category axis, so it ticks at rounded numbers rather than at the data — and it casts a grid by default'
      }
    },
    {
      name: 'yAxis',
      type: 'NebaChartAxis',
      description: { ko: '값 축', en: 'The value axis' }
    },
    {
      name: 'shape',
      type: "'auto' | 'varied' | 'circle' | 'square' | 'triangle' | 'diamond' | 'cross'",
      default: "'auto'",
      description: {
        ko: '마크의 모양. auto는 색만으로 구분되는 동안 원을, 네 번째 series부터는 series마다 다른 모양을 씁니다. varied는 항상 모양을 나눕니다 — 인쇄하거나 흑백으로 읽을 차트에',
        en: 'What each mark is drawn as. auto is a circle while colour alone can carry identity and a shape per series from the fourth on; varied always separates them, which is what a chart that will be printed needs'
      }
    },
    {
      name: 'pointRadius',
      type: 'number',
      default: 'size',
      description: {
        ko: 'z가 없는 마크의 반지름(px)',
        en: 'The radius of a mark with no z, in pixels'
      }
    },
    {
      name: 'maxRadius',
      type: 'number',
      default: 'plot 짧은 변의 1/12 / a twelfth of the plot',
      description: {
        ko: '가장 큰 bubble의 반지름(px). 나머지는 반지름이 아니라 넓이로 그 아래에 맞춰집니다 — z를 반지름에 쓰면 두 배인 값이 네 배로 보입니다',
        en: 'The radius of the largest bubble, in pixels. Everything else is scaled under it by area, not by radius: encode z as a radius and a value twice as large draws a mark four times the size'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  HeatmapChart: [
    {
      name: 'series',
      type: 'NebaChartSeries[]',
      required: true,
      description: {
        ko: 'series 하나가 grid의 행 또는 treemap의 그룹입니다. y가 크기, x가 열·타일 이름이고, null은 결측이라 그 셀은 그리지 않습니다',
        en: 'A series is a row of the grid or a group of the treemap. y is the magnitude and x names the column or tile; a null is a gap and its cell is not drawn'
      }
    },
    {
      name: 'categories',
      type: '(string | number | Date)[]',
      description: {
        ko: '열 이름. 각 점이 x를 직접 들고 있어도 됩니다',
        en: 'The column names. Points may carry their own x instead'
      }
    },
    {
      name: 'shape',
      type: "'grid' | 'treemap'",
      default: "'grid'",
      description: {
        ko: 'grid는 category 축 둘과 숫자 하나, treemap은 비중대로 크기를 준 타일로 상자를 채웁니다',
        en: 'grid is a cell per row and column; treemap packs a tile per datum, sized by its share'
      }
    },
    {
      name: 'scale',
      type: "'sequential' | 'diverging'",
      default: "'sequential'",
      description: {
        ko: 'sequential은 한 hue의 옅음→진함, diverging은 중립 회색을 사이에 둔 두 hue입니다. diverging은 기준이 되는 0이 실제로 있을 때만 — 없으면 없는 경계를 만들어 냅니다',
        en: 'sequential is one hue pale to deep; diverging is two hues either side of a neutral grey. Reach for diverging only when there is a real zero to diverge about'
      }
    },
    {
      name: 'midpoint',
      type: 'number',
      default: '0',
      description: {
        ko: 'diverging 스케일이 뒤집히는 지점',
        en: 'Where a diverging scale turns over'
      }
    },
    {
      name: 'min',
      type: 'number',
      description: {
        ko: '스케일이 시작하는 값. 생략하면 데이터에서 옵니다 — 두 차트를 비교하려면 같은 범위를 주어야 합니다',
        en: 'Where the scale starts. Taken from the data otherwise, so two charts are not comparable until they are given the same bounds'
      }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '스케일이 끝나는 값', en: 'Where the scale ends' }
    },
    {
      name: 'valueLabels',
      type: "'none' | 'all'",
      default: "'none'",
      description: {
        ko: '각 셀 위에 값을 씁니다. 들어갈 자리가 없는 라벨은 잘리는 대신 생략되고, 잉크는 셀의 단계에 따라 정해집니다',
        en: 'Writes each value on its cell. A label that does not fit is dropped rather than clipped, and its ink is picked from the step underneath it'
      }
    },
    {
      name: 'legend',
      type: 'boolean | { side, align }',
      default: 'true',
      description: {
        ko: '양 끝에 값이 붙은 스케일 막대. swatch 목록이 아닙니다 — 여기에는 이름을 가진 것이 없고 순서가 곧 의미입니다',
        en: 'A scale bar with its ends labelled, not a list of swatches: nothing here has a name and the order is the meaning'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  NebaTimelinePoint: [
    {
      name: 'start',
      type: 'Date | number',
      required: true,
      description: { ko: '이 span이 시작하는 시각', en: 'When the span begins' }
    },
    {
      name: 'end',
      type: 'Date | number',
      required: true,
      description: {
        ko: '끝나는 시각. 앞뒤가 바뀌어 있어도 제대로 그립니다',
        en: 'And when it is done. A span written back to front is drawn the right way round'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: 'tooltip과 표에서 이 span을 부르는 이름',
        en: 'What the span is called, in the tooltip and the table'
      }
    },
    {
      name: 'color',
      type: 'NebaColor | string',
      description: {
        ko: '이 span 하나만 행의 색 대신 이 색으로',
        en: "Overrides its row's colour for this one span"
      }
    }
  ],

  TimelineChart: [
    {
      name: 'series',
      type: 'NebaTimelineSeries[]',
      required: true,
      description: {
        ko: 'series 하나가 행 하나이고, 그 안의 datum이 span입니다. 행 이름이 왼쪽 축에 쓰입니다',
        en: "One row per series, and a span per datum. A row's name is what the axis says down the left"
      }
    },
    {
      name: 'min',
      type: 'Date | number',
      description: {
        ko: '시간 축이 시작하는 지점. 생략하면 span에서 오고, 달력이 이름을 가진 날짜로 바깥쪽으로 반올림됩니다',
        en: 'Where the time axis starts. Taken from the spans otherwise, and rounded outward to a date a calendar has a name for'
      }
    },
    {
      name: 'max',
      type: 'Date | number',
      description: { ko: '시간 축이 끝나는 지점', en: 'Where the time axis ends' }
    },
    {
      name: 'xAxis',
      type: 'NebaChartAxis',
      description: {
        ko: '행 축. 방향과 무관하게 xAxis가 category 축입니다',
        en: 'The row axis. xAxis is the category axis whichever way a chart runs'
      }
    },
    {
      name: 'yAxis',
      type: 'NebaChartAxis',
      description: {
        ko: '시간 축. 여기서는 아래쪽에 그려지지만 여전히 값 축이므로 yAxis입니다',
        en: 'The time axis. It is drawn along the bottom here and it is still the value axis, so it is yAxis'
      }
    },
    {
      name: 'barSize',
      type: 'number',
      default: 'size',
      description: {
        ko: '막대가 두꺼워질 수 있는 최대 두께(px). 그 아래에서는 행의 몫을 채우고, 넘는 만큼은 여백으로 남습니다',
        en: 'How thick a bar may get, in pixels. Below the cap the bars fill their share of the row; above it the leftover stays as air'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'span의 양쪽 끝을 둥글게. BarChart와 달리 양쪽 다입니다 — span은 0에서 자라지 않으므로 기준이 되는 끝이 없습니다',
        en: 'Cuts the corners off a span. Both ends, unlike a BarChart: a span grows from nothing, so neither end is a baseline'
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  PieChart: [
    {
      name: 'data',
      type: 'NebaChartDatum[]',
      required: true,
      description: {
        ko: '조각들. pie는 series가 하나이므로 series 배열이 아니라 값의 배열을 받습니다 — 여기서 정체성을 갖는 것은 조각입니다',
        en: 'The slices. A pie has one series, so it takes the values directly: the slices are the entities here'
      }
    },
    {
      name: 'categories',
      type: '(string | number | Date)[]',
      description: {
        ko: '조각의 이름. 대신 각 점이 x를 직접 들고 있어도 됩니다',
        en: 'What each slice is called. Points may carry their own x instead'
      }
    },
    {
      name: 'shape',
      type: "'pie' | 'donut' | 'semi'",
      default: "'pie'",
      description: {
        ko: 'pie는 꽉 찬 원, donut은 가운데를 비운 고리, semi는 상자 아래쪽에서 그리는 반원입니다',
        en: 'pie is a filled disc, donut opens a hole for the total, semi draws half a ring from the bottom of the box'
      }
    },
    {
      name: 'startAngle',
      type: 'number',
      default: '0',
      description: {
        ko: '첫 조각이 시작하는 각도 — 12시 방향에서 시계 방향으로. semi는 무시합니다',
        en: 'Where the first slice starts, in degrees clockwise from twelve o’clock. Ignored by semi'
      }
    },
    {
      name: 'center',
      type: 'ReactNode',
      description: {
        ko: '고리 가운데에 들어가는 것. 가운데가 빈 donut은 한 입 베어 문 pie일 뿐입니다',
        en: 'What goes in the hole. A ring with nothing in the middle is a pie with a bite out of it'
      }
    },
    {
      name: 'valueLabels',
      type: "'none' | 'all'",
      default: "'none'",
      description: {
        ko: '각 조각에 그 비중을 씁니다. 글자가 양옆 여유까지 들어갈 만큼 넓은 조각에만 그려지고, 들어가지 않으면 잘리는 대신 그려지지 않습니다',
        en: "Writes each slice's share on it, only where the text fits with room on both sides. One that does not fit is dropped rather than clipped"
      }
    },
    ...chartBaseProps({ height: 'size' })
  ],

  Sparkline: [
    {
      name: 'data',
      type: 'NebaChartDatum[]',
      required: true,
      description: {
        ko: '값들. 다른 차트와 마찬가지로 null은 결측입니다',
        en: 'The values. null is a gap, exactly as it is on every other chart'
      }
    },
    {
      name: 'shape',
      type: "'line' | 'area' | 'bar'",
      default: "'line'",
      description: {
        ko: '어떤 마크로 그릴지. 추세에는 선, 양에는 area, 세는 것에는 막대',
        en: 'Which mark. A line for a trend, an area for a quantity, bars for a count of discrete things'
      }
    },
    {
      name: 'curve',
      type: CHART_CURVE,
      default: "'linear'",
      description: { ko: '점과 점 사이를 잇는 방식', en: 'How it gets from one point to the next' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '띠의 높이. 페이지가 아니라 옆에 놓인 한 줄의 글자를 기준으로 만든 사다리입니다',
        en: 'The height of the strip, on a ladder measured against the line of text beside it rather than against the page'
      }
    },
    {
      name: 'color',
      type: `${COLOR} | string`,
      default: '첫 번째 chart slot / the first chart slot',
      description: {
        ko: '마크의 색. 전체 차트와 달리 색을 직접 받습니다 — series가 하나이고 팔레트가 나눠 줄 범례도 없기 때문입니다',
        en: "The mark's colour, taken directly unlike the full charts: a sparkline has one series and no legend for a palette to hand out"
      }
    },
    {
      name: 'endDot',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마지막 점에 dot을 찍습니다. 이만한 크기가 담을 수 있는 유일한 직접 라벨입니다',
        en: 'Puts a dot on the last point — the one direct label a strip this small has room for'
      }
    },
    {
      name: 'baseline',
      type: 'number',
      description: {
        ko: '이 값의 자리에 가로선을 긋습니다 — 목표, 예산, 작년 평균',
        en: "Draws a rule across the strip at this value — a target, a budget, last year's average"
      }
    },
    {
      name: 'min',
      type: 'number',
      description: {
        ko: '축의 아래 끝. 생략하면 자기 데이터로 띠를 가득 채웁니다 — 나란히 놓인 둘을 비교하려면 같은 값을 주어야 합니다',
        en: 'The bottom of the scale. Left out, the strip fills itself with its own range — two side by side are only comparable if both are given the same one'
      }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '축의 위 끝', en: 'The top of the scale' }
    },
    {
      name: 'width',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: '너비. 기본은 컨테이너를 채웁니다',
        en: 'How wide. Fills its container by default'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '띠의 이름. 주면 값들이 보조 기술에 노출되고, 주지 않으면 완전히 감춰집니다',
        en: 'A name for the strip. With one, the values are exposed to assistive technology; without one it is hidden entirely'
      }
    }
  ],

  Button: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. xs 22px · sm 26px · md 32px · lg 40px · xl 48px',
        en: 'Height and type scale. xs 22px · sm 26px · md 32px · lg 40px · xl 48px'
      },
      elevationDescription: {
        ko: '그림자 깊이. 0은 그림자 없음. 호버는 한 단계 올리고, 누르면 한 단계 내립니다',
        en: 'Drop shadow depth. 0 is flat; hover adds a level and pressing removes one'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용. 1.2em으로 그려져 라벨 크기를 따라갑니다',
        en: 'Content before the label. Sized in em, so it tracks the label'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤에 놓이는 내용', en: 'Content after the label' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'startIcon 자리에 스피너를 띄우고 활성화를 막습니다. 포커스는 유지됩니다',
        en: 'Spinner in place of startIcon; stops activation but keeps focus'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비활성이되 흐려지지 않음. 액션은 존재하지만 여기서는 쓸 수 없다는 뜻',
        en: 'Inert but not dimmed — the action exists, it just is not available here'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 되며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Drops the colour family for neutral grey and leaves the tab order'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'button 대신 다른 요소로 렌더링합니다 (<a href>, 라우터의 Link). 링크는 링크로 남아 크롤러와 스크린리더가 그대로 인식합니다',
        en: 'Renders something other than a button (an <a href>, a router Link). A link stays a link, so crawlers and screen readers still see one'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '라벨. 생략하면 정사각형 아이콘 버튼이 됩니다',
        en: 'The label. Omit it and the button goes square for an icon'
      }
    }
  ],

  TextField: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. Button과 같은 높이라서 한 줄에 섞어 놓아도 기준선이 맞습니다',
        en: "Height and type scale. The same heights as Button, so a row's baseline holds"
      },
      variantDescription: {
        ko: '표면의 무게. solid도 색으로 채우지 않습니다 — 필드가 담는 것은 사용자 데이터입니다',
        en: 'Weight of the surface. Even solid is not flooded with colour — a field holds user data'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리와 포커스 링, 캐럿에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the focus ring and the caret'
      },
      elevationDescription: {
        ko: '그림자 깊이. 필드는 떠 있는 표면이 아니므로 거의 올리지 않습니다',
        en: 'Drop shadow depth. A field is a well, not a surface that floats — rarely raised'
      }
    }),
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 위 라벨. Base UI Field로 연결됩니다',
        en: "Label above the control, wired to it by Base UI's Field"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '컨트롤 아래 보조 설명', en: 'Helper text below the control' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 아래 오류 메시지. 값이 있으면 invalid 상태도 함께 켜집니다',
        en: 'Error message below the control. Its presence also turns the field invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      default: '!!error',
      description: {
        ko: '메시지 없이 invalid만 켭니다. 외부 폼 라이브러리가 유효성을 가질 때',
        en: 'Forces the invalid state without a message, for when a form library owns validity'
      }
    },
    {
      name: 'multiline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'input 대신 textarea로 렌더링합니다. 나머지 축은 그대로',
        en: 'Renders a textarea instead of an input. Every other axis stays identical'
      }
    },
    {
      name: 'rows',
      type: 'number',
      default: '3',
      description: { ko: 'multiline일 때 보이는 줄 수', en: 'Visible rows in multiline mode' }
    },
    {
      name: 'resize',
      type: "'none' | 'vertical' | 'horizontal' | 'both'",
      default: "'vertical'",
      description: {
        ko: '사용자가 끌어서 크기를 바꿀 수 있는 방향. 가로는 폼의 열을 깨뜨립니다',
        en: "Which way the user may drag it. Horizontal breaks a form's column"
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '컨트롤 앞에 놓이는 내용', en: 'Content before the control' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '컨트롤 뒤에 놓이는 내용', en: 'Content after the control' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'endIcon 자리에 스피너를 띄웁니다. 입력은 계속 가능합니다',
        en: 'Spinner in place of endIcon. Typing is deliberately still allowed'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '읽기 전용. 선택과 복사는 됩니다',
        en: 'Read-only. Selecting and copying still work'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    }
  ],

  Box: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 시트는 염색되지 않으며, solid와 outline은 불투명도와 하이라인으로 갈립니다',
        en: 'Weight of the surface. The sheet is never dyed — solid and outline differ in opacity and hairline'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 하이라인에만 나타납니다 (solid에는 테두리가 없어 보이지 않습니다)',
        en: 'Semantic colour role. The surface is white, so it reaches the hairline only — invisible on solid, which has no border'
      },
      sizeDescription: {
        ko: '모서리 반경과 안쪽 여백. 높이도 글자 크기도 건드리지 않습니다',
        en: 'Corner radius and padding. Never a height, never the type scale'
      },
      elevationDescription: {
        ko: '그림자 깊이. variant가 text면 무시됩니다',
        en: 'Drop shadow depth. Ignored when variant is text'
      }
    }),
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 여백. 이미지·표처럼 가장자리까지 채우는 콘텐츠는 끄세요',
        en: 'Inner padding. Turn it off for full-bleed content — an image, a table'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div 대신 다른 요소로 렌더링합니다. Base UI의 render prop 그대로',
        en: "Renders something other than a div. Base UI's own escape hatch"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '박스에 담기는 내용', en: 'What the box holds' }
    },
    transitionProp('transition="fade"')
  ],

  PageLayout: [
    {
      name: 'header',
      type: 'ReactNode',
      description: {
        ko: '맨 위 바. 보통 Header',
        en: 'The bar across the top. A Header, usually'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '맨 아래 시트. 보통 Footer',
        en: 'The sheet at the end. A Footer, usually'
      }
    },
    {
      name: 'sidebar',
      type: 'ReactNode',
      description: {
        ko: '앞쪽 열. 여기에 넣은 Sidebar는 자기가 어느 쪽인지 이미 알고 있으므로 side를 다시 쓸 필요가 없습니다',
        en: 'The leading column. A Sidebar handed to this slot already knows which end it is on and needs no side of its own'
      }
    },
    {
      name: 'endSidebar',
      type: 'ReactNode',
      description: {
        ko: '뒤쪽 열. 한쪽엔 탐색, 반대쪽엔 목차·인스펙터·필터를 두는 레이아웃용',
        en: 'The trailing column, for navigation down one side and a table of contents, an inspector or a filter panel down the other'
      }
    },
    {
      name: 'headerSpan',
      type: "'full' | 'content'",
      default: "'full'",
      description: {
        ko: 'header와 sidebar 중 어느 쪽이 위쪽 모서리를 차지하는지. full은 헤더가 전체 너비를 가로지르고 사이드바가 그 아래에서 시작하는 웹사이트 배치, content는 사이드바가 창 높이를 다 쓰고 헤더가 그 사이에 놓이는 애플리케이션 배치',
        en: 'Which of the header and the sidebars takes the top corner. full spans the whole width with the sidebars beginning underneath it — a website; content runs the sidebars the full height with the header between them — an application'
      }
    },
    {
      name: 'footerSpan',
      type: "'full' | 'content'",
      default: "'full'",
      description: {
        ko: 'footer에 대한 같은 질문. 따로 답할 수 있는 이유는, 전체 높이 레일을 쓰는 대시보드도 저작권 줄은 대개 레일 아래가 아니라 콘텐츠 아래에 두기 때문',
        en: 'The same question for the footer, and worth answering separately: a dashboard with a full-height rail still usually wants its copyright line under the content rather than under the rail'
      }
    },
    {
      name: 'scroll',
      type: "'page' | 'content'",
      default: "'page'",
      description: {
        ko: '무엇이 스크롤되는지. page는 문서 자체가 스크롤되고 헤더는 sticky로 자리를 지킵니다. content는 레이아웃이 창 높이에 고정되고 header와 footer 사이만 스크롤됩니다',
        en: 'What scrolls. page scrolls the document and the header holds its place with sticky; content pins the layout to the window and scrolls only the region between the bars'
      }
    },
    {
      name: 'height',
      type: "'viewport' | 'auto' | number | string",
      default: "'viewport'",
      description: {
        ko: '레이아웃의 높이. viewport는 창 높이, auto는 부모 높이(Mockup 화면 안의 앱 셸이나 미리보기용), 길이를 주면 그 값. 숫자는 픽셀',
        en: "How tall the layout is. viewport is the window's, auto is its parent's — an app shell inside a Mockup's screen, a preview — and a length is exactly that. Numbers are pixels"
      }
    },
    {
      name: 'collapseBelow',
      type: `${BREAKPOINT} | 'none'`,
      default: "'md'",
      description: {
        ko: '이 너비보다 좁아지면 사이드바가 열이 아니라 drawer가 되고, SidebarTrigger가 그것을 여는 버튼이 됩니다. none이면 어느 너비에서도 열로 남습니다',
        en: 'The width below which the sidebars stop being columns and become drawers, with a SidebarTrigger as the way to open them. none keeps them as columns at every width'
      }
    },
    {
      name: 'sidebarOpen',
      type: 'boolean',
      description: {
        ko: '앞쪽 사이드바의 drawer가 열려 있는지. onSidebarOpenChange와 함께 쓰면 controlled',
        en: "Whether the leading sidebar's drawer is open. Use with onSidebarOpenChange for a controlled layout"
      }
    },
    {
      name: 'defaultSidebarOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음 상태', en: 'Which state it starts in' }
    },
    {
      name: 'onSidebarOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리고 닫힐 때', en: 'Fires as it opens and closes' }
    },
    {
      name: 'endSidebarOpen',
      type: 'boolean',
      description: {
        ko: '뒤쪽 사이드바에 대한 같은 세 가지',
        en: 'The same three for the trailing sidebar'
      }
    },
    {
      name: 'defaultEndSidebarOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음 상태', en: 'Which state it starts in' }
    },
    {
      name: 'onEndSidebarOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리고 닫힐 때', en: 'Fires as it opens and closes' }
    },
    {
      name: 'skipLink',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '문서 맨 앞에 “본문으로 건너뛰기” 링크를 둡니다. focus를 받을 때만 그려지므로 눈으로 보는 독자에게는 비용이 없습니다',
        en: 'Puts a "Skip to content" link first in the document, drawn only while it holds the focus — so it costs a sighted reader nothing'
      }
    },
    {
      name: 'skipLabel',
      type: 'string',
      description: {
        ko: '그 링크의 문구. 기본값은 locale의 표현',
        en: "What that link says. Defaults to the locale's word for it"
      }
    },
    {
      name: 'mainId',
      type: 'string',
      default: "'main'",
      description: {
        ko: 'skip link가 향하는 id. main에 붙습니다',
        en: 'The id the skip link jumps to, put on the main'
      }
    },
    {
      name: 'mainProps',
      type: "Omit<ComponentPropsWithoutRef<'main'>, 'id' | 'children'>",
      description: {
        ko: 'main에 더 넘길 것들 — className, aria-label',
        en: 'Anything else the main needs — a className, an aria-label'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '레이아웃이 쓰는 단어의 언어. 안쪽 Sidebar와 SidebarTrigger가 물려받으므로 페이지당 한 번만 씁니다',
        en: "The language the layout's own words are in. Inherited by every Sidebar and SidebarTrigger inside it, so it is written once per page"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'skip link와 focus 링이 띠는 색 계열. 레이아웃 자체는 아무 면도 그리지 않습니다',
        en: 'The colour family the skip link and the focus rings light up in. The layout itself draws no surface'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '페이지. main 안에 그려집니다', en: 'The page. Rendered inside the main' }
    }
  ],

  Header: [
    {
      name: 'brand',
      type: 'ReactNode',
      description: {
        ko: '앞쪽 자리 — 로고, 제품 이름, 모든 페이지에서 같은 것. 보통 AppLogo',
        en: "The leading slot: the logo, the product's name, the thing that is the same on every page. An AppLogo, usually"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '가운데 자리 — 대개 탐색', en: 'The middle slot, usually the navigation' }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '뒤쪽 자리 — 계정 메뉴, 테마 전환, 주요 행동. 끝에 붙여 배치되므로 버튼 여러 개를 감쌀 필요가 없습니다',
        en: 'The trailing slot: the account menu, the theme switch, the call to action. Laid out end-aligned, so a row of buttons needs no wrapper'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '가운데 자리가 어디에 놓이는지. center는 남는 공간이 아니라 바 자체의 중심선에 놓습니다 — 그러려고 양끝에 같은 몫을 줍니다',
        en: "Where the middle slot sits. center puts it on the bar's own midline rather than in the space left over, which is what giving both ends an equal share is for"
      }
    },
    {
      name: 'position',
      type: POSITION,
      default: "'sticky'",
      shared: true,
      description: {
        ko: '스크롤 속에서 바가 놓이는 방식. sticky는 흐름 안에 남은 채 창 위에 붙고, fixed는 흐름에서 빠져나갑니다(PageLayout이 그 높이를 대신 비워 둡니다)',
        en: "How the bar sits in the page's scroll. sticky stays in the flow while holding the top of the window; fixed leaves the flow, and a PageLayout reserves its height"
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '면의 무게. 바는 색으로 물들지 않습니다 — 위에 놓이는 것들이 자기 색을 갖고 오기 때문',
        en: 'Weight of the sheet. The bar is never dyed, because what is on it arrives with colours of its own'
      },
      sizeDescription: {
        ko: '바의 최소 높이와 거터. Box에서처럼 시트의 크기이며 타입 스케일은 건드리지 않습니다',
        en: "The bar's height floor and gutter. As on Box this is the size of the sheet and never touches the type scale"
      }
    }),
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '아래 가장자리의 헤어라인. 스크롤되는 내용이 계속 지나가는 바이므로 기본으로 켜져 있습니다',
        en: 'A hairline along the bottom edge. On by default: a bar pinned over a scrolling page has content passing underneath it at every moment'
      }
    },
    {
      name: 'maxWidth',
      type: `${SIZE} | 'none'`,
      default: "'none'",
      description: {
        ko: '시트는 창을 가로지른 채, 안쪽 줄만 이 폭으로 묶어 가운데 놓습니다. Container와 같은 사다리',
        en: 'Holds the row of slots to a measure and centres it while the sheet still spans the window. The same ladder Container uses'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '양쪽 거터', en: 'The gutter down each side of the row' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '랜드마크의 이름. 한 페이지에 header가 둘 이상일 때 써 둘 만합니다',
        en: 'The name the landmark is announced by. Worth writing when a page has more than one header in it'
      }
    },
    renderProp('render={<div />}')
  ],

  Footer: [
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '안에 들어가는 모든 것. 링크 열, 저작권 줄, 로고 — 컴포넌트가 짐작할 수 없는 것들이라 자리를 나누지 않습니다',
        en: 'Everything in it — columns of links, a copyright line, a logo. None of it something a component could guess at, which is why this one has slots for nothing'
      }
    },
    {
      name: 'position',
      type: POSITION,
      default: "'static'",
      shared: true,
      description: {
        ko: 'Header와 반대되는 기본값. 푸터는 스크롤해서 닿는 문서의 끝입니다. sticky와 fixed는 손에 닿아 있어야 하는 바용',
        en: "The opposite default from Header's: a footer is the thing at the end of the document, reached by scrolling to it. sticky and fixed are for the bar that has to stay in reach"
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '면의 무게. 바는 색으로 물들지 않습니다',
        en: 'Weight of the sheet. The bar is never dyed'
      },
      sizeDescription: {
        ko: '거터와 위아래 여백. Box에서처럼 시트의 크기입니다',
        en: 'The gutter and the air above and below. As on Box this is the size of the sheet'
      }
    }),
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '위 가장자리의 헤어라인. 위에는 내용이 있고 아래에는 아무것도 없는 유일한 시트이므로, 이 선이 문서가 끝났다고 말하는 전부입니다',
        en: 'A hairline along the top edge. A footer is the one sheet with content directly above it and nothing below, so the line is the whole of what says the document ended'
      }
    },
    {
      name: 'maxWidth',
      type: `${SIZE} | 'none'`,
      default: "'none'",
      description: {
        ko: '시트는 창을 가로지른 채, 안쪽 내용만 이 폭으로 묶어 가운데 놓습니다',
        en: 'Holds the content to a measure and centres it while the sheet still spans the window'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '거터와 위아래 여백', en: 'The gutter and the air above and below' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '랜드마크의 이름. 한 페이지에 footer가 둘 이상일 때',
        en: 'The name the landmark is announced by. Worth writing when a page has more than one footer in it'
      }
    },
    renderProp('render={<div />}')
  ],

  Sidebar: [
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '안에 들어가는 것 — 탐색, 필터 패널, 목차',
        en: 'Everything in it: a nav, a filter panel, a table of contents'
      }
    },
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '어느 끝을 차지하는지. 물리적이 아니라 논리적이라 RTL에서 뒤집힙니다. PageLayout 안에서는 어느 자리에 넘겼는지로 이미 정해집니다',
        en: 'Which end of the band it takes. Logical rather than physical, so it flips under RTL. Inside a PageLayout this is already decided by which slot it was handed to'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      default: 'size',
      description: {
        ko: '열의 너비. 숫자는 픽셀. resizable일 때는 시작 너비이며, 드래그가 이 값을 덮어씁니다',
        en: 'How wide the column is. Numbers are pixels. With resizable it is only the width the sidebar starts at — dragging writes over it'
      }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '안쪽 가장자리를 끌어 너비를 바꿀 수 있게 합니다. 키보드에서는 좌우 화살표',
        en: "Lets the reader drag the inner edge to change the column's width. Arrow keys do the same from the keyboard"
      }
    },
    {
      name: 'minWidth',
      type: 'number | string',
      default: '160',
      description: { ko: '드래그로 좁힐 수 있는 한계', en: 'How narrow it may be dragged' }
    },
    {
      name: 'maxWidth',
      type: 'number | string',
      default: '480',
      description: { ko: '넓힐 수 있는 한계', en: 'And how wide' }
    },
    {
      name: 'onResize',
      type: '(width: number) => void',
      description: {
        ko: '끄는 동안 매 걸음, 픽셀 단위로',
        en: 'Fires with the width in pixels while the edge is being dragged'
      }
    },
    {
      name: 'onResizeEnd',
      type: '(width: number) => void',
      description: {
        ko: '놓을 때 한 번. 너비를 저장해 둘 자리',
        en: 'Fires once, with the same number, when it is let go'
      }
    },
    {
      name: 'collapseBelow',
      type: `${BREAKPOINT} | 'none'`,
      default: 'PageLayout',
      description: {
        ko: '이 너비보다 좁아지면 열이 아니라 drawer가 됩니다. PageLayout의 값을 물려받고, 밖에서는 none — 되돌릴 방법이 없는 채로 접히면 독자가 사이드바를 잃기 때문',
        en: "The width below which it stops being a column and becomes a drawer. Defaults to the PageLayout's own, and to none outside one: a sidebar that collapsed with nothing able to bring it back is a sidebar the reader has lost"
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: 'drawer가 열려 있는지. 접힌 뒤에만 의미가 있습니다. PageLayout 안에서는 레이아웃이 이 상태를 가지므로 거기서 다루세요',
        en: 'Whether the drawer is open — only meaningful once it has collapsed. Inside a PageLayout the layout owns this, so control it there'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '레이아웃 밖에서 쓸 때의 처음 상태',
        en: 'Which state it starts in, for an uncontrolled standalone sidebar'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: '열리고 닫힐 때. 어느 쪽이 상태를 갖든 항상 호출됩니다',
        en: 'Fires as it opens and closes, whichever of the two owns the state'
      }
    },
    {
      name: 'sticky',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '페이지가 지나가는 동안 자리를 지키는지. 헤더 아래에서 시작해 남은 창 높이만큼인 sticky 열이 됩니다',
        en: 'Whether the column holds its place while the page scrolls past it — a sticky column as tall as what is left of the window under the header'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: 'drawer일 때만 그려지는 제목. 열에는 주위의 페이지가 그것이 무엇인지 말해 주지만, 페이지를 덮은 패널에는 없습니다',
        en: 'The heading, drawn only while the sidebar is a drawer. A column has the page around it to say what it is; a panel that has covered the page does not'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '면의 무게. 패널은 색으로 물들지 않습니다',
        en: 'Weight of the sheet. The panel is never dyed'
      },
      sizeDescription: {
        ko: '기본 너비와 안쪽 여백',
        en: "The panel's default width and the air around its content"
      }
    }),
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '내용을 마주보는 안쪽 가장자리의 헤어라인. 바깥쪽은 창에 닿아 있어 나눌 것이 없습니다',
        en: 'A hairline down the inner edge, the one facing the content. The outer edge is against the window, where there is nothing to be separated from'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: { ko: '안쪽 여백', en: 'The gutter and the air above and below the content' }
    },
    {
      name: 'label',
      type: 'string',
      default: "locale('Sidebar')",
      description: {
        ko: '영역의 이름. 사이드바가 둘인 페이지는 반드시 써야 합니다 — 아니면 스크린 리더가 “complementary”라는 영역 두 개를 내놓습니다',
        en: 'The name the region is announced by. A page with two sidebars must have one, or a screen reader offers two regions called "complementary"'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: 'PageLayout',
      description: {
        ko: '사이드바가 쓰는 단어의 언어. PageLayout 안에서는 물려받습니다',
        en: "Which language the sidebar's own words are in. Inherited from the PageLayout when there is one"
      }
    }
  ],

  SidebarTrigger: [
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '레이아웃의 두 사이드바 중 어느 쪽을 여는지',
        en: "Which of the layout's two sidebars it opens"
      }
    },
    {
      name: 'collapseBelow',
      type: `${BREAKPOINT} | 'none'`,
      default: 'PageLayout',
      description: {
        ko: '버튼이 나타나는 너비. 사이드바가 접히는 그 너비이며, PageLayout에서 정하는 것이 맞습니다',
        en: 'The width below which the button appears — the same one the sidebar collapses at. Inherited from the PageLayout, which is where it should be set'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      default: '햄버거',
      description: {
        ko: '글리프. 기본은 세 줄',
        en: 'The glyph. Three lines, unless something else is given'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "locale('Open sidebar')",
      description: {
        ko: '하는 일을 말로. 기본값은 열림 상태에 따라 “사이드바 열기”와 “사이드바 닫기”',
        en: 'What it does, in words. Defaults to the locale\'s "Open sidebar" and "Close sidebar", whichever is true'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: 'PageLayout',
      description: { ko: '그 단어의 언어', en: 'Which language that word is in' }
    }
  ],

  AppLogo: [
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '마크를 마크업으로. 대개 인라인 svg이며, src보다 우선합니다 — 문서의 일부가 된 마크는 페이지의 색을 따르고, 요청이 하나 줄고, 늦게 도착할 수 없습니다',
        en: "The artwork as markup — an inline svg, usually. It beats src: a mark that is part of the document takes the page's own colours, needs no second request, and cannot arrive late"
      }
    },
    {
      name: 'src',
      type: 'string',
      description: {
        ko: '마크를 이미지로. 로고 파일에는 제품 이름이 들어 있는 경우가 많은데, shape의 기본값이 bare인 이유이자 name을 옆에 또 그리지 않고 읽어 주기만 하는 이유입니다',
        en: 'The artwork as an image. A logo file very often has the product\'s name set into it, which is what shape="bare" is the default for and why name is read out rather than drawn a second time'
      }
    },
    {
      name: 'srcSet',
      type: 'string',
      description: {
        ko: '다른 해상도의 후보들. img에서와 같습니다',
        en: 'Candidate images at other resolutions, as on any img'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '제품 이름. 한 prop이 세 가지 일을 합니다 — 마크의 이름이 되고, 마크가 아예 없으면 로고타이프로 그려지고, 타일에서는 이니셜의 출처가 됩니다',
        en: "The product's name. One prop doing three jobs: it names the artwork, it is drawn as the logotype when there is no artwork at all, and its initials are what a tile falls back to"
      }
    },
    {
      name: 'alt',
      type: 'string',
      default: 'name',
      description: {
        ko: '볼 수 없는 독자에게 마크가 말하는 것. 로고는 제품을 뜻하므로 대개 name이 정답입니다',
        en: 'What the artwork says for a reader who cannot see it. Almost always name, since a logo means the product'
      }
    },
    {
      name: 'initials',
      type: 'string',
      default: 'name에서 유도',
      description: { ko: '타일 위 글자를 직접 씁니다', en: 'The letters on a tile, written out' }
    },
    {
      name: 'showName',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마크 옆에 이름을 그립니다. 그린 순간부터 그 글자가 접근성 이름이 되므로 이름이 두 번 읽히지 않습니다',
        en: 'Draws the name beside the artwork. What is drawn *is* the accessible name from then on, so the name stops being read out twice'
      }
    },
    {
      name: 'shape',
      type: "'bare' | 'app' | 'circle'",
      default: "'bare'",
      description: {
        ko: '마크를 두르는 방식. bare는 준 그대로(배경도 자르기도 여백도 없음), app은 모서리를 깎은 채워진 타일 안에 넣은 앱 아이콘, circle은 같은 타일을 둥글게',
        en: 'How the artwork is framed. bare draws it as it was given — no plate, no crop, no padding; app is an app icon, a filled tile with the artwork inset and the corners cut off; circle is the same tile, round'
      }
    },
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      elevation: '0',
      variantDescription: {
        ko: '마크 뒤 타일의 무게. bare에서는 타일이 없으므로 아무 일도 하지 않습니다',
        en: 'Weight of the tile behind the artwork. Nothing at all on bare, which draws no tile'
      },
      sizeDescription: {
        ko: '마크의 높이 — 컨트롤 높이 사다리라, 헤더에서 로고와 옆의 버튼이 같은 높이가 됩니다. bare는 높이만 정하고 너비는 마크의 비율대로',
        en: "How tall the mark is — the control heights, so a logo and the button beside it in a header are the same height. On bare only the height is set and the width follows the artwork's own proportions"
      }
    }),
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '앱 아이콘의 글리프처럼 마크를 타일 가장자리에서 안쪽으로 들입니다. 타일을 꽉 채우도록 그린 마크(파비콘, 사진)면 끕니다',
        en: "Insets the artwork from the tile's edge, the way an app icon's glyph is. Turn it off for a mark drawn to fill the tile — a favicon, a photograph"
      }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: 'size를 대신하는 정확한 높이. 숫자는 픽셀. 브랜드 아트워크는 누군가 고른 높이로 그려져 있고, 그것을 사다리의 가까운 칸으로 반올림하면 옆 글자와 반 픽셀씩 어긋납니다',
        en: "An exact height, overriding size. Numbers are pixels: a brand's artwork is drawn at a height somebody chose, and rounding it to the nearest step of a ladder is how a logo ends up half a pixel off the type beside it"
      }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '전체를 링크로 만듭니다. 헤더의 로고는 거의 언제나 첫 페이지로 돌아가는 길입니다',
        en: 'Makes the whole lockup a link. A logo in a header is nearly always the way back to the front page'
      }
    },
    {
      name: 'imageProps',
      type: "Omit<ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>",
      description: {
        ko: 'img에 더 넘길 것들 — loading, decoding, crossOrigin',
        en: 'Anything else the img needs — loading, decoding, crossOrigin'
      }
    },
    renderProp('render={<h1 />}')
  ],

  Container: [
    {
      name: 'maxWidth',
      type: `${SIZE} | 'none'`,
      default: "'none'",
      description: {
        ko: '내용이 넓어질 수 있는 한계. 브레이크포인트와 같은 사다리입니다 — xs 30rem, sm 40rem, md 48rem, lg 64rem, xl 80rem. 기본값 none은 제한 없음',
        en: 'How wide the content may get, on the breakpoint ladder — xs 30rem, sm 40rem, md 48rem, lg 64rem, xl 80rem. The default, none, is no limit'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '좌우 여백. 끄면 가운데 정렬과 최대 너비는 그대로 두고 여백만 사라집니다',
        en: 'The gutter. Turning it off keeps the centring and the measure and drops only the padding'
      }
    },
    ...layoutPaddingProps,
    {
      name: 'centered',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'maxWidth가 페이지보다 좁을 때 가운데로 놓습니다. maxWidth가 none이면 남는 공간이 없으므로 아무 일도 하지 않습니다',
        en: 'Centres the content once maxWidth is narrower than the page. No effect while maxWidth is none — there is nothing left over to centre in'
      }
    },
    renderProp('<main />'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '여백을 두를 내용', en: 'What the gutter goes around' }
    }
  ],

  GridContainer: [
    {
      name: 'columns',
      type: RESPONSIVE,
      default: '12',
      description: {
        ko: '한 줄이 몇 칸으로 나뉘는지. 안쪽의 모든 span과 offset이 이 수를 기준으로 계산됩니다',
        en: 'How many columns a row divides into. Every span and offset inside is read against this number'
      }
    },
    {
      name: 'spacing',
      type: RESPONSIVE,
      default: '2',
      description: {
        ko: '항목 사이의 거터. Tailwind 간격 스케일이라 4는 1rem이며, 소수점도 받습니다 (1.5 → 0.375rem)',
        en: "The gutter between items, on Tailwind's spacing scale — 4 is 1rem. Fractions are allowed: 1.5 is 0.375rem"
      }
    },
    {
      name: 'rowSpacing',
      type: RESPONSIVE,
      default: 'spacing',
      description: { ko: '행 사이의 거터만', en: 'The gutter between rows only' }
    },
    {
      name: 'columnSpacing',
      type: RESPONSIVE,
      default: 'spacing',
      description: { ko: '열 사이의 거터만', en: 'The gutter between columns only' }
    },
    {
      name: 'justifyContent',
      type: JUSTIFY_CONTENT,
      description: {
        ko: '한 줄이 쓰고 남은 공간을 어떻게 나눌지. prop으로 직접 받습니다 — sx도 className도 필요 없습니다',
        en: 'How a row distributes the space its items did not use. A prop of its own, not something to reach for sx or className for'
      }
    },
    {
      name: 'alignItems',
      type: ALIGN_ITEMS,
      default: "'stretch'",
      description: {
        ko: '항목들이 줄을 가로질러 어디에 놓일지. 기본값은 늘리기라서 한 줄의 카드들은 높이가 같아집니다',
        en: 'How items sit across the row. The default stretches, so a row of cards is a row of one height'
      }
    },
    {
      name: 'alignContent',
      type: JUSTIFY_CONTENT,
      description: {
        ko: '그리드가 담긴 상자보다 짧을 때 행들이 어디에 놓일지. 높이를 가진 컨테이너에서만 보입니다',
        en: 'Where the rows sit when the grid is shorter than the box holding it. Only visible on a container with a height of its own'
      }
    },
    {
      name: 'wrap',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '칸이 모자란 줄이 다음 줄로 이어지는지. 끄면 넘치는 한 줄이 되며, 가로 스크롤 스트립이 원하는 모습입니다',
        en: 'Whether a row that runs out of columns continues on the next one. Off gives one overflowing row, which is what a scrolling strip wants'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 여백. 이미 여백을 가진 것 안에 있다면 끄세요 — Container, Card, 또 다른 그리드',
        en: 'Inner padding. Turn it off when the grid already sits inside something that pads — a Container, a Card, another grid'
      }
    },
    ...layoutPaddingProps,
    renderProp('<section />'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'Grid 항목들', en: 'The Grid items' }
    }
  ],

  Grid: [
    {
      name: 'span',
      type: RESPONSIVE,
      default: 'a full row',
      description: {
        ko: '컨테이너의 칸을 몇 개 차지할지. 브레이크포인트마다 다르게 줄 수 있습니다 — { xs: 12, md: 6 }. 줄보다 넓은 span은 넘치지 않고 줄에 맞춰 잘립니다',
        en: "How many of the container's columns the item takes. Per-breakpoint as { xs: 12, md: 6 }. A span wider than the row is clamped to the row rather than overflowing"
      }
    },
    {
      name: 'offset',
      type: RESPONSIVE,
      default: '0',
      description: {
        ko: '항목 앞에 밀어 넣는 빈 칸 수. 줄의 시작에서 센 절대 위치가 아니라 항목 앞에 들어가는 공간입니다',
        en: 'Columns left empty ahead of the item — space pushed in before it, not an absolute position counted from the start of the row'
      }
    },
    {
      name: 'alignSelf',
      type: ALIGN_SELF,
      description: {
        ko: '이 항목만 줄의 alignItems를 따르지 않게 합니다',
        en: "Overrides the row's alignItems for this item alone"
      }
    },
    renderProp('<li />'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '칸에 담기는 내용', en: 'What the cell holds' }
    }
  ],

  Card: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 하이라인과 구분선에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the hairline and the dividers only'
      },
      sizeDescription: {
        ko: '모서리 반경, 안쪽 여백, 헤더와 본문의 타입 스케일',
        en: 'Corner radius, padding, and the type scale of the header and body'
      },
      elevationDescription: {
        ko: '그림자 깊이. variant가 text면 무시됩니다',
        en: 'Drop shadow depth. Ignored when variant is text'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. 문서 개요에 넣어야 하면 실제 heading을 넘기세요 (title={<h2>…</h2>})',
        en: 'The heading. Pass a real heading element when it belongs in the document outline'
      }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 한 단계 작고 muted',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'headerAction',
      type: 'ReactNode',
      description: {
        ko: '헤더 행 끝에 고정되는 내용. 메뉴 버튼이나 상태 칩',
        en: 'Content pinned to the end of the header row — a menu button, a status chip'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '아래 영역. 줄바꿈되는 행으로 배치됩니다',
        en: 'The bottom area, laid out as a wrapping row'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '섹션 사이를 공백 대신 하이라인으로 나눕니다. 선은 시트의 양 끝까지 닿습니다',
        en: 'Separates the sections with a hairline instead of space, edge to edge'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '카드 본문', en: "The card's body" }
    },
    transitionProp('transition="grow"')
  ],

  ButtonGroup: [
    ...sharedProps({
      variant: '—',
      size: '—',
      color: '—',
      density: '—',
      elevation: '—',
      variantDescription: {
        ko: '그룹 안의 모든 버튼에 적용됩니다. 지정하지 않으면 Button 자신의 기본값이 그대로 쓰입니다',
        en: "Applied to every button in the group. Unset means the Button's own default stands"
      },
      sizeDescription: {
        ko: '그룹 안의 모든 버튼의 높이와 타입 스케일',
        en: 'Height and type scale for every button in the group'
      },
      colorDescription: {
        ko: '그룹 안의 모든 버튼의 색 역할. 버튼 하나가 자기 색을 따로 지정하면 그쪽이 이깁니다',
        en: "Colour role for every button in the group. A button's own prop still wins"
      },
      densityDescription: {
        ko: '그룹 안의 모든 버튼의 가로 여백',
        en: 'Horizontal padding for every button in the group'
      },
      elevationDescription: {
        ko: '그룹 안의 모든 버튼의 그림자 깊이',
        en: 'Drop shadow depth for every button in the group'
      }
    }),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '버튼이 이어지는 방향. 세로면 위아래 모서리가 깎입니다',
        en: 'Which way the buttons run. Vertical flattens the top and bottom corners instead'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '그룹 전체를 한 번에 비활성화합니다',
        en: 'Disables every button in the group at once'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비만큼 확장하고 버튼이 너비를 균등하게 나눠 가집니다',
        en: 'Stretches to the container and divides the width evenly between the buttons'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Button들. 중간에 다른 요소로 감싸도 그룹의 값은 전달됩니다',
        en: 'The buttons. The shared props reach them even through a wrapper'
      }
    }
  ],

  Toggle: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '토글이 **꺼져 있을 때**의 표면 무게. 켜졌을 때는 어느 weight든 색 계열이 전면에 나섭니다',
        en: 'How the toggle looks while it is **off**. On is always the colour family asserting itself'
      },
      colorDescription: {
        ko: '켜졌을 때 띠는 의미론적 색 역할. 꺼져 있으면 어느 계열이든 중립입니다',
        en: 'The semantic role it turns when it goes on. Off it is neutral in every family'
      }
    }),
    {
      name: 'pressed',
      type: 'boolean',
      description: {
        ko: '켜져 있는지 여부. onPressedChange와 함께 쓰면 controlled 컴포넌트가 됩니다',
        en: 'Whether it is on. With onPressedChange it makes the toggle controlled'
      }
    },
    {
      name: 'defaultPressed',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '처음에 켜진 채로 시작할지 여부 (uncontrolled)',
        en: 'Whether it starts on, for an uncontrolled toggle'
      }
    },
    {
      name: 'onPressedChange',
      type: '(pressed: boolean) => void',
      description: { ko: '상태가 바뀔 때마다 호출됩니다', en: 'Fired on every change' }
    },
    {
      name: 'value',
      type: 'string',
      description: {
        ko: 'ToggleGroup 안에서 이 토글을 식별하는 값',
        en: 'Identifies the toggle inside a ToggleGroup'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 내용. em 단위라 라벨을 따라갑니다',
        en: 'Content before the label. Sized in em, so it tracks the label'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤의 내용', en: 'Content after the label' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
        en: 'Unavailable. Drops the colour family for neutral grey'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비만큼 확장합니다',
        en: 'Stretches to the width of the container'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '라벨. 없으면 아이콘을 감싸는 정사각형이 되며, 이때는 aria-label이 필요합니다',
        en: 'The label. Without one the toggle goes square around its icon and needs an aria-label'
      }
    }
  ],

  ToggleGroup: [
    ...sharedProps({
      variant: '—',
      size: '—',
      color: '—',
      density: '—',
      elevation: '—',
      variantDescription: {
        ko: '세트 안의 모든 토글에 적용됩니다. 지정하지 않으면 Toggle 자신의 기본값이 그대로 쓰입니다',
        en: "Applied to every toggle in the set. Unset means the Toggle's own default stands"
      },
      sizeDescription: {
        ko: '세트 안의 모든 토글의 높이와 타입 스케일',
        en: 'Height and type scale for every toggle in the set'
      },
      colorDescription: {
        ko: '세트 안의 모든 토글의 색 역할. 토글 하나가 자기 색을 따로 지정하면 그쪽이 이깁니다',
        en: "Colour role for every toggle in the set. A toggle's own prop still wins"
      },
      densityDescription: {
        ko: '세트 안의 모든 토글의 가로 여백',
        en: 'Horizontal padding for every toggle in the set'
      },
      elevationDescription: {
        ko: '세트 안의 모든 토글의 그림자 깊이',
        en: 'Drop shadow depth for every toggle in the set'
      }
    }),
    {
      name: 'value',
      type: 'readonly string[]',
      description: {
        ko: '켜져 있는 토글들의 value. 단일 선택이든 다중 선택이든 배열입니다',
        en: 'Which toggles are on, by their value. An array in both the single and the multiple case'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly string[]',
      description: {
        ko: '처음에 켜져 있는 값들 (uncontrolled)',
        en: 'Which start on, for an uncontrolled set'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string[]) => void',
      description: { ko: '값이 바뀔 때마다 호출됩니다', en: 'Fired on every change' }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '동시에 여러 개를 켤 수 있는지 여부. 꺼져 있으면 하나를 켤 때 직전 것이 꺼집니다',
        en: 'Whether more than one can be on at a time. Off, turning one on turns the last one off'
      }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '토글이 이어지는 방향. 세로면 위아래 모서리가 깎입니다',
        en: 'Which way the toggles run. Vertical flattens the top and bottom corners instead'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '세트 전체를 한 번에 비활성화합니다',
        en: 'Disables every toggle in the set at once'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '방향키가 양 끝에서 순환할지 여부',
        en: 'Whether the arrow keys wrap around at the ends'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비만큼 확장하고 토글이 너비를 균등하게 나눠 가집니다',
        en: 'Stretches to the container and divides the width evenly between the toggles'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Toggle들. 중간에 다른 요소로 감싸도 세트의 값은 전달됩니다',
        en: 'The toggles. The shared props reach them even through a wrapper'
      }
    }
  ],

  Meter: [
    {
      name: 'value',
      type: 'number',
      required: true,
      description: {
        ko: '측정된 양. 필수이며, 이것이 ProgressLinear와의 차이입니다 — meter는 이미 알려진 양을 보고하므로 미정 상태가 없습니다',
        en: 'How much there is. Required, and that is the difference from ProgressLinear: a meter reports a quantity that is already known, so there is no indeterminate case'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '범위의 시작', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '범위의 끝', en: 'The top of the range' }
    },
    {
      name: 'thresholds',
      type: 'readonly MeterThreshold[]',
      description: {
        ko: '막대의 색이 바뀌는 지점들. { from, color } 배열이며 from이 작은 것부터 나열합니다. 값이 도달한 마지막 항목이 이기고, 아무 것에도 도달하지 못했다면 color가 그대로 쓰입니다',
        en: 'Where the bar changes colour, as { from, color } entries listed smallest first. The last one the value has reached wins; below all of them color stands'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇을 재고 있는지에 대한 이름. 값과 함께 읽힙니다',
        en: 'A name for what is being measured. Read out with the value'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '막대 옆에 값을 글자로 씁니다. format이 없으면 범위에 대한 비율입니다',
        en: 'Shows the value as text beside the bar. A share of the range unless format says otherwise'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 쓰는 방식. meter는 대개 실제 단위를 가지므로 프로그레스 바보다 자주 쓰입니다',
        en: 'How to write the value. A meter usually has real units, which is when this matters more than it does on a progress bar'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '홈의 두께. ProgressLinear과 같은 사다리입니다',
        en: 'Thickness of the groove, on the same ladder ProgressLinear uses'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'threshold에 도달하기 전 막대가 띠는 색 역할',
        en: 'The family the bar carries before any threshold is reached'
      }
    }
  ],

  MeterThreshold: [
    {
      name: 'from',
      type: 'number',
      required: true,
      description: {
        ko: '이 색 계열이 적용되기 시작하는 값. meter 자신의 단위로 씁니다',
        en: "The value from which this family applies, in the meter's own units"
      }
    },
    {
      name: 'color',
      type: COLOR,
      required: true,
      shared: true,
      description: {
        ko: '그 지점부터 막대가 띠는 색',
        en: 'What the bar turns at and above that point'
      }
    }
  ],

  HoverCard: [
    {
      name: 'trigger',
      type: 'ReactElement',
      required: true,
      description: {
        ko: '카드가 매달리는 요소. ref를 받고 props를 펼치는 요소 하나여야 하며, 카드는 감싸지 않고 그 요소에 병합됩니다',
        en: 'What the card hangs off. One element that accepts a ref and spreads props; the card merges onto it rather than wrapping it'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '카드의 제목', en: 'The heading' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '제목 아래 한 줄', en: 'A line under the title' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '카드의 본문', en: 'The body' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백, 그리고 카드가 넓어질 수 있는 한계까지 함께 정합니다',
        en: 'The type scale, the padding, and how wide the card may get'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 시트는 물들지 않으므로 가장자리에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed, so it reaches the edge'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '카드 안쪽 여백만 바꿉니다',
        en: "Changes the card's inset and nothing else"
      }
    },
    {
      name: 'side',
      type: SIDE,
      default: "'bottom'",
      shared: true,
      description: {
        ko: '카드가 나타나는 trigger의 모서리. 공간이 없으면 반대편으로 뒤집힙니다',
        en: 'Which edge of the trigger it appears on. Flips when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: { ko: '그 모서리 위에서의 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: 'trigger와의 거리 (px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'alignOffset',
      type: 'number',
      default: '0',
      description: { ko: '그 모서리를 따라 미는 양 (px)', en: 'Shift along that edge, in pixels' }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'trigger를 가리키는 꼭지를 그립니다. 반투명한 표면의 꼭지는 흐려진 배경을 함께 가져갈 수 없어 기본은 꺼짐입니다',
        en: "Draws the wedge pointing at the trigger. Off by default: a translucent sheet's wedge cannot carry the blurred backdrop with it"
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께 쓰면 controlled 컴포넌트가 됩니다',
        en: 'Whether the card is open. With onOpenChange it makes it controlled'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: '열린 채로 시작할지 여부 (uncontrolled)',
        en: 'Whether it starts open, uncontrolled'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리고 닫힐 때마다 호출됩니다', en: 'Fired whenever it opens or closes' }
    },
    {
      name: 'delay',
      type: 'number',
      description: {
        ko: '카드가 열리기까지 포인터가 머물러야 하는 시간 (ms)',
        en: 'How long the pointer has to rest on the trigger before the card opens, in milliseconds'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      description: {
        ko: '포인터가 떠난 뒤 카드가 남아 있는 시간 (ms). trigger와 카드 사이의 빈틈을 건널 수 있게 합니다',
        en: 'How long the card stays after the pointer has left, in milliseconds. This is what makes the gap crossable'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정한 최대 너비를 덮어씁니다. 숫자는 px입니다',
        en: 'A hard cap on the width, overriding the one size implies. Numbers are pixels'
      }
    }
  ],

  ScrollArea: [
    {
      name: 'orientation',
      type: "'vertical' | 'horizontal' | 'both'",
      default: "'vertical'",
      shared: true,
      description: {
        ko: '스크롤할 수 있는 축. NebaOrientation에 값 하나를 더한 형태입니다 — both는 그 타입을 쓰는 다른 컴포넌트에서는 의미가 없습니다',
        en: "Which axes may scroll. NebaOrientation plus a third value: 'both' means nothing anywhere else that type is used"
      }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: '고정 높이. 세로 스크롤 영역은 무언가로 묶여야 스크롤할 것이 생깁니다. 숫자는 px입니다',
        en: 'A fixed height. A vertical scroll area has to be bounded by something or there is nothing to scroll. Numbers are pixels'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '같은 것을 상한으로',
        en: 'The same, as a ceiling rather than a fixed height'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '내용이 더 남아 있는 가장자리에서만 내용을 서서히 지웁니다. 내용 위의 그러데이션이 아니라 mask라서 반투명한 표면 위에서도 성립합니다',
        en: 'Fades the content out at each edge that has more beyond it, and only at those. A mask rather than a gradient over the content, so it works on a translucent surface'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '레일의 두께. 스크롤바는 컨트롤이 아니므로 컨트롤 높이와는 다른 사다리입니다',
        en: 'Thickness of the rail. A scrollbar is not a control, so it has its own ladder well below the control heights'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: 'thumb이 띠는 색 계열. 글 옆에서 두 번째 단처럼 보이지 않도록 낮춰 섞습니다',
        en: 'The family the thumb carries, mixed down so it does not read as a second column beside the text'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '스크롤되는 내용', en: 'What is scrolled' }
    }
  ],

  Form: [
    {
      name: 'onSubmit',
      type: '(values: Record<string, unknown>) => void',
      description: {
        ko: '모든 field가 유효할 때만, 각 field의 name을 키로 하는 값 객체와 함께 호출됩니다. 네이티브 submit 이벤트는 막히므로 페이지가 이동하지 않습니다',
        en: "Called only when every field is valid, with the form's values keyed by each field's name. The native submit event is prevented, so nothing navigates"
      }
    },
    {
      name: 'validationMode',
      type: "'onSubmit' | 'onBlur' | 'onChange'",
      default: "'onSubmit'",
      description: {
        ko: 'field가 언제 검사받는지. onSubmit은 제출할 때(그 뒤로는 변경할 때마다), onBlur는 focus가 빠질 때, onChange는 키를 누를 때마다입니다',
        en: 'When a field validates. onSubmit means on submit and on every change afterwards, onBlur when it loses focus, onChange on every keystroke'
      }
    },
    {
      name: 'errors',
      type: 'Record<string, string | string[]>',
      description: {
        ko: '브라우저 바깥에서 온 오류 — 서버, form action, 스키마 — 를 field의 name으로 키를 잡아 전달합니다. 해당 field에 표시되고 그 field가 바뀌면 사라집니다',
        en: "Errors from outside the browser's own validation, keyed by the name of the field each belongs to. Shown on that field and cleared as soon as it changes"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'children 사이의 간격. form은 세로 열이고, 이것이 어느 사다리 위에 쌓이는지를 정합니다',
        en: 'The gap between the children. A form is a stack, and this is which rung it stacks on'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'field들과 제출 버튼', en: 'The fields and the submit button' }
    }
  ],

  Fieldset: [
    {
      name: 'legend',
      type: 'ReactNode',
      description: {
        ko: '묶음의 이름. 안의 모든 컨트롤의 접근 가능한 이름이 되므로, 각 컨트롤 앞에 붙여 읽어도 말이 되는 구절이어야 합니다',
        en: 'What the group is called. It becomes the accessible name of every control inside, so it has to read correctly in front of each of them'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: 'legend 아래 한 줄', en: 'A line under the legend' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '안의 모든 컨트롤을 한 번에 비활성화합니다. 진짜 fieldset만 할 수 있는 일입니다',
        en: 'Disables every control inside at once, the way only a real fieldset can'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'legend의 타입 스케일과 컨트롤 사이의 간격. 컨트롤 자체에는 닿지 않습니다',
        en: 'The type scale of the legend and the gap between the controls. It does not reach the controls themselves'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '묶이는 컨트롤들', en: 'The controls being grouped' }
    }
  ],

  Menubar: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '단어의 높이와 타입 스케일. 각 단계에서 컨트롤 높이보다 한 칸 아래인 자기만의 사다리입니다',
        en: 'The height and type scale of the words. Its own ladder, one rung below the control heights at every step'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '열린 메뉴의 단어가 띠는 색 역할',
        en: 'The role the word of an open menu carries'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '단어의 가로 여백만 바꿉니다',
        en: 'The horizontal padding of the words and nothing else'
      }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '띠가 이어지는 방향. 방향키도 이를 따릅니다',
        en: 'Which way the bar runs. The arrow keys follow it'
      }
    },
    {
      name: 'modal',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '열린 메뉴가 뒤 페이지를 가져가는지 여부',
        en: 'Whether an open menu takes the page away'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '방향키가 바 양 끝에서 순환할지 여부',
        en: 'Whether the arrow keys wrap around at the ends of the bar'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '바 위의 모든 메뉴를 한 번에 비활성화합니다',
        en: 'Disables every menu on the bar at once'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'MenubarMenu들', en: 'The menus' }
    }
  ],

  MenubarMenu: [
    {
      name: 'label',
      type: 'ReactNode',
      required: true,
      description: { ko: '바 위에 놓이는 단어', en: 'The word on the bar' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '단어 앞의 내용. em 단위라 단어를 따라갑니다',
        en: 'Content before the label. Sized in em, so it tracks it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 단어는 바에 남고 아무것도 열지 않습니다',
        en: 'Unavailable. The word stays on the bar and opens nothing'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '행들. Menu 안에 쓰는 것과 똑같이 씁니다',
        en: 'The rows, written exactly as they are inside a Menu'
      }
    }
  ],

  Checkbox: [
    ...scaleProps("'md'"),
    ...fieldProps,
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '체크 여부. onCheckedChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether it is ticked. Use with onCheckedChange for a controlled checkbox'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: '초기 체크 여부', en: 'The initial state, for an uncontrolled checkbox' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: {
        ko: '체크 상태가 바뀔 때',
        en: 'Called when the checkbox is ticked or unticked'
      }
    },
    {
      name: 'indeterminate',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '켜짐도 꺼짐도 아닌 중간 상태. 하위 항목 일부만 체크된 부모 체크박스',
        en: 'Neither ticked nor unticked — a parent whose children disagree'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 반드시 체크해야 함',
        en: 'Must be ticked before the form submits'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  Switch: [
    ...scaleProps("'md'"),
    ...fieldProps,
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '켜짐 여부. onCheckedChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether it is on. Use with onCheckedChange for a controlled switch'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: '초기 켜짐 여부', en: 'The initial state, for an uncontrolled switch' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: { ko: '켜고 꺼질 때', en: 'Called when the switch is turned on or off' }
    },
    {
      name: 'labelPlacement',
      type: "'start' | 'end'",
      default: "'end'",
      description: {
        ko: '라벨이 놓이는 쪽. start는 설정 목록처럼 스위치가 오른쪽에 정렬되어야 할 때',
        en: 'Which side the label sits on. `start` is for a settings list, where the switches line up on the right'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  RadioGroup: [
    ...scaleProps("'md'", "'primary'", {
      ko: '의미론적 색 역할. 그룹이 정하고 모든 Radio가 물려받습니다',
      en: 'Semantic colour role. Set on the group, inherited by every Radio'
    }),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'vertical'",
      shared: true,
      description: {
        ko: '옵션이 쌓이는 방향. 세로가 기본입니다 — 가로는 라벨이 길어지는 순간 읽을 수 없어집니다',
        en: 'Which way the options stack. Vertical by default — a row breaks the moment one label is long'
      }
    },
    ...fieldProps,
    {
      name: 'value',
      type: 'Value',
      description: {
        ko: '선택된 값. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value. Use with onValueChange for a controlled group'
      }
    },
    {
      name: 'defaultValue',
      type: 'Value',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled group' }
    },
    {
      name: 'onValueChange',
      type: '(value: Value, details) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen option changes' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 하나를 골라야 함',
        en: 'One option must be chosen before the form submits'
      }
    },
    ...inertProps,
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'Radio들', en: 'The Radio options' }
    }
  ],

  Radio: [
    {
      name: 'value',
      type: 'Value',
      required: true,
      description: {
        ko: '이 옵션을 식별하는 값. 그룹의 value와 같은 언어로 말합니다',
        en: 'Identifies this option. Speaks the same language as the group’s value'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '점 옆의 라벨', en: 'The text beside the dot' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    ...inertProps
  ],

  Select: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸이므로 폼 안에서 두 컨트롤이 구분되지 않습니다',
        en: 'Weight of the surface. The same shell as a TextField, so the two are indistinguishable in a form'
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. Button·TextField와 같은 높이입니다',
        en: 'Height and type scale. The same heights as Button and TextField'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge and the focus ring'
      },
      elevationDescription: {
        ko: '트리거의 그림자 깊이. 팝업은 자기 그림자를 따로 가집니다',
        en: 'Drop shadow depth of the trigger. The popup carries its own'
      }
    }),
    {
      name: 'items',
      type: 'readonly SelectOption[]',
      required: true,
      description: {
        ko: '옵션 목록. { value, label?, disabled? } 배열입니다',
        en: 'The options, as an array of { value, label?, disabled? }'
      }
    },
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 값. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value. Use with onValueChange for a controlled select'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled select' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen value changes' }
    },
    {
      name: 'placeholder',
      type: 'ReactNode',
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 보이는 내용',
        en: 'Shown in the trigger while nothing is chosen'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '값 앞에 놓이는 내용', en: 'Content before the value' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  DatePicker: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField·Select와 같은 셸입니다',
        en: 'Weight of the surface. The same shell as a TextField and a Select'
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. 달력의 한 칸도 같은 사다리를 씁니다 — md는 32px',
        en: 'Height and type scale. A day cell is on the same ladder — 32px at md'
      },
      elevationDescription: {
        ko: '트리거의 그림자 깊이. 팝업은 자기 그림자를 따로 가집니다',
        en: 'Drop shadow depth of the trigger. The popup carries its own'
      }
    }),
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 날. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen day. Use with onValueChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: '초기 값', en: 'The initial value, for an uncontrolled picker' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen day changes' }
    },
    ...calendarProps({
      ko: '고를 수 있는 가장 이른 날. 날짜 단위로만 비교하므로 시각은 무시됩니다',
      en: 'The earliest day that may be chosen. Day-granular — the time of day is ignored'
    }),
    {
      name: 'showTodayButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 오늘로 가는 단축 버튼',
        en: 'Offers the shortcut to today in the footer'
      }
    },
    ...pickerProps({
      closeOnSelect: 'true',
      closeOnSelectDescription: {
        ko: '날을 고르는 즉시 팝업을 닫습니다. 물어본 것이 하나뿐이므로 기본값이 true입니다',
        en: 'Closes the popup as soon as a day is chosen. True by default, because only one thing was asked'
      },
      submitted: {
        ko: '폼 제출 시의 필드 이름. 값은 YYYY-MM-DD로, UTC가 아니라 로컬 기준입니다',
        en: 'Identifies the field when a form is submitted, as YYYY-MM-DD — local, not UTC'
      }
    })
  ],

  TimePicker: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. 시계 열의 행 높이도 같습니다',
        en: 'Height and type scale. A row of the clock is the same height'
      }
    }),
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 시각. Date이므로 날짜도 함께 지닙니다 — referenceDate를 보세요',
        en: 'The chosen time. A Date, so it carries a day as well — see referenceDate'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: '초기 값', en: 'The initial value, for an uncontrolled picker' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen time changes' }
    },
    {
      name: 'referenceDate',
      type: 'Date',
      default: 'today',
      description: {
        ko: '값이 아직 없을 때 고른 시각이 얹히는 날',
        en: 'The day a chosen time is written onto while there is no value yet'
      }
    },
    {
      name: 'minTime',
      type: 'Date | null',
      description: {
        ko: '고를 수 있는 가장 이른 시각. 날짜는 무시하고 시계만 읽습니다. 열이 그리는 범위 단위로 비교하므로 09:30이면 9시는 남고 그 앞의 분들이 빠집니다',
        en: 'The earliest time of day that may be chosen — only the clock is read. Compared against the span a row stands for, so 09:30 keeps the hour 9 and greys out the minutes before it'
      }
    },
    {
      name: 'maxTime',
      type: 'Date | null',
      description: { ko: '같은 범위의 반대쪽 끝', en: 'The other end of the same span' }
    },
    ...clockProps,
    {
      name: 'showNowButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 지금으로 가는 단축 버튼',
        en: 'Offers the shortcut to the current time in the footer'
      }
    },
    ...pickerProps({
      closeOnSelect: 'false',
      closeOnSelectDescription: {
        ko: '열을 건드리는 즉시 닫습니다. DatePicker와 달리 기본값이 false입니다 — 시각은 답이 둘이라, 첫 번째에서 닫으면 9시 30분을 고르는 데 팝업을 두 번 열어야 합니다',
        en: 'Closes the popup as soon as a column is touched. False by default, unlike DatePicker: a time is two answers, and closing after the first would make choosing 9:30 a matter of opening the popup twice'
      },
      submitted: {
        ko: '폼 제출 시의 필드 이름. 값은 HH:MM (초를 보이면 HH:MM:SS)',
        en: 'Identifies the field when a form is submitted, as HH:MM (HH:MM:SS with seconds shown)'
      }
    })
  ],

  DateTimePicker: [
    ...sharedProps({ variant: "'outline'", size: "'md'" }),
    {
      name: 'value',
      type: 'Date | null',
      description: {
        ko: '선택된 순간. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen moment. Use with onValueChange for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'Date | null',
      description: { ko: '초기 값', en: 'The initial value, for an uncontrolled picker' }
    },
    {
      name: 'onValueChange',
      type: '(value: Date | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen moment changes' }
    },
    ...calendarProps({
      ko: '고를 수 있는 가장 이른 순간. DatePicker와 달리 시각까지 읽습니다 — 그 날은 달력에 남고, 시계에서 그 앞 시간들이 빠집니다',
      en: "The earliest moment that may be chosen. Unlike DatePicker's this is read at full precision: the day stays selectable in the calendar and the clock blocks the hours before it"
    }),
    ...clockProps,
    {
      name: 'showNowButton',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '푸터에 지금으로 가는 단축 버튼',
        en: 'Offers the shortcut to this moment in the footer'
      }
    },
    ...pickerProps({
      closeOnSelect: 'false',
      closeOnSelectDescription: {
        ko: '날을 고르는 즉시 닫습니다. 순간은 날 *그리고* 시각이므로, 둘 중 첫 번째에서 닫으면 두 번째를 묻지 못한 채 끝납니다',
        en: 'Closes the popup as soon as a day is chosen. A moment is a day *and* a time, so closing on the first of the two would leave the second unanswered'
      },
      submitted: {
        ko: '폼 제출 시의 필드 이름. 값은 YYYY-MM-DDTHH:MM, 로컬 기준입니다',
        en: 'Identifies the field when a form is submitted, as YYYY-MM-DDTHH:MM — local, not UTC'
      }
    })
  ],

  DateRangePicker: [
    ...sharedProps({ variant: "'outline'", size: "'md'" }),
    {
      name: 'value',
      type: 'DateRange | null',
      description: {
        ko: '선택된 범위. { start, end }이고 각각 null일 수 있습니다',
        en: 'The chosen range, as { start, end } with either end possibly null'
      }
    },
    {
      name: 'defaultValue',
      type: 'DateRange | null',
      description: { ko: '초기 범위', en: 'The initial range, for an uncontrolled picker' }
    },
    {
      name: 'onValueChange',
      type: '(value: DateRange) => void',
      description: {
        ko: '항상 객체로 불립니다. 비워진 범위는 { start: null, end: null }',
        en: 'Always called with an object. A cleared range is { start: null, end: null }'
      }
    },
    ...calendarProps({
      ko: '고를 수 있는 가장 이른 날. 두 패널 모두에 적용됩니다',
      en: 'The earliest day that may be chosen, in both panels'
    }),
    {
      name: 'monthCount',
      type: '1 | 2',
      default: '2',
      description: {
        ko: '한 번에 보이는 달의 수. 달을 넘는 범위가 예외가 아니라 보통이라 2가 기본값입니다',
        en: 'How many months are on screen at once. Two by default, because a range that crosses a month boundary is the ordinary case'
      }
    },
    {
      name: 'startPlaceholder',
      type: 'ReactNode',
      description: {
        ko: '시작이 비었을 때 트리거의 왼쪽 절반에 보이는 내용',
        en: 'Shown in the first half of the trigger while the start is unchosen'
      }
    },
    {
      name: 'endPlaceholder',
      type: 'ReactNode',
      description: { ko: '끝이 비었을 때의 같은 것', en: 'The same, for the end' }
    },
    {
      name: 'presets',
      type: 'readonly DateRangePreset[]',
      description: {
        ko: '달력 옆에 놓이는 단축 범위들 — "최근 7일", "이번 달". value가 함수면 눌린 시점에 계산됩니다',
        en: 'Shortcuts listed beside the calendars — "Last 7 days", "This month". A function value is computed when it is pressed'
      }
    },
    ...pickerProps({
      placeholder: false,
      closeOnSelect: 'true',
      closeOnSelectDescription: {
        ko: '두 끝이 다 정해지면 팝업을 닫습니다',
        en: 'Closes the popup once both ends are chosen'
      },
      submitted: {
        ko: '폼 제출 시의 필드 이름. 같은 이름의 hidden input 두 개가 나가므로 FormData.getAll로 받습니다',
        en: 'Identifies the field when a form is submitted. Two hidden inputs of the same name, so the ends arrive as FormData.getAll(name)'
      }
    })
  ],

  Slider: [
    ...scaleProps("'md'"),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '트랙이 놓이는 방향. 세로는 길이를 직접 정해 주세요',
        en: 'Which way the track runs. A vertical slider needs a height of its own'
      }
    },
    {
      name: 'value',
      type: 'number | number[]',
      description: {
        ko: '현재 값. 배열이면 thumb이 값마다 하나씩 생깁니다',
        en: 'The current value. An array gives one thumb per entry'
      }
    },
    {
      name: 'defaultValue',
      type: 'number | number[]',
      description: { ko: '초기 값', en: 'The initial value, for an uncontrolled slider' }
    },
    {
      name: 'onValueChange',
      type: '(value, details) => void',
      description: { ko: '끄는 동안 계속 호출됩니다', en: 'Called throughout the drag' }
    },
    {
      name: 'onValueCommitted',
      type: '(value, details) => void',
      description: {
        ko: '값이 확정될 때 한 번만. 네트워크 요청은 이쪽에 거세요',
        en: 'Called once, when the value settles. Put the network request here'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '최솟값', en: 'The lowest allowed value' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '최댓값', en: 'The highest allowed value' }
    },
    {
      name: 'step',
      type: 'number',
      default: '1',
      description: { ko: '값이 움직이는 단위', en: 'The granularity the value moves in' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '트랙 위의 라벨', en: 'The label above the track' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '트랙 아래 보조 설명', en: 'Helper text below the track' }
    },
    {
      name: 'showValue',
      type: 'boolean | ((formatted, values) => ReactNode)',
      default: 'false',
      description: {
        ko: '라벨 옆에 현재 값을 보여 줍니다. 함수를 넘기면 표시 형식을 직접 정할 수 있습니다',
        en: 'Shows the current value beside the label. Pass a function to format it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    }
  ],

  Divider: [
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '선이 놓이는 방향. 세로 선은 자기 높이가 없고 flex 부모에 맞춰 늘어납니다',
        en: 'Which way the line runs. A vertical rule has no height of its own — it stretches to its flex parent'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. Card가 섹션을 나눌 때 쓰는 것과 같은 하이라인입니다',
        en: 'Semantic colour role. The same hairline a Card scores its sections with'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '라벨의 타입 스케일. 선 자체에는 크기가 없습니다',
        en: 'Type scale of the label. The line itself has no size'
      }
    },
    {
      name: 'length',
      type: 'number | string',
      description: {
        ko: '선이 뻗는 길이 — 가로 divider의 너비, 세로 divider의 높이. 숫자는 px, 문자열은 임의의 CSS 길이입니다. 생략하면 가로는 컨테이너의 100%, 세로는 flex 행 높이만큼 늘어납니다',
        en: 'How far the rule runs — the width of a horizontal divider, the height of a vertical one. A number is pixels, a string is any CSS length. Left out, a horizontal rule is the full width of its container and a vertical one stretches to its flex row'
      }
    },
    {
      name: 'thickness',
      type: 'number | string',
      default: '1',
      description: {
        ko: '선의 두께. 숫자는 px, 문자열은 임의의 CSS 길이입니다',
        en: 'How thick the rule is. A number is pixels, a string is any CSS length'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '선 사이에 들어가는 라벨. 문자열이면 aria-label로도 쓰입니다',
        en: 'A label set into the line. A string is copied into aria-label as well'
      }
    },
    {
      name: 'textAlign',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: {
        ko: '라벨의 위치. 가운데가 아니면 가까운 쪽에 짧은 선이 남습니다',
        en: 'Where the label sits. Off-centre leaves a short stub on the near side'
      }
    }
  ],

  Chip: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 삭제 버튼의 접근성 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag naming the delete button in that language'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. 같은 size의 컨트롤보다 한 단계 낮습니다 — md 칩은 sm 컨트롤입니다',
        en: 'Height and type scale, one step below the control of the same size — a md chip is a sm control'
      },
      elevationDescription: {
        ko: '그림자 깊이. 칩은 다른 것 위에 얹힌 토큰이라 거의 올리지 않습니다',
        en: 'Drop shadow depth. A chip sits on something else, so this is rarely raised'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용 — 아이콘, 상태 점, 아바타',
        en: 'Content before the label — an icon, a status dot, an avatar'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, count 앞에 놓이는 내용',
        en: 'Content after the label, before any count'
      }
    },
    {
      name: 'count',
      type: 'ReactNode',
      description: {
        ko: '끝에 붙는 숫자. 자기 판 위에 그려져 칩 하나로 읽힙니다',
        en: 'A number set into the end, on its own small plate'
      }
    },
    {
      name: 'onClick',
      type: '(event) => void',
      description: {
        ko: '넘기면 라벨이 진짜 button이 됩니다',
        en: 'Passing it turns the label into a real button'
      }
    },
    {
      name: 'onDelete',
      type: '(event) => void',
      description: {
        ko: '넘기면 삭제 버튼이 나타납니다. onClick과 별개의 버튼입니다',
        en: 'Passing it adds the delete button — its own button, separate from onClick'
      }
    },
    {
      name: 'deleteLabel',
      type: 'string',
      description: { ko: '삭제 버튼의 접근성 이름', en: 'Accessible name of the delete button' }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선택됨. 색 계열을 바꾸는 대신 표면을 한 단계 깊게 만듭니다',
        en: 'Chosen. Deepens the surface a step rather than changing the colour family'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '칩의 라벨', en: "The chip's label" }
    },
    transitionProp('transition="zoom"')
  ],

  Table: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. Box에 그대로 전달됩니다 — text로 두면 시트 없이 행만 남습니다',
        en: 'Weight of the surface, passed straight to the Box. `text` leaves the rows with no sheet'
      },
      sizeDescription: {
        ko: '셀의 타입 스케일과 여백, 시트의 모서리 반경',
        en: 'Type scale and padding of the cells, and the radius of the sheet'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 시트는 흰색이므로 하이라인과 행 사이 선에만 나타납니다',
        en: 'Semantic colour role. The sheet is white, so it reaches the hairline and the rules between rows'
      }
    }),
    {
      name: 'headers',
      type: 'readonly TableColumn[]',
      required: true,
      description: {
        ko: '열 정의. key·label·width·align·render를 가집니다',
        en: 'The columns: key, label, width, align and render'
      }
    },
    {
      name: 'items',
      type: 'readonly Row[]',
      required: true,
      description: { ko: '행 데이터', en: 'The rows' }
    },
    {
      name: 'getRowKey',
      type: '(row, index) => Key',
      default: 'index',
      description: {
        ko: '행의 안정적인 key. 정렬이나 필터가 있으면 반드시 넘기세요',
        en: 'A stable key per row. Required the moment the table sorts or filters'
      }
    },
    {
      name: 'caption',
      type: 'ReactNode',
      description: {
        ko: '표 위의 설명. 접근성 이름으로도 읽힙니다',
        en: 'Shown above the table, and read as its accessible name'
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      description: {
        ko: 'items가 비었을 때 대신 보여 줄 내용',
        en: 'What to show instead of rows when items is empty'
      }
    },
    {
      name: 'striped',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 행 걸러 배경을 깝니다. 넓은 표에서 눈이 가로로 따라가야 할 때',
        en: 'Tints every other row. For a wide table the eye has to track across'
      }
    },
    {
      name: 'hoverable',
      type: 'boolean',
      default: 'false',
      description: { ko: '포인터가 올라간 행을 밝힙니다', en: 'Lights the row under the pointer' }
    },
    {
      name: 'stickyHeader',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '본문이 스크롤될 때 머리행을 고정합니다. 표의 높이가 제한되어 있어야 의미가 있습니다',
        en: 'Pins the header while the body scrolls. Only does anything if the height is constrained'
      }
    },
    {
      name: 'onRowClick',
      type: '(row, index) => void',
      description: { ko: '행을 누를 수 있게 만듭니다', en: 'Makes the rows activatable' }
    }
  ],

  DataTable: [
    ...sharedProps({
      variant: "'outline'",
      size: "'sm'",
      density: "'compact'",
      variantDescription: {
        ko: '표면의 무게. Box에 그대로 전달됩니다',
        en: 'Weight of the surface, passed straight to the Box'
      },
      sizeDescription: {
        ko: '셀의 타입 스케일과 여백, 그리고 rowHeight의 기본값. Table보다 한 단계 촘촘합니다',
        en: "Type scale and padding of the cells, and the default rowHeight. One step tighter than Table's"
      },
      densityDescription: {
        ko: '여백만 바꿉니다 — 다만 여기서는 rowHeight의 기본값도 함께 내려갑니다',
        en: 'Padding only — though here it also lowers the default rowHeight'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 시트는 흰색이므로 하이라인·선택된 행·정렬된 열에만 나타납니다',
        en: 'Semantic colour role. The sheet stays white, so it reaches the hairline, the chosen rows and the sorted column'
      }
    }),
    {
      name: 'headers',
      type: 'readonly DataTableColumn[]',
      required: true,
      description: {
        ko: '열 정의. 아래 DataTableColumn 참고',
        en: 'The columns — see DataTableColumn below'
      }
    },
    {
      name: 'items',
      type: 'readonly Row[]',
      required: true,
      description: { ko: '행 데이터', en: 'The rows' }
    },
    {
      name: 'getRowKey',
      type: '(row, index) => Key',
      default: 'index',
      description: {
        ko: '행의 안정적인 식별자이자 selected가 담는 값. 선택·정렬·필터를 쓴다면 반드시 넘기세요',
        en: 'A stable identity per row, and what selected is a list of. Required in practice the moment rows can be chosen, sorted or filtered'
      }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: '스크롤 본문의 높이. **virtual scroll을 켜는 것이 바로 이 prop입니다**',
        en: 'The height of the scrolling body. **This is what turns virtual scrolling on**'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '같은 것을 상한으로. 행이 적으면 그만큼만 차지합니다',
        en: 'The same, as a ceiling: as tall as its rows, up to this'
      }
    },
    {
      name: 'rowHeight',
      type: 'number',
      default: 'size/density',
      description: {
        ko: '행 하나의 높이(px). 모든 행이 같은 높이이며 셀은 줄바꿈 없이 잘립니다',
        en: 'How tall one row is, in pixels. Every row is this tall and cells truncate rather than wrap'
      }
    },
    {
      name: 'virtual',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '화면 밖 행을 DOM에서 뺍니다. height 또는 maxHeight가 있어야 동작합니다',
        en: 'Leaves off-screen rows out of the DOM. Needs a height or a maxHeight to do anything'
      }
    },
    {
      name: 'overscan',
      type: 'number',
      default: '8',
      description: {
        ko: '뷰포트 위아래로 더 그려 두는 행 수',
        en: 'How many rows are kept rendered past each edge of the viewport'
      }
    },
    {
      name: 'striped',
      type: "boolean | 'odd' | 'even'",
      default: 'false',
      description: {
        ko: '한 행 걸러 색을 깝니다. true는 even이며, 홀짝은 전체 순번으로 셉니다',
        en: 'Tints every other row. true means even, and the parity is counted over the whole set'
      }
    },
    {
      name: 'hoverable',
      type: 'boolean',
      default: 'true',
      description: { ko: '포인터가 올라간 행을 밝힙니다', en: 'Lights the row under the pointer' }
    },
    {
      name: 'stickyHeader',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '본문이 스크롤될 때 머리행을 고정합니다',
        en: 'Pins the header while the body scrolls'
      }
    },
    {
      name: 'caption',
      type: 'ReactNode',
      description: {
        ko: '표 위의 설명. 접근성 이름으로도 읽힙니다',
        en: 'Shown above the table, and read as its accessible name'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: 'caption이 없을 때 grid를 부르는 이름',
        en: 'The name the grid is announced by, when there is no caption'
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      description: {
        ko: '행이 하나도 없을 때 대신 보여 줄 내용',
        en: 'What to show instead of rows when there are none'
      }
    },
    {
      name: 'sortable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모든 열을 정렬 가능하게. 열이 자기 sortable로 뒤집을 수 있습니다',
        en: 'Makes every column sortable. A column overrides it with its own sortable'
      }
    },
    {
      name: 'sortMode',
      type: "'single' | 'multiple'",
      default: "'single'",
      description: {
        ko: 'multiple이면 Shift-클릭이 정렬을 교체하지 않고 덧붙입니다',
        en: 'With multiple, a Shift-click adds a column to the sort instead of replacing it'
      }
    },
    {
      name: 'sort / defaultSort',
      type: 'readonly DataTableSort[]',
      description: {
        ko: '정렬 상태. { key, direction } 목록이며 앞쪽이 우선입니다',
        en: 'The sort: a list of { key, direction }, first key outermost'
      }
    },
    {
      name: 'onSortChange',
      type: '(sort: DataTableSort[]) => void',
      description: { ko: '정렬이 바뀔 때', en: 'Fires when the sort changes' }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '머리행 경계를 끌어 열 너비를 바꿉니다. 핸들을 더블클릭하면 원래 너비로',
        en: 'Lets the headers be dragged wider. A double-click on the handle restores the original width'
      }
    },
    {
      name: 'columnWidths / defaultColumnWidths',
      type: 'Record<string, number>',
      description: { ko: '열별 너비(px)', en: 'The widths, in pixels, keyed by column' }
    },
    {
      name: 'onColumnWidthsChange',
      type: '(widths) => void',
      description: { ko: '너비가 바뀔 때', en: 'Fires when a column is resized' }
    },
    {
      name: 'selectionMode',
      type: "'none' | 'single' | 'multiple'",
      default: "'none'",
      description: {
        ko: '한 번에 고를 수 있는 행 수',
        en: 'How many rows may be chosen at once'
      }
    },
    {
      name: 'selected / defaultSelected',
      type: 'readonly Key[]',
      description: {
        ko: '선택된 행의 key 목록',
        en: 'The chosen rows, as their keys'
      }
    },
    {
      name: 'onSelectedChange',
      type: '(keys: Key[], rows: Row[]) => void',
      description: {
        ko: 'key와 그 뒤의 행. 다른 페이지의 행도 포함합니다',
        en: 'The keys, and the rows behind them — including rows on other pages'
      }
    },
    {
      name: 'checkboxes',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '체크박스 열과, 보이는 행을 한 번에 고르는 머리행 체크박스를 답니다',
        en: 'Adds a column of ticks, and one in the header that chooses every displayed row at once'
      }
    },
    {
      name: 'onRowClick',
      type: '(row, index, event) => void',
      description: {
        ko: '행을 누를 때마다, 선택이 바뀌기 전에',
        en: 'Fires on every press of a row, before the selection changes'
      }
    },
    {
      name: 'onRowActivate',
      type: '(row, index) => void',
      description: {
        ko: '더블클릭과 Enter. 행을 여는 동작입니다',
        en: 'Fires on a double-click and on Enter — opening the row is what this is'
      }
    },
    {
      name: 'paging',
      type: "'scroll' | 'pages'",
      default: "'scroll'",
      description: {
        ko: '전체를 한 번에 스크롤할지, 한 페이지씩 끊을지',
        en: 'Whether the rows arrive all at once or a page at a time'
      }
    },
    {
      name: 'page / defaultPage',
      type: 'number',
      default: '1',
      description: { ko: '현재 페이지(1부터)', en: 'The current page, 1-based' }
    },
    {
      name: 'onPageChange',
      type: '(page: number) => void',
      description: { ko: '페이지가 바뀔 때', en: 'Fires when the page changes' }
    },
    {
      name: 'pageSize / defaultPageSize',
      type: 'number',
      default: '25',
      description: { ko: '한 페이지의 행 수', en: 'How many rows a page holds' }
    },
    {
      name: 'onPageSizeChange',
      type: '(pageSize: number) => void',
      description: { ko: '페이지 크기가 바뀔 때', en: 'Fires when the page size changes' }
    },
    {
      name: 'pageSizeOptions',
      type: 'readonly number[]',
      default: '[10, 25, 50, 100]',
      description: {
        ko: '푸터의 Select가 제시할 값. 빈 배열이면 그 컨트롤이 사라집니다',
        en: "What the footer's page-size Select offers. An empty list drops the control"
      }
    },
    {
      name: 'footer',
      type: 'boolean',
      default: "paging === 'pages'",
      description: {
        ko: '행 수·선택 개수·페이지를 담은 아래쪽 바',
        en: 'The bar under the table: how many rows there are, how many are chosen, and the pages'
      }
    },
    {
      name: 'search / defaultSearch',
      type: 'string',
      description: {
        ko: 'searchable한 모든 열과 대조할 질의',
        en: 'The query every searchable column is matched against'
      }
    },
    {
      name: 'onSearchChange',
      type: '(search: string) => void',
      description: { ko: '질의가 바뀔 때', en: 'Fires when the query changes' }
    },
    {
      name: 'searchable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '표 위에 검색 필드를 그립니다',
        en: 'Draws the search field above the table'
      }
    },
    {
      name: 'searchPlaceholder',
      type: 'string',
      description: {
        ko: '검색 필드의 placeholder이자 접근성 이름',
        en: "The field's placeholder and its accessible name"
      }
    },
    {
      name: 'filter',
      type: '(row, index) => boolean',
      description: {
        ko: '검색 다음에 적용되는 직접 만든 필터. false를 돌려주면 그 행이 빠집니다',
        en: 'A filter of your own, applied after the search. Return false to drop a row'
      }
    },
    {
      name: 'toolbar',
      type: 'ReactNode',
      description: {
        ko: '검색 필드가 있는 바의 끝에 놓일 내용',
        en: 'Content at the end of the bar the search field sits in'
      }
    },
    {
      name: 'manual',
      type: "boolean | ('sort' | 'filter' | 'pages')[]",
      default: 'false',
      description: {
        ko: '이미 caller가 끝낸 단계. true는 셋 다입니다',
        en: 'Which stages the caller has already done. true is all three'
      }
    },
    {
      name: 'rowCount',
      type: 'number',
      description: {
        ko: '표가 페이징을 하지 않을 때의 전체 행 수',
        en: 'How many rows there are in total, when the table is not doing the paging'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '표가 스스로 말하는 문구의 언어. 기본 정렬이 문자열을 비교할 때 쓰는 locale이기도 합니다',
        en: "The language the table's own words are in, and what the default sort compares strings with"
      }
    }
  ],

  DataTableColumn: [
    {
      name: 'key',
      type: 'string',
      required: true,
      description: {
        ko: '열의 식별자. value나 render가 없으면 행에서 읽을 속성 이름이기도 합니다',
        en: 'Identifies the column, and unless value or render says otherwise, names the property to read off each row'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      default: 'key',
      description: { ko: '머리글', en: 'The heading' }
    },
    {
      name: 'group',
      type: 'string',
      description: {
        ko: '이웃한 열들이 같은 문자열을 가지면 두 번째 머리행에서 하나로 합쳐집니다',
        en: 'Adjacent columns carrying the same string are drawn under one merged cell in a second header row'
      }
    },
    {
      name: 'width',
      type: 'number',
      description: {
        ko: '너비(px). 지정하지 않은 열들이 남은 폭을 나눠 갖습니다',
        en: 'How wide, in pixels. Columns that do not say share whatever is left'
      }
    },
    {
      name: 'minWidth',
      type: 'number',
      default: '48',
      description: { ko: '드래그로 줄일 수 있는 하한', en: 'How narrow a drag may make it' }
    },
    {
      name: 'align / headerAlign',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      description: {
        ko: '셀과 머리글이 붙는 쪽. 숫자는 보통 end',
        en: 'Which edge the cells and the heading line up against. Numbers usually want end'
      }
    },
    {
      name: 'sortable / resizable',
      type: 'boolean',
      default: '표의 값',
      description: {
        ko: '표의 sortable·resizable을 이 열에서만 뒤집습니다',
        en: "Overrides the table's own sortable and resizable for this column"
      }
    },
    {
      name: 'searchable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '검색이 이 열을 들여다볼지',
        en: 'Whether the search looks in this column'
      }
    },
    {
      name: 'hidden',
      type: 'boolean',
      description: {
        ko: '목록에서 지우지 않고 열만 빼 둡니다',
        en: 'Leaves the column out without removing it from the list'
      }
    },
    {
      name: 'value',
      type: '(row) => unknown',
      default: 'row[key]',
      description: {
        ko: '셀 뒤의 값 — 정렬되고 검색되는 것',
        en: 'The value behind the cell: what is sorted, and what the search is matched against'
      }
    },
    {
      name: 'compare',
      type: '(a, b) => number',
      description: {
        ko: '기본 비교로는 순서를 매길 수 없는 값을 위한 비교 함수. 항상 오름차순으로 쓰고 표가 뒤집습니다',
        en: 'Orders two rows by this column when the default comparison cannot. Always written ascending; the table reverses it'
      }
    },
    {
      name: 'render',
      type: '(row, index) => ReactNode',
      description: {
        ko: '셀을 직접 그립니다. index는 정렬·필터된 순서에서의 자리이며 페이지를 가로질러 셉니다',
        en: "Draws the cell. index is the row's place in the sorted, filtered order, counted across every page"
      }
    }
  ],

  Alert: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 닫기 버튼의 접근성 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag naming the dismiss button in that language'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      color: "'info'",
      colorDescription: {
        ko: '심각도. 표면과 글리프를 함께 정합니다. 기본값이 primary가 아닌 info인 이유는, 심각도를 말하지 않은 알림은 정보 알림이기 때문입니다',
        en: 'The severity: it picks the surface and the glyph together. The default is info rather than primary — an alert with no severity named is an informational one'
      },
      variantDescription: {
        ko: '표면의 무게. 알림은 색이 입혀지는 대상이므로 시트가 실제로 물듭니다. text는 폼 안에 놓을 때',
        en: 'Weight of the surface. An alert *is* the thing being coloured, so the sheet takes the tint. Reach for text inside a form'
      },
      elevationDescription: {
        ko: '그림자 깊이. 알림은 페이지 흐름 안에 있습니다 — 떠 있는 쪽은 Toast입니다',
        en: 'Drop shadow depth. An alert sits in the flow of the page; the one that floats is a Toast'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목 줄. 있으면 제목+설명 두 단짜리가 되고, 없으면 전체가 한 줄입니다',
        en: 'The heading line. With it the alert is two-part; without it the whole thing is one line'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞머리 글리프. 기본값은 color에 딸린 그림, false면 생략. 색만으로 심각도를 말하지 않기 위해 계열마다 모양이 다릅니다',
        en: 'The glyph at the start. Defaults to the one that goes with `color`; `false` drops it. The shapes differ per family so severity is not carried by colour alone'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 내용 — 재시도 버튼, 링크. 본문이 줄바꿈되어도 첫 줄에 남습니다',
        en: 'Content pinned to the end of the row. Stays on the first line while the message wraps'
      }
    },
    {
      name: 'onClose',
      type: '(event) => void',
      description: {
        ko: '넘기면 닫기 버튼이 생깁니다',
        en: 'Passing it is what makes the dismiss button appear'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '닫기 버튼의 접근성 이름', en: 'Accessible name of the dismiss button' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메시지', en: 'The message' }
    },
    transitionProp('transition="slide"')
  ],

  Dialog: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. ×의 접근성 이름을 이 언어로 씁니다. 지원하지 않는 태그는 영어로',
        en: 'BCP 47 tag naming the × in that language. Unsupported tags fall back to English'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백, 그리고 시트가 넓어질 수 있는 한계까지 함께 정합니다. maxWidth라는 두 번째 축을 만들지 않은 이유입니다',
        en: 'The type scale, the padding, and how wide the sheet may get. One axis rather than a second scale spelled maxWidth'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 시트는 물들지 않으므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed, so it reaches the edge and the focus ring'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께 쓰면 제어 컴포넌트가 됩니다',
        en: 'Whether it is shown. With onOpenChange, a controlled dialog'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비제어 다이얼로그의 초기 상태',
        en: 'The initial state of an uncontrolled dialog'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '다이얼로그를 여는 요소. Base UI가 연결합니다. 선택 사항 — 다른 곳에서 여는 제어 다이얼로그에는 필요 없습니다',
        en: 'The element that opens it, wired up by Base UI. Optional — a controlled dialog opened elsewhere needs none'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. 다이얼로그의 이름이 되는 h2로 렌더링됩니다',
        en: 'The heading. Rendered as the h2 that names the dialog'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 다이얼로그의 접근성 설명',
        en: "A line under the title, and the dialog's accessible description"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '아래쪽 버튼 줄. 끝 정렬됩니다. DialogClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, end-aligned. DialogClose is what makes one of them dismiss'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '구역 사이를 여백 대신 하이라인으로 나눕니다. 본문이 스크롤되는 순간부터 켜는 편이 좋습니다',
        en: 'Separates the sections with hairlines instead of space. Worth turning on the moment the body scrolls'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '모서리의 ×. 라이브러리의 다른 불리언과 달리 기본이 켜짐입니다 — 모달은 답할 때까지 페이지를 가져가므로 나가는 길이 보여야 합니다',
        en: 'The × in the corner. On by default, unlike most booleans here: a modal takes the page away, and the way out should be visible'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정한 최대 너비를 대신할 값. 숫자는 픽셀입니다',
        en: 'A hard cap overriding the one size implies. Numbers are pixels'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'size가 허용하는 너비를 가득 채웁니다. 다른 컴포넌트와 반대로 기본이 켜짐입니다 — 다이얼로그의 컨테이너는 뷰포트입니다',
        en: 'Takes the full width its size allows. On by default, the other way round from everywhere else: a dialog’s container is the viewport'
      }
    },
    {
      name: 'fullScreen',
      type: 'boolean',
      default: 'false',
      description: { ko: '뷰포트를 가장자리까지 채웁니다', en: 'Fills the viewport edge to edge' }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 가져갈지. trap-focus는 스크롤과 클릭은 남기고 포커스만 가둡니다',
        en: "Whether the page behind is taken away. 'trap-focus' keeps it scrollable and clickable while holding focus inside"
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Esc와 바깥 클릭으로 닫히는지. 끄려면 답할 수 있는 actions를 반드시 함께 주세요',
        en: 'Whether Escape and an outside click close it. Turn it off only with actions that answer it'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '본문. 스크롤되는 유일한 구역입니다',
        en: 'The body — the only part that scrolls'
      }
    }
  ],

  ToastProvider: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 모든 toast의 × 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag naming the × on every toast in that language'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'outline'",
      shared: true,
      description: {
        ko: '표면의 무게. 토스트 하나가 따로 덮어쓸 수 있습니다',
        en: 'Weight of the surface. A single toast can override it'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '타입 스케일과 여백', en: 'Type scale and padding' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '기본 색 계열', en: 'The default colour family' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'position',
      type: '`top-${Align}` | `bottom-${Align}`',
      default: "'bottom-end'",
      description: {
        ko: '스택이 놓이는 자리. 위·아래 두 값과 공용 Align의 조합입니다 — 화면 한복판을 세로로 가르는 스택은 만들 수 없습니다',
        en: 'Where the stack is pinned: top or bottom, times the shared Align. There is deliberately no way to ask for a column down the middle'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      default: '5000',
      description: {
        ko: '기본 유지 시간(ms). 0이면 닫을 때까지 남습니다',
        en: 'How long a toast lasts by default, in ms. 0 keeps it up until it is closed'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '3',
      description: {
        ko: '동시에 보이는 개수. 넘친 것은 버려지지 않고 스택이 빠지면 나타납니다',
        en: 'How many are shown at once. The rest are kept and revealed as the stack drains'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      default: '380',
      description: { ko: '토스트 하나의 최대 너비', en: 'How wide a toast is allowed to get' }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '× 버튼의 접근성 이름', en: "Accessible name of every toast's × button" }
    }
  ],

  'useToast().add': [
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '제목', en: 'The headline' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '아래 설명. 이것만 있으면 한 줄짜리 토스트입니다',
        en: 'The detail under it. A toast with only this is a one-line toast'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 토스트만 다른 색 계열로',
        en: 'Overrides the provider for this toast alone'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      shared: true,
      description: {
        ko: '이 토스트만 다른 표면으로',
        en: 'Overrides the provider for this toast alone'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞머리 글리프. 기본값은 color에 딸린 그림',
        en: 'The glyph. Defaults to the one that goes with `color`'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      description: {
        ko: '이 토스트의 유지 시간(ms). 0은 읽고 나서 조치가 필요한 메시지에 씁니다',
        en: 'How long this one lasts, in ms. 0 is the right answer for anything the reader has to act on'
      }
    },
    {
      name: 'priority',
      type: "'low' | 'high'",
      default: "'low'",
      description: {
        ko: 'high는 스크린 리더의 말을 끊습니다. 오류는 그럴 만하고 저장 완료는 아닙니다',
        en: 'high interrupts a screen reader. An error is worth interrupting for and a save is not'
      }
    },
    {
      name: 'actionLabel',
      type: 'ReactNode',
      description: {
        ko: '액션 버튼의 라벨. 넘기면 버튼이 생깁니다',
        en: 'The label of the action button. Passing it is what makes it appear'
      }
    },
    {
      name: 'onAction',
      type: '(event) => void',
      description: { ko: '액션 버튼을 눌렀을 때', en: 'Called when the action is pressed' }
    },
    {
      name: 'id',
      type: 'string',
      description: {
        ko: '같은 id로 다시 부르면 그 토스트를 제자리에서 갱신하고 타이머를 다시 시작합니다',
        en: 'Reusing an id updates that toast in place and restarts its timer'
      }
    },
    {
      name: 'onClose',
      type: '() => void',
      description: {
        ko: '어떤 방식으로든 닫혔을 때',
        en: 'Called when it closes, however it closed'
      }
    },
    {
      name: 'onRemove',
      type: '() => void',
      description: {
        ko: '애니메이션이 끝나고 DOM에서 빠졌을 때',
        en: 'Called once it has left the DOM'
      }
    }
  ],

  Tooltip: [
    {
      name: 'content',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '툴팁이 하는 말. 짧은 구절이어야 합니다 — 툴팁은 터치로 닿을 수 없고 안의 무엇도 누를 수 없습니다',
        en: 'What it says. A short phrase: a tooltip cannot be reached by touch and nothing inside it can be clicked'
      }
    },
    {
      name: 'children',
      type: 'ReactElement',
      required: true,
      description: {
        ko: '툴팁이 매달릴 요소 하나. 트리거가 감싸지 않고 이 요소에 병합되므로 레이아웃에 요소가 늘지 않습니다',
        en: 'The single element it hangs off. The trigger merges onto it rather than wrapping it, so the layout gains no element'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'sm'",
      shared: true,
      description: { ko: '판의 타입 스케일과 여백', en: "The plate's type scale and padding" }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '색 계열. 툴팁은 언제나 다른 것에 대한 주석이므로 중립이 기본입니다',
        en: 'Colour family. A tooltip is always a note about something else, so the neutral family is the honest default'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'top'",
      description: {
        ko: '트리거의 어느 쪽에 뜨는지. 자리가 없으면 반대쪽으로 넘어갑니다',
        en: 'Which edge of the trigger it appears on. Flips to the opposite side when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: { ko: '그 변을 따라 놓이는 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'delay',
      type: 'number',
      default: '600',
      description: {
        ko: '열리기까지 포인터가 머물러야 하는 시간(ms)',
        en: 'How long the pointer has to rest before it opens, in ms'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      default: '0',
      description: {
        ko: '포인터가 떠난 뒤 닫히기까지(ms)',
        en: 'How long it waits before closing, in ms'
      }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '트리거를 가리키는 작은 쐐기',
        en: 'The little wedge pointing at the trigger'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께',
        en: 'Whether it is open. With onOpenChange'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비제어 툴팁의 초기 상태',
        en: 'The initial state of an uncontrolled tooltip'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거는 그대로 두고 툴팁만 열리지 않게 합니다 — 라벨이 잘렸을 때만 뜨는 툴팁 같은 경우',
        en: 'Stops it opening without disabling the trigger — for the tooltip that only exists while a label is truncated'
      }
    }
  ],

  ProgressLinear: progressProps({
    ko: '홈의 두께. 막대에서 크기를 가지는 것은 이것뿐입니다',
    en: 'Thickness of the groove. Nothing else on a bar has a size'
  }),

  ProgressCircular: progressProps({
    ko: '고리의 지름. 매 단계에서 컨트롤 사다리 바로 아래에 놓이므로, 버튼이나 필드 안에 넣어도 행이 높아지지 않습니다',
    en: 'Diameter of the ring. It lands just under the control ladder at every step, so dropping one into a button or a field never makes the row taller'
  }),

  ProgressBox: [
    ...progressProps({
      ko: '판 하나의 크기',
      en: 'The size of one plate'
    }),
    {
      name: 'count',
      type: 'number',
      default: '4',
      description: {
        ko: '판의 개수. 넷이면 파도가 파도로 읽히면서도 한눈에 셀 수 있습니다. 기다리는 대상에 실제로 단계가 있다면 그 수를 넣으세요',
        en: 'How many plates. Four reads as a wave and can still be counted at a glance. Set it to the number of steps when the thing being waited on genuinely has steps'
      }
    }
  ],

  List: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 담는 쪽이므로 시트는 물들지 않습니다. Card 안에서는 text를 쓰세요 — 카드가 이미 시트입니다',
        en: 'Weight of the surface. The sheet is never dyed, as on Box. Reach for text inside a Card — the card is already a sheet'
      },
      sizeDescription: {
        ko: '행의 타입 스케일과 여백. 항목이 아니라 목록이 가지는 축입니다',
        en: "The rows' type scale and padding. An axis of the list, not of any one row"
      }
    }),
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '행 사이를 여백 대신 하이라인으로 나눕니다. 들리는 것보다 많이 바뀝니다 — 선이 시트 양끝까지 닿아야 하므로 목록은 안쪽 여백을, 행은 둥근 모서리를 내놓습니다',
        en: 'Separates the rows with a hairline instead of space. It changes more than it sounds like: the rules have to reach both edges, so the list gives up its inner padding and the rows give up their corners'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'ul 대신 다른 것으로 — 순서가 의미를 가지면 render={<ol />}',
        en: 'Renders something other than a ul — render={<ol />} when the order is the point'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'ListItem들', en: 'The ListItems' }
    }
  ],

  ListItem: [
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞 내용 — 아이콘, 아바타, 상태 점',
        en: 'Content before the label — an icon, an avatar, a status dot'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤 내용. 누를 수 있는 영역 안에 있습니다',
        en: 'Content after the label, inside the pressable area'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 둘째 줄', en: 'A second line under the label' }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 컨트롤 — 스위치, 메뉴 버튼. 일부러 누를 수 있는 영역 바깥입니다: 버튼 안의 버튼은 브라우저가 파싱하면서 고쳐 쓰는 마크업입니다',
        en: 'A control pinned to the end of the row. Deliberately outside the pressable area — a button inside a button is markup the browser rewrites on parse'
      }
    },
    {
      name: 'onClick',
      type: '(event) => void',
      description: {
        ko: '넘기면 행이 진짜 button이 됩니다',
        en: 'Passing it is what turns the row into a real button'
      }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '넘기면 행이 진짜 a가 됩니다',
        en: 'Passing it is what turns the row into a real link'
      }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '고른 행 — 열려 있는 페이지, 켜진 필터. 링크에는 aria-current="page"가, 버튼에는 aria-current="true"가 붙습니다',
        en: 'The chosen row — the open page, the current filter. A link gets aria-current="page" and a button aria-current="true"'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
        en: 'Unavailable. Drops the colour family for neutral grey'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  Typography: [
    {
      name: 'level',
      type: "'h1'…'h6' | 'lead' | 'body' | 'caption' | 'overline'",
      default: "'body'",
      description: {
        ko: '타입 스케일과 렌더링할 요소를 함께 정합니다. variant라고 부르지 않는 이유는 이 라이브러리에서 variant가 이미 표면의 무게를 뜻하기 때문입니다',
        en: 'The type scale, and the element that carries it. Not called `variant` — that word already means the weight of a surface here'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 다른 컴포넌트와 달리 기본값이 없습니다 — 지정하지 않으면 페이지의 글자색을 그대로 씁니다',
        en: 'Semantic colour role. Unlike every other component this has no default: unset means the page’s own colour'
      }
    },
    {
      name: 'weight',
      type: "'regular' | 'medium' | 'semibold' | 'bold'",
      description: {
        ko: 'level이 정한 굵기를 덮어씁니다',
        en: 'Overrides the weight the level would pick'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end' | 'justify'",
      description: { ko: '텍스트 정렬', en: 'Text alignment' }
    },
    {
      name: 'lines',
      type: 'number',
      description: {
        ko: '이 줄 수로 자르고 말줄임표를 붙입니다. 1이면 한 줄 자르기',
        en: 'Clamps to this many lines with an ellipsis. 1 is a single-line truncation'
      }
    },
    {
      name: 'gutter',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '아래 여백을 붙입니다. 기본이 꺼짐인 이유는 여백을 스스로 만드는 컴포넌트는 레이아웃이 싸워야 할 대상이기 때문입니다',
        en: 'Adds the space below. Off by default: a component that injects margins is one a layout has to fight'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: '타입 스케일은 그대로 두고 요소만 바꿉니다. Base UI의 render prop 그대로',
        en: "Changes the element without changing the type scale. Base UI's own escape hatch"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '텍스트', en: 'The text' }
    },
    transitionProp('transition="fade"')
  ],

  Avatar: [
    {
      name: 'src',
      type: 'string',
      description: {
        ko: '그림. 로딩되기 전까지, 그리고 실패하면 계속 fallback이 그려집니다',
        en: 'The picture. Until it loads — and forever, if it fails — the fallback is what is drawn'
      }
    },
    {
      name: 'srcSet',
      type: 'string',
      description: {
        ko: '다른 해상도의 후보 이미지. img의 srcSet 그대로',
        en: 'Candidate images at other resolutions, as on any img'
      }
    },
    {
      name: 'alt',
      type: 'string',
      default: 'name',
      description: {
        ko: '그림의 대체 텍스트. 이름 옆에 놓인 아바타는 장식이므로 name도 없으면 빈 문자열이 됩니다',
        en: "The picture's alt text. Falls back to name, and to an empty string when there is neither"
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '누구 또는 무엇인지. 그림의 이름이 되고, initials가 여기서 파생되며, screen reader는 이 문장을 대신 읽습니다',
        en: 'Who or what this is. It names the picture, the initials are derived from it, and a screen reader hears it instead of them'
      }
    },
    {
      name: 'initials',
      type: 'string',
      description: {
        ko: '이니셜을 직접 씁니다. 첫 단어와 마지막 단어의 첫 글자라는 규칙이 맞지 않는 이름일 때',
        en: 'The initials, written out, for when the first-and-last-word rule derives the wrong ones'
      }
    },
    {
      name: 'shape',
      type: "'circle' | 'square'",
      default: "'circle'",
      description: {
        ko: '크롭 모양. square는 모서리를 상자의 약 28%만큼 잘라 냅니다',
        en: 'The crop. square cuts the corners off instead, at roughly 28% of the box'
      }
    },
    ...sharedProps({
      variant: "'text'",
      size: "'md'",
      variantDescription: {
        ko: 'fallback 뒤 표면의 무게. 그림이 로딩되면 가장자리만 남고 보이지 않습니다',
        en: 'Weight of the surface behind the fallback. Invisible once a picture has loaded, apart from the edge it keeps'
      },
      sizeDescription: {
        ko: '그림이 그려지는 상자. 컨트롤 높이 사다리라서 옆에 놓인 Button과 높이가 맞습니다',
        en: 'The box the picture is drawn in — the control heights, so an avatar and the button beside it are the same height'
      }
    }).filter((row) => row.name !== 'density'),
    {
      name: 'delay',
      type: 'number',
      description: {
        ko: 'fallback을 그리기까지 기다리는 시간(ms). 캐시된 그림 앞에서 이니셜이 번쩍이는 것을 막습니다',
        en: 'How long to wait before drawing the fallback, in milliseconds. Stops the initials flashing up in front of a cached picture'
      }
    },
    {
      name: 'imageProps',
      type: "Omit<ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>",
      description: {
        ko: 'img에 필요한 나머지 속성 — loading, crossOrigin, referrerPolicy',
        en: 'Anything else the img needs — loading, crossOrigin, referrerPolicy'
      }
    },
    {
      name: 'onLoadingStatusChange',
      type: "(status: 'idle' | 'loading' | 'loaded' | 'error') => void",
      description: {
        ko: '그림의 로딩 상태가 바뀔 때 호출됩니다',
        en: 'Called as the picture moves between its four loading states'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '이니셜 대신 그릴 fallback. 아이콘, 로고, 이모지 하나',
        en: 'The fallback, drawn instead of the initials. An icon, a logo, a single emoji'
      }
    },
    transitionProp('transition="fade"')
  ],

  Badge: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      sizeDescription: {
        ko: '표식의 크기. 컨트롤 사다리와 별개입니다 — 배지는 무언가의 모서리에 걸리는 것이라 줄을 맞출 상대가 없습니다',
        en: 'The size of the mark, on a ladder of its own: a badge hangs off a corner, so it lines up with nothing'
      },
      densityDescription: {
        ko: '숫자 좌우의 여백만 바꿉니다',
        en: 'The room around the digits, and nothing else'
      }
    }),
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '표식이 말하는 것. 보통 숫자, 가끔 단어. 없으면 점이 됩니다',
        en: 'What the badge says — usually a count. Omit it and the badge draws a dot'
      }
    },
    {
      name: 'max',
      type: 'number',
      default: '99',
      description: {
        ko: '숫자 content의 상한. 넘으면 99+가 됩니다. 단어는 자르지 않습니다',
        en: 'Caps a numeric content and adds a plus. Text is never truncated'
      }
    },
    {
      name: 'dot',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'content가 있어도 점으로 그립니다. 숫자는 스크린 리더에만 남습니다',
        en: 'Draws a dot even with content, keeping the count for screen readers only'
      }
    },
    {
      name: 'showZero',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '0도 보여 줍니다. 기본이 꺼짐인 이유는 읽지 않은 메시지 0개는 소식이 아니기 때문입니다',
        en: 'Shows a count of zero. Off by default — zero unread messages is not news'
      }
    },
    {
      name: 'invisible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '자리는 지킨 채 숨깁니다. 다시 나타나도 주변이 움직이지 않습니다',
        en: 'Hides the marker without giving up its box, so nothing moves when it returns'
      }
    },
    {
      name: 'placement',
      type: "'top-start' | 'top-end' | 'bottom-start' | 'bottom-end'",
      default: "'top-end'",
      shared: true,
      description: {
        ko: '어느 모서리에 붙을지. start/end라서 쓰기 방향을 따라 뒤집힙니다',
        en: 'Which corner it sits on. start/end, so the corner flips with the writing direction'
      }
    },
    {
      name: 'overlap',
      type: "'square' | 'circle'",
      default: "'square'",
      description: {
        ko: '아래에 있는 것의 모양. 원의 모서리는 사각형보다 중심에서 멀기 때문에 파고드는 깊이가 다릅니다',
        en: "The shape underneath, which decides how far the mark tucks in — a circle's corner is further out than a square's"
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크린 리더가 숫자 대신 읽을 문장. 종 옆의 "3"은 아무 뜻도 없습니다',
        en: 'What a screen reader hears instead of the raw count — "3" beside a bell means nothing'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '표식이 붙을 대상. 없으면 인라인으로 놓이는 독립 표식이 됩니다',
        en: 'What the badge is pinned to. Without it, the badge is a standalone marker that lays out inline'
      }
    }
  ],

  Menu: [
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '메뉴를 여는 요소. Base UI가 연결해 줍니다. 다른 곳에서 여는 controlled 메뉴에는 필요 없습니다',
        en: 'The element that opens the menu, wired up by Base UI. Not needed for a controlled menu opened elsewhere'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. controlled 메뉴',
        en: 'Whether it is open, for a controlled menu'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 열려 있음', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when it opens or closes' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: {
        ko: '트리거의 어느 변에 걸릴지. 자리가 없으면 반대편으로 뒤집힙니다',
        en: 'Which edge of the trigger it hangs off. Flips when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: { ko: '그 변 위에서의 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'modal',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '열려 있는 동안 뒤 페이지를 가져갈지',
        en: 'Whether the page behind is taken away while it is open'
      }
    },
    {
      name: 'openOnHover',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '호버로도 열립니다. 메뉴바처럼 열린 채로 옆 메뉴로 건너가야 할 때',
        en: 'Opens on hover too. For a menu bar, where crossing the row should walk through the others'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 항목에서 화살표를 누르면 처음으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last row back to the first'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 트리거가 아무것도 열지 않습니다',
        en: 'Unavailable. The trigger stops opening anything'
      }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '행의 여백만 바꿉니다. 메뉴는 자기 팝업 폭을 스스로 정하므로 Box보다 좁은 사다리를 씁니다',
        en: 'The rows’ padding only. A menu is as wide as its longest label, so it runs a tighter ladder than Box'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '행들. MenuItem, MenuGroup, MenuSeparator, MenuSubmenu 등',
        en: 'The rows — MenuItem, MenuGroup, MenuSeparator, MenuSubmenu and the rest'
      }
    }
  ],

  MenuItem: [
    {
      name: 'onClick',
      type: '(event) => void',
      description: { ko: '행이 하는 일', en: 'What the row does' }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '넘기면 진짜 a가 됩니다. 링크로 이뤄진 메뉴는 링크여야 새 탭으로 열 수 있습니다',
        en: 'Passing it renders a real anchor. A menu of links has to be links, or none of them opens in a new tab'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, shortcut 앞의 내용',
        en: 'Content after the label, before any shortcut'
      }
    },
    {
      name: 'shortcut',
      type: 'ReactNode',
      description: {
        ko: '같은 일을 하는 단축키. 행 끝에 흐리게 놓입니다 — 표시만 하고 바인딩하지는 않습니다',
        en: 'The keystroke that does the same thing, set muted at the end. Shown, never bound'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 한 줄', en: 'A second line under the label' }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 행만 다른 색 계열로. 지우는 행에 danger. 기본값은 메뉴의 색입니다',
        en: "Re-points this row's colour family — danger for the one that deletes. Defaults to the menu's own"
      }
    },
    {
      name: 'closeOnClick',
      type: 'boolean',
      default: 'true',
      description: { ko: '고르면 메뉴가 닫힐지', en: 'Whether picking the row closes the menu' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 목록에는 남고 타이핑 검색에도 걸립니다',
        en: 'Unavailable. Still listed, and still found by typeahead'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '타이핑 검색이 맞춰 볼 문자열. 라벨이 평범한 문자열이 아닐 때',
        en: 'What typeahead matches against, when the label is not a plain string'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  MenuSubmenu: [
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '서브메뉴를 여는 행의 라벨', en: 'The label on the row that opens it' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'right'",
      shared: true,
      description: {
        ko: '부모 행의 어느 쪽으로 열릴지',
        en: 'Which edge of the parent row it opens against'
      }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '4',
      description: { ko: '부모 메뉴와의 거리(px)', en: 'Distance from the parent menu, in pixels' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '중첩된 행들. 그 안에 또 MenuSubmenu를 넣을 수 있고, 깊이 제한은 없습니다',
        en: 'The nested rows — one of which may be another MenuSubmenu, to any depth'
      }
    }
  ],

  ContextMenu: [
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '행들. Menu 안에 쓰는 것과 똑같이 씁니다',
        en: 'The rows, written exactly as they are inside a Menu'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '오른쪽 클릭이나 길게 누르기에 반응할 영역',
        en: 'The area that answers a right-click or a long press'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: { ko: '열림 여부', en: 'Whether it is open' }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 열려 있음', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when it opens or closes' }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '행의 여백만 바꿉니다', en: 'The rows’ padding only' }
    }
  ],

  Accordion: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '시트의 반경과 각 섹션의 여백. Box와 같은 뜻입니다',
        en: "The sheet's radius and each section's padding — the same thing size means on Box"
      }
    }),
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '여러 섹션을 동시에 열 수 있는지. 기본이 꺼짐인 이유는 하나를 열 때 하나를 닫는 것이 아코디언이 접이식 목록과 다른 점 전부이기 때문입니다',
        en: 'Whether more than one section may be open. Off by default: closing the last as you open the next is the whole difference between an accordion and a stack of collapsibles'
      }
    },
    {
      name: 'value',
      type: '(string | number)[]',
      description: {
        ko: '열려 있는 섹션들. controlled',
        en: 'Which sections are open, for a controlled accordion'
      }
    },
    {
      name: 'defaultValue',
      type: '(string | number)[]',
      description: { ko: '처음 열려 있는 섹션들', en: 'Which start open' }
    },
    {
      name: 'onValueChange',
      type: '(value: (string | number)[]) => void',
      description: { ko: '열린 집합이 바뀔 때', en: 'Called when the open set changes' }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '섹션 사이를 여백 대신 실선으로 나눕니다. List와 기본값이 반대인 이유는 접히는 카드 더미가 아니라 한 덩어리로 읽혀야 하기 때문입니다',
        en: 'Separates the sections with a hairline rather than space. The opposite default from List: an accordion of tiles is a stack of cards, not one thing'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 모든 섹션이 접히지 않습니다',
        en: 'Unavailable. Every section stops answering'
      }
    },
    {
      name: 'hiddenUntilFound',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남겨 브라우저의 페이지 검색이 찾아 펼칠 수 있게 합니다. keepMounted보다 우선합니다',
        en: "Keeps closed panels in the DOM so the browser's own page search can find and open them. Overrides keepMounted"
      }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남깁니다. 만들기 비싼 내용이나 접혀도 살아 있어야 하는 폼 상태',
        en: 'Keeps closed panels in the DOM. For content that is expensive to build, or form state that should survive being folded away'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'AccordionItem들', en: 'The AccordionItems' }
    }
  ],

  AccordionItem: [
    {
      name: 'value',
      type: 'string | number',
      description: {
        ko: 'value / defaultValue가 가리키는 식별자. 생략하면 Base UI가 만들어 줍니다',
        en: 'Identifies the section to value / defaultValue. Base UI generates one when it is left out'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '접히는 부분의 제목', en: 'The heading on the fold' }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: { ko: '제목 아래 한 줄', en: 'A second line under the title' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '제목 앞의 내용', en: 'Content before the title' }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '헤더 끝에 고정되는 컨트롤. 접는 버튼 바깥에 놓입니다 — 버튼 안의 버튼은 브라우저가 고쳐 씁니다',
        en: 'A control pinned to the end of the header, outside the folding button — a button inside a button is markup the browser rewrites'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이 섹션만 접히지 않습니다. 나머지는 그대로 동작합니다',
        en: 'This section stops folding; the rest keep working'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '펼쳤을 때의 내용', en: 'The body' }
    }
  ],

  Tabs: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '패널이 아니라 탭 **바**의 무게. solid는 분절 컨트롤(홈통 안의 타일), outline은 바 가장자리의 선, text는 그 선을 뺀 것',
        en: 'Weight of the tab **bar**, not of the panels. solid is a segmented control, outline is a rule along the bar, text is the same without it'
      },
      sizeDescription: {
        ko: '탭의 높이와 타입 스케일. Button과 같은 사다리라 툴바에 섞어 놓아도 기준선이 맞습니다',
        en: "The tabs' height and type scale, on Button's own ladder — so a tab bar keeps its baseline in a toolbar"
      }
    }).filter((row) => row.name !== 'elevation'),
    {
      name: 'value',
      type: 'string | number | null',
      description: { ko: '선택된 탭. controlled', en: 'The chosen tab, for a controlled set' }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: '처음 선택된 탭', en: 'Which starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen tab changes' }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '바가 흐르는 방향. vertical이면 탭이 옆으로 서고 화살표 키도 그 축으로 옮겨 갑니다',
        en: 'Which way the bar runs. vertical stands the tabs down the side and moves the arrow keys onto the other axis'
      }
    },
    {
      name: 'activateOnFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '화살표로 지나가기만 해도 선택할지. 기본이 꺼짐인 이유는 패널 하나가 데이터를 받아 온다면 탭 넷을 지나가는 것이 요청 네 번이기 때문입니다',
        en: 'Whether the arrow keys also choose. Off by default: the moment one panel fetches, walking past four tabs fires four requests'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 탭에서 화살표를 누르면 처음으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last tab back to the first'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '탭들이 바의 폭을 똑같이 나눠 갖습니다',
        en: 'The tabs share the full width of the bar, each taking an equal part'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Tab과 TabPanel. 둘은 알아서 나뉘어 각자의 자리에 놓이므로 감싸는 래퍼를 쓸 필요가 없습니다',
        en: 'The Tabs and the TabPanels. They are sorted into their two boxes for you, so there is no list wrapper to remember'
      }
    }
  ],

  Tab: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '탭의 식별자. 같은 값을 가진 TabPanel을 가리킵니다',
        en: 'Identifies the tab, and picks out the panel with the same value'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤의 내용 — 개수, Badge, 상태 점',
        en: 'Content after the label — a count, a Badge, a status dot'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가. 목록에는 남습니다', en: 'Unavailable, but still listed' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '탭의 라벨', en: "The tab's label" }
    }
  ],

  TabPanel: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: { ko: '어느 탭이 이 패널을 보여 줄지', en: 'Which tab shows this panel' }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '숨겨진 동안에도 DOM에 남깁니다. 만들기 비싼 내용이나 살아 있어야 하는 폼 상태',
        en: 'Keeps the panel in the DOM while hidden. For content that is expensive to build, or form state that should survive'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '패널의 내용', en: 'The content' }
    }
  ],

  FilePicker: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 셋 다 점선 테두리는 공유합니다 — 라이브러리에서 실선이 아닌 선을 긋는 유일한 곳이고, 장식이 아니라 "여기에 놓을 수 있다"는 관례이기 때문입니다',
        en: 'Weight of the surface. All three share the dashed edge — the one place the library draws a line that is not solid, because a dashed rectangle is the established sign for a drop target'
      },
      sizeDescription: {
        ko: '상자의 여백과 글자 크기. 상자는 안에 쓰인 글이 아니라 받아 내야 할 제스처에 맞춰 커집니다',
        en: "The box's padding and type scale. A dropzone is sized by the gesture it has to catch, not by what is written in it"
      }
    }),
    {
      name: 'accept',
      type: 'string',
      description: {
        ko: "브라우저 파일 창이 보여 줄 종류 — 'image/*,.pdf'. 드롭된 파일도 같은 문자열로 검사합니다. 브라우저는 그렇게 하지 않습니다",
        en: "Which files the browser's own picker offers — 'image/*,.pdf'. Dropped files are checked against it too, which the attribute alone does not do"
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '파일을 여러 개 고를 수 있는지',
        en: 'Whether more than one file may be chosen'
      }
    },
    {
      name: 'maxSize',
      type: 'number',
      description: {
        ko: '파일 하나의 최대 크기(바이트)',
        en: 'The largest a single file may be, in bytes'
      }
    },
    {
      name: 'maxFiles',
      type: 'number',
      description: {
        ko: '한 번에 들고 있을 수 있는 개수. 한 번의 드롭이 아니라 이미 들고 있는 것과 합쳐서 셉니다',
        en: 'How many files may be held at once — counted against what is already chosen, not against one drop'
      }
    },
    {
      name: 'value',
      type: 'readonly File[]',
      description: {
        ko: '고른 파일들. controlled',
        en: 'The chosen files, for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly File[]',
      description: { ko: '처음 고른 파일들', en: 'The initially chosen files' }
    },
    {
      name: 'onFilesChange',
      type: '(files: File[]) => void',
      description: { ko: '파일 목록이 바뀔 때', en: 'Called when the list of files changes' }
    },
    {
      name: 'onReject',
      type: '(rejections: FileRejection[]) => void',
      description: {
        ko: '되돌려 보낸 파일과 그 이유. 없으면 거부된 파일이 조용히 사라지는데, 드롭존이 하는 가장 나쁜 일입니다',
        en: 'Called with everything turned away, and why. Without it a rejected file disappears silently, which is the worst thing a dropzone does'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '상자 안의 문장', en: 'The line inside the box' }
    },
    {
      name: 'hint',
      type: 'ReactNode',
      description: {
        ko: '그 아래 줄 — 무엇을, 얼마나 크게, 몇 개까지',
        en: 'The line under it — what is accepted, how big, how many'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '문장 위의 글리프. null을 주면 그림 없는 상자가 됩니다',
        en: 'The glyph above the title. Pass null for a box with no picture in it'
      }
    },
    {
      name: 'showList',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '고른 파일들을 상자 아래에 나열하고 각각 지울 방법을 붙입니다',
        en: 'Lists the chosen files under the box, each with a way to remove it'
      }
    },
    {
      name: 'removeLabel',
      type: '(name: string) => string',
      description: {
        ko: '파일 삭제 버튼의 접근성 이름',
        en: "Accessible name of a file's remove button"
      }
    },
    ...fieldProps,
    ...inertProps,
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 파일이 있어야 하는지',
        en: 'Whether a file must be chosen before the form is submitted'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    }
  ],

  Pagination: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. nav 이름, 페이지 버튼, 화살표, 현재 위치 문장을 모두 이 언어로 씁니다',
        en: 'BCP 47 tag: the nav name, the page buttons, the arrows and the status sentence'
      }
    },
    ...sharedProps({
      variant: "'text'",
      size: "'md'",
      density: "'compact'",
      variantDescription: {
        ko: '쉬고 있는 페이지 버튼의 무게. 현재 페이지는 언제나 solid입니다 — 읽지 않고도 보여야 하는 유일한 정보이고, 기본값이 text인 이유도 그것입니다. 채워진 버튼 아홉 개가 한 줄에 있으면 아홉 개 모두가 주된 액션이라는 뜻이 됩니다',
        en: 'How the pages look at rest. The current page is always solid — the one thing the row has to say without being read, which is also why the default here is text: nine filled buttons in a row say all nine are the primary action'
      },
      sizeDescription: {
        ko: '버튼의 높이와 타입 스케일. 실제로 Button이므로 옆에 놓인 같은 size의 버튼과 줄이 맞습니다',
        en: 'The buttons’ height and type scale. They are real Buttons, so a lg pagination lines up with a lg button beside it'
      }
    }),
    {
      name: 'count',
      type: 'number',
      required: true,
      description: {
        ko: '전체 페이지 수. 둘보다 적으면 아무것도 그리지 않습니다 — 할 일이 없다고 광고하는 컨트롤은 컨트롤이 아닙니다',
        en: 'How many pages there are. Fewer than two and the whole control renders nothing: a row advertising that it has nothing to do is not a control'
      }
    },
    {
      name: 'page',
      type: 'number',
      description: {
        ko: '현재 페이지(1부터). controlled',
        en: 'The current page, 1-based, for a controlled set'
      }
    },
    {
      name: 'defaultPage',
      type: 'number',
      default: '1',
      description: { ko: '처음 페이지', en: 'Which page starts current' }
    },
    {
      name: 'onPageChange',
      type: '(page: number) => void',
      description: { ko: '페이지가 바뀔 때', en: 'Called when the page changes' }
    },
    {
      name: 'siblingCount',
      type: 'number',
      default: '1',
      description: {
        ko: '현재 페이지 양옆에 언제나 보이는 페이지 수',
        en: 'How many pages are always shown on either side of the current one'
      }
    },
    {
      name: 'boundaryCount',
      type: 'number',
      default: '1',
      description: {
        ko: '양 끝에 언제나 보이는 페이지 수. 0이면 첫 페이지와 마지막 페이지가 빠지고 창만 남습니다',
        en: 'How many pages are always shown at each end. 0 drops the first and last page, leaving only the window'
      }
    },
    {
      name: 'showEdges',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '맨 앞 / 맨 뒤로 건너뛰는 버튼',
        en: 'Shows the jump-to-first and jump-to-last steppers'
      }
    },
    {
      name: 'showArrows',
      type: 'boolean',
      default: 'true',
      description: { ko: '이전 / 다음 버튼', en: 'Shows the previous and next steppers' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 줄 전체가 반응하지 않습니다',
        en: 'Unavailable. Every button in the row stops answering'
      }
    },
    {
      name: 'getPageHref',
      type: '(page: number) => string',
      description: {
        ko: '페이지의 주소. 넘기면 번호가 실제 링크가 되어 크롤러가 따라갈 수 있고, 좌우 화살표에 rel="prev" / rel="next"가 붙습니다',
        en: 'The address of a page. Turns the numbers into real links a crawler can follow, and marks the two arrows rel="prev" / rel="next"'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: { ko: 'nav 랜드마크의 접근성 이름', en: 'Accessible name of the nav landmark' }
    },
    {
      name: 'pageLabel',
      type: '(page: number) => string',
      description: {
        ko: '페이지 버튼의 접근성 이름. 기본값은 locale의 표현',
        en: "Accessible name of a page button. Defaults to the locale's wording"
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      description: { ko: '이전 버튼의 접근성 이름', en: 'Accessible name of the previous stepper' }
    },
    {
      name: 'nextLabel',
      type: 'string',
      description: { ko: '다음 버튼의 접근성 이름', en: 'Accessible name of the next stepper' }
    },
    {
      name: 'firstLabel',
      type: 'string',
      description: {
        ko: '맨 앞 버튼의 접근성 이름',
        en: 'Accessible name of the first-page stepper'
      }
    },
    {
      name: 'lastLabel',
      type: 'string',
      description: {
        ko: '맨 뒤 버튼의 접근성 이름',
        en: 'Accessible name of the last-page stepper'
      }
    }
  ],

  Combobox: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. 결과 없음 문구와 지우기 · 삭제 버튼의 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag: the no-matches line and the clear and remove buttons'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸이므로 폼 안에서 두 컨트롤이 구분되지 않습니다',
        en: 'Weight of the surface. The same shell as a TextField, so the two are indistinguishable in a form'
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. multiple에서는 칩이 줄바꿈하는 만큼 자라므로 최소 높이가 됩니다',
        en: 'Height and type scale. With multiple it becomes a minimum, because the field grows as the chips wrap'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리·포커스 링·칩에 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the focus ring and the chips'
      },
      elevationDescription: {
        ko: '필드의 그림자 깊이. 팝업은 자기 그림자를 따로 가집니다',
        en: 'Drop shadow depth of the field. The popup carries its own'
      }
    }),
    {
      name: 'items',
      type: 'readonly ComboboxOption[]',
      required: true,
      description: {
        ko: '옵션 목록. { value, label?, disabled? } 배열이고, label은 ReactNode가 아니라 string입니다',
        en: 'The options, as an array of { value, label?, disabled? } — label is a string, not a ReactNode'
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 여러 개 들 수 있는지. 고른 값은 필드 안의 칩이 됩니다',
        en: 'Whether more than one value may be held. The chosen ones become chips inside the field'
      }
    },
    {
      name: 'value',
      type: 'string | number | (string | number)[] | null',
      description: {
        ko: '선택된 값. multiple이면 배열입니다. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value — an array when multiple. Use with onValueChange for a controlled combobox'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | (string | number)[] | null',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled combobox' }
    },
    {
      name: 'onValueChange',
      type: '(value) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen value changes' }
    },
    {
      name: 'onInputValueChange',
      type: '(inputValue: string) => void',
      description: {
        ko: '입력란의 글자가 바뀔 때. 값이 아니라 필터 질의입니다',
        en: 'Called as the text in the input changes — the filter query, not the value'
      }
    },
    {
      name: 'allowCustom',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '목록에 없는 값을 확정할 수 있는지. 입력한 글자가 목록 맨 끝에 자기 행으로 제안됩니다 — 검색되는 select와 combobox를 가르는 지점입니다',
        en: 'Whether a value the list does not contain may be committed. The typed text is offered as its own row at the end of the list — what separates this from a searchable select'
      }
    },
    {
      name: 'customLabel',
      type: '(query: string) => ReactNode',
      default: 'Add “…”',
      description: { ko: '그 행이 하는 말', en: 'What that row says' }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '필드를 비우는 ×. 한 번에 비워지는 필드는 실수로도 비워지는 필드입니다',
        en: 'Shows a × that empties the field. A field that can be cleared in one click can be emptied by accident'
      }
    },
    {
      name: 'emptyMessage',
      type: 'ReactNode',
      description: {
        ko: '일치하는 것이 없고 값을 추가할 수도 없을 때 팝업이 하는 말',
        en: 'Shown in the popup when nothing matches and no value may be added'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '-1',
      description: {
        ko: '한 번에 보여 줄 최대 행 수. -1은 전부',
        en: 'The most rows the list will show at once. -1 is all of them'
      }
    },
    {
      name: 'placeholder',
      type: 'string',
      description: {
        ko: '아무것도 입력하지 않았을 때 보이는 내용',
        en: 'Shown in the input while nothing is typed'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '입력란 앞에 놓이는 내용', en: 'Content before the input' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'removeLabel',
      type: '(label: string) => string',
      default: 'Remove …',
      description: {
        ko: '칩 제거 버튼의 접근성 이름. 칩의 라벨을 받습니다',
        en: "Accessible name of a chip's remove button. Receives the chip's label"
      }
    },
    {
      name: 'clearLabel',
      type: 'string',
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the clear button' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  NumberField: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸입니다',
        en: "Weight of the surface. A TextField's shell, to the pixel"
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. 스테퍼는 em이므로 숫자를 따라갑니다',
        en: 'Height and type scale. The steppers are sized in em, so they track the number'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리·포커스 링·캐럿·스테퍼의 호버에 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the ring, the caret and the steppers on hover'
      }
    }),
    {
      name: 'value',
      type: 'number | null',
      description: {
        ko: '값. null이 비어 있음입니다 — 파싱해야 하는 문자열이 아닙니다',
        en: 'The number. null means empty — never a string you have to parse'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      description: { ko: '초기 값', en: 'The initial number, for an uncontrolled field' }
    },
    {
      name: 'onValueChange',
      type: '(value: number | null) => void',
      description: {
        ko: '값이 바뀔 때마다 — 타이핑, 스테핑, 휠',
        en: 'Called on every change — typing, stepping, the wheel'
      }
    },
    {
      name: 'onValueCommitted',
      type: '(value: number | null) => void',
      description: {
        ko: '값이 자리를 잡을 때. 타이핑 후 blur, 누르기를 뗄 때',
        en: 'Called when the value settles: on blur after typing, on pointer release after a press'
      }
    },
    {
      name: 'min',
      type: 'number',
      description: { ko: '범위의 시작. 스테핑은 여기서 멈춥니다', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '범위의 끝', en: 'The top of the range' }
    },
    {
      name: 'step',
      type: "number | 'any'",
      default: '1',
      description: {
        ko: '한 걸음의 크기. any는 step 검증을 끕니다',
        en: "How far one step goes. 'any' turns step validation off"
      }
    },
    {
      name: 'largeStep',
      type: 'number',
      default: '10',
      description: { ko: 'Shift를 누른 채의 한 걸음', en: 'The step taken while Shift is held' }
    },
    {
      name: 'smallStep',
      type: 'number',
      default: '0.1',
      description: { ko: 'Alt를 누른 채의 한 걸음', en: 'The step taken while Alt is held' }
    },
    {
      name: 'snapOnStep',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '스테핑이 step의 배수에 붙는지',
        en: 'Whether stepping snaps to multiples of the step'
      }
    },
    {
      name: 'allowWheelScrub',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '포커스된 채 호버 중일 때 휠이 값을 바꾸는지. 포인터 아래에서 스크롤되는 페이지와 바뀌는 필드는 같은 제스처이고, 의도된 것은 하나뿐입니다',
        en: 'Whether the wheel changes the value while focused and hovered. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one was meant'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자를 어떻게 쓸지 — 통화, 백분율, 소수 자릿수. 필드는 $1,240을 보여 주고 값으로는 1240을 보고합니다',
        en: 'How the number is written — currency, percent, decimal places. The field shows $1,240 and still reports 1240'
      }
    },
    {
      name: 'locale',
      type: 'Intl.LocalesArgument',
      description: {
        ko: '어느 로케일로 쓰고 읽을지. 기본은 런타임의 것. BCP 47 문자열이면 두 스테퍼의 이름도 이 언어로 씁니다',
        en: "Which locale the number is written and parsed in. Defaults to the runtime's; a plain BCP 47 string also names the two steppers"
      }
    },
    {
      name: 'steppers',
      type: "'end' | 'split' | 'none'",
      default: "'end'",
      description: {
        ko: '스테퍼가 앉는 자리. split은 숫자 양옆, none은 버튼 없음',
        en: 'Where the steppers sit. split puts them on either side of the number; none drops them'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 앞에 놓이는 내용 — 통화 기호, 단위',
        en: 'Content before the number — a currency mark, a unit'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 뒤, 스테퍼 앞에 놓이는 내용',
        en: 'Content after the number, before the steppers'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'incrementLabel',
      type: 'string',
      description: { ko: '증가 버튼의 접근성 이름', en: 'Accessible name of the increment button' }
    },
    {
      name: 'decrementLabel',
      type: 'string',
      description: { ko: '감소 버튼의 접근성 이름', en: 'Accessible name of the decrement button' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  Overlay: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. overlay의 접근성 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag naming the overlay in that language'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '오버레이가 보입니다. onOpenChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The overlay is shown. Use with onOpenChange for a controlled overlay'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 보일지', en: 'Whether the overlay starts shown' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when the overlay opens or closes' }
    },
    {
      name: 'tone',
      type: "'scrim' | 'blur' | 'solid' | 'clear'",
      default: "'scrim'",
      description: {
        ko: '뒤 페이지를 얼마나 가져가는지. 하나의 축 위의 네 단계이고, 알파만큼이나 블러 반경으로 조율되어 있습니다',
        en: 'How much of the page is taken away. Four steps on one axis, tuned with the blur radius as much as with the alpha'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '클릭이나 Escape로 닫히는지. Dialog와 반대로 꺼져 있습니다 — 오버레이는 묻지 않고 기다리라고 말하며, 빗나간 클릭으로 사라지는 저장은 끝났다고 믿게 되는 저장입니다',
        en: 'Whether a click or Escape closes it. Off, the other way round from Dialog: an overlay is not asking anything, and a save dismissed by a stray click is a save the user will believe finished'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 키보드에서도 가져가는지. trap-focus는 페이지를 스크롤·클릭할 수 있게 두고 포커스만 붙잡습니다',
        en: "Whether the page behind is taken away for the keyboard too. 'trap-focus' leaves it scrollable and clickable while still holding focus inside"
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: {
        ko: '내용이 화면 세로에서 앉는 자리',
        en: 'Where the content sits down the viewport'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '내용 둘레 여백의 스케일', en: 'Scale of the padding around the content' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 포커스 링과, 내용이 읽어 가는 슬롯에 닿습니다',
        en: 'Semantic colour role. Reaches the focus ring and whatever the content reads'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '오버레이의 접근성 이름. 읽을 것이 없는 오버레이도 자기가 무엇인지는 말해야 하므로 선택이 아니라 기본값입니다',
        en: 'The accessible name. It has a default rather than being optional: an overlay that holds nothing readable still has to say what it is'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '스크림 위에 앉는 것 — 스피너, 한 줄, 작은 카드',
        en: 'What sits on top of the scrim — a spinner, a line of text, a small card'
      }
    }
  ],

  Icon: [
    {
      name: 'icon',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '그릴 글리프. svg, img, 아이콘 세트의 컴포넌트, 문자 — children이 아니라 prop인 이유는 남이 그린 요소에서 정작 바꾸고 싶은 두 가지(크기와 색)가 자식으로 들어간 뒤에는 손이 닿지 않기 때문입니다',
        en: 'The glyph — an svg, an img, a component from an icon set, a character. A prop and not children because the two things you always want to change about an icon somebody else drew are the two you cannot reach once it is a child'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '글리프가 그려지는 상자: 14 / 16 / 20 / 24 / 28px. 컨트롤 높이가 아니라 자체 사다리입니다 — 아이콘은 컨트롤이 아니고, 32px짜리 md 글리프는 자기가 들어앉을 버튼만 해집니다',
        en: 'The box the glyph is drawn in: 14 / 16 / 20 / 24 / 28px. Its own ladder rather than the control heights — an icon is not a control, and a 32px md glyph would be the size of the button it sits in'
      }
    },
    {
      name: 'color',
      type: `${COLOR} | 'inherit'`,
      default: "'inherit'",
      shared: true,
      description: {
        ko: '의미론적 색 역할, 또는 감싼 것의 색을 그대로 받는 inherit. 라이브러리에서 기본값이 primary가 아닌 유일한 color입니다 — 아이콘은 콘텐츠이고, 대부분은 이미 색을 정한 무언가 안에 들어갑니다',
        en: 'Semantic colour role, or `inherit` to take the colour of whatever it sits in. The one `color` in the library that does not default to `primary`: an icon is content, and it nearly always sits inside something that has already decided'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '아이콘이 하는 말. 없으면 접근성 트리에서 완전히 숨깁니다 — 대부분의 아이콘 옆에는 같은 말을 하는 단어가 이미 있고, 둘 다 읽는 것은 하나만 읽는 것보다 나쁩니다',
        en: 'What the icon says. Without it the icon is hidden from the accessibility tree entirely — most icons sit next to a word that already says the same thing, and reading both out loud is worse than reading one'
      }
    },
    transitionProp('transition="fade"')
  ],

  IconButton: [
    {
      name: 'icon',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '글리프. 그냥 넘기면 버튼에 대해 em으로 잡히고, 따로 크기가 필요하면 Icon으로 감싸세요',
        en: 'The glyph. Passed bare it is sized in em against the button; wrap it in an Icon when it needs a size of its own'
      }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '버튼이 하는 일을 말로. 여기서 유일한 필수 prop입니다 — 라벨이 그림뿐인 버튼은 접근 가능한 이름이 아예 없고, 그것이 컴포넌트 라이브러리가 가장 흔히 내보내는 접근성 결함입니다',
        en: 'What the button does, in words. The one required prop here: a button whose whole label is a drawing has no accessible name at all, and that is the single most common accessibility defect a component library ships'
      }
    },
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      sizeDescription: {
        ko: 'Button과 같은 높이 사다리. 원반 하나가 버튼 줄에 끼어도 기준선이 흐트러지지 않습니다',
        en: "Button's own height ladder, so a disc drops into a row of buttons without the row losing its baseline"
      },
      densityDescription: {
        ko: '전달은 되지만 눈에 보이지 않습니다 — 아이콘 전용 컨트롤은 정사각형이라 가로 여백이 0입니다',
        en: 'Passed through but invisible: an icon-only control is square, so its horizontal padding is zero'
      }
    }),
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '글리프 자리에 스피너를 놓고 동작을 막습니다. 포커스는 그대로',
        en: 'Puts a spinner in the glyph’s place and stops the button activating, while keeping it focusable'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '흐려지지 않은 채 반응만 멈춤 — 액션은 존재하지만 여기서는 쓸 수 없습니다',
        en: 'Inert but not dimmed — the action exists, it just is not available here'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
        en: 'Unavailable. Drops the colour family for neutral grey'
      }
    }
  ],

  Statistic: [
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '숫자의 이름. Card가 title이라 부르는 자리지만, 여기 있는 것은 *값*의 이름이고 그것은 라이브러리가 이미 label이라 쓰고 있는 것입니다',
        en: 'The name of the number. Card calls the same slot `title`, but what this names is a *value* — which is the thing the library already spells `label` on every field it has'
      }
    },
    {
      name: 'value',
      type: 'number | string',
      required: true,
      description: {
        ko: '수치. 숫자는 형식이 적용되고, 문자열은 그대로 찍힙니다 — 숫자가 아닌 값("3h 42m", "A+")을 위해서',
        en: 'The figure. A number is formatted; a string is printed exactly as given, for the values that are not numbers at all — "3h 42m", "A+"'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자를 어떻게 쓸지. 진행 표시기가 받는 것과 같은 prop이고, 없으면 읽는 사람의 로케일대로 자릿수만 끊습니다',
        en: 'How to write a numeric value — the same prop the progress indicators take. Without it a number is grouped by the reader’s own locale and otherwise left alone'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "the reader's",
      description: {
        ko: '수치를 어떤 언어로 쓸지. 모든 차트가 받는 것과 같은 prop입니다 — 대시보드에서 Statistic은 차트들 옆에 서므로 한쪽에 걸 수 있는 로케일은 다른 쪽에도 걸 수 있어야 합니다',
        en: 'Which language the figure is written in — the same prop every chart takes. A Statistic sits next to the charts in a dashboard, so a locale set on one of them has to be settable on all'
      }
    },
    {
      name: 'prefix',
      type: 'ReactNode',
      description: { ko: '수치 앞 — 통화 기호', en: 'Set before the figure — a currency sign' }
    },
    {
      name: 'unit',
      type: 'ReactNode',
      description: {
        ko: '수치 뒤 — %, MB, 명. prefix와 따로인 이유는 둘이 조판상 다른 것이기 때문입니다: 통화 기호는 숫자 앞에 서고 단위는 뒤에 섭니다',
        en: 'Set after the figure — %, MB, 명. A second slot rather than one adornment with a side, because a currency symbol leads its number and a unit follows it'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 글리프', en: 'A glyph before the label' }
    },
    {
      name: 'previousValue',
      type: 'number',
      description: {
        ko: '비교 대상이 되는 수치 — 지난달 값, 목표치. 이 값을 주는 것이 차이 표시를 켜는 스위치입니다',
        en: 'The figure this one is compared against — last month’s, the target. Passing it is what makes the delta appear'
      }
    },
    {
      name: 'delta',
      type: "'percent' | 'absolute' | 'both' | 'none'",
      default: "'percent'",
      description: {
        ko: '차이를 어떻게 쓸지. 기본이 백분율인 이유는 보고서가 대개 "몇 개 늘었나"가 아니라 "얼마나 움직였나"를 묻기 때문입니다. previousValue가 0이면 나눌 것이 없으므로 차이 자체로 내려앉습니다',
        en: 'How the difference is written. Percentage by default, because a report is nearly always asking how much a figure has moved rather than by how many. With a previousValue of 0 there is nothing to divide by, so it falls back to the difference itself'
      }
    },
    {
      name: 'betterWhen',
      type: "'up' | 'down'",
      default: "'up'",
      description: {
        ko: '어느 쪽이 좋은 방향인지, 그래서 차이를 어느 색으로 칠할지. 매출은 up, 이탈률·오류율·페이지 용량은 down. 장식이 아닙니다 — 이탈률이 올랐는데 초록이면 보고서가 뜻과 반대로 말하고, 하필 훑어보는 독자에게 그렇게 말합니다',
        en: 'Which direction counts as good, and so which way the delta is coloured. `up` for revenue, `down` for churn and error rate and page weight. Not decoration: green-for-larger on a bounce rate says the opposite of what the report means, and says it to exactly the reader who is skimming'
      }
    },
    {
      name: 'caption',
      type: 'ReactNode',
      description: {
        ko: '수치 아래 한 줄 — "지난달 대비"',
        en: 'A line under the figure — "vs. last month"'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: {
        ko: '카드 안에서 블록이 앉는 자리. 한 줄로 늘어놓는 타일이면 center',
        en: 'Where the block sits in the card. `center` for a row of tiles that read as one band'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. Box의 것 그대로 — Statistic은 배치가 얹힌 Box입니다',
        en: 'Weight of the surface — Box’s own, because a Statistic is a Box with an arrangement on it'
      },
      sizeDescription: {
        ko: '수치의 타입 스케일과 시트의 여백·모서리',
        en: 'The figure’s type scale, and the sheet’s padding and radius'
      }
    }),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'caption 아래 무엇이든 — 스파크라인, 목표 대비 ProgressLinear',
        en: 'Anything below the caption: a sparkline, a ProgressLinear against a target'
      }
    },
    transitionProp('transition="zoom"')
  ],

  Carousel: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. region 이름, 화살표, 각 슬라이드 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag: the region name, the arrows and every slide name'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '프레임의 무게. 컨테이너의 방식대로 시트에 색을 들이지 않습니다 — 캐러셀은 남의 사진을 담습니다. 사진에 이미 테두리가 있으면 text',
        en: 'Weight of the frame, said the way a container says it — the sheet is never dyed, because a carousel holds other people’s pictures. `text` when they have edges of their own'
      },
      sizeDescription: {
        ko: '프레임의 모서리, 화살표의 크기와 안쪽 여백, 점의 크기',
        en: 'The frame’s radius, the arrows and how far they sit in, and the size of the dots'
      }
    }),
    {
      name: 'value',
      type: 'number',
      description: { ko: '보이는 슬라이드. 0부터', en: 'Which slide is showing, counted from 0' }
    },
    {
      name: 'defaultValue',
      type: 'number',
      default: '0',
      description: { ko: '처음 보이는 슬라이드', en: 'Which starts showing' }
    },
    {
      name: 'onValueChange',
      type: '(index: number) => void',
      description: {
        ko: '슬라이드가 바뀔 때. 손가락으로 밀어서 바뀐 경우에도 불립니다',
        en: 'Called when the slide changes — including when it changed because somebody swiped'
      }
    },
    {
      name: 'loop',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '끝에서 처음으로 돌아갈지. 끄면 양 끝에서 화살표가 죽습니다 — 시작과 끝이 있는 묶음에는 그쪽이 정직합니다',
        en: 'Whether the arrows wrap from the last slide back to the first. With it off they go inert at the ends instead, which is the honest thing for a set that has a beginning and an end'
      }
    },
    {
      name: 'autoPlay',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '스스로 넘어갑니다. 기본이 꺼짐인 이유는 읽는 중에 움직이는 캐러셀이 웹에서 가장 많은 불평을 듣는 패턴이기 때문입니다. 켜도 hover·포커스·백그라운드 탭에서 멈추고, 모션을 줄여 달라고 한 독자에게는 아예 시작하지 않습니다',
        en: 'Advances on its own. Off by default and deliberately: a carousel that moves while it is being read is the most complained-about pattern on the web. It pauses on hover, on focus anywhere inside it, and in a background tab — and does not start at all for a reader who asked for reduced motion'
      }
    },
    {
      name: 'interval',
      type: 'number',
      default: '5000',
      description: {
        ko: '슬라이드 한 장을 붙잡는 시간(ms)',
        en: 'How long each slide is held, in milliseconds'
      }
    },
    {
      name: 'arrows',
      type: 'boolean',
      default: 'true',
      description: { ko: '이전/다음 버튼', en: 'The previous/next buttons' }
    },
    {
      name: 'indicators',
      type: 'boolean',
      default: 'true',
      description: { ko: '프레임 아래 위치 점들', en: 'The row of position dots under the frame' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '캐러셀의 접근성 이름. 선택이 아니라 기본값입니다 — 이름 없는 region은 건너뛸 수도 없습니다',
        en: 'The accessible name. It has a default rather than being optional: a region with no name is a region nobody can skip'
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      description: { ko: '이전 버튼의 이름', en: 'The previous button’s name' }
    },
    {
      name: 'nextLabel',
      type: 'string',
      description: { ko: '다음 버튼의 이름', en: 'The next button’s name' }
    },
    {
      name: 'slideLabel',
      type: '(index: number, count: number) => string',
      description: {
        ko: '슬라이드 하나를 스크린 리더에게 어떻게 부를지, 그리고 그 점의 라벨. 기본값은 locale의 표현',
        en: "How one slide is named to a screen reader, and how its dot is labelled. Defaults to the locale's wording"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '슬라이드들. 최상위 자식 하나가 슬라이드 하나가 됩니다 — 스냅 지점, 폭, role을 감싸는 쪽이 붙이므로 사진 한 장에 그것들을 붙일 일이 없습니다',
        en: 'The slides. Every top-level child becomes one — the wrapper carries the snap point, the width and the roles, none of which anybody should have to put on a photograph'
      }
    }
  ],

  Pill: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      color: "'secondary'",
      elevation: '2',
      variantDescription: {
        ko: '표면의 무게. *컨트롤*의 방식대로 표면 자체가 색을 받습니다 — Button, Chip과 같습니다',
        en: 'Weight of the surface, said the way a *control* says it: the surface takes the tint, as on Button and Chip'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 여기서만 기본이 secondary입니다 — 이 모양이 흉내 내는 물건이 거의 중립인 검정이기 때문입니다',
        en: 'Semantic colour role. `secondary` here rather than `primary`, because the object this shape is borrowed from is very nearly neutral black'
      },
      elevationDescription: {
        ko: '그림자 깊이. 다른 모든 것이 0인데 여기만 2인 것은 일관성이 깨진 것이 아닙니다 — Pill은 페이지의 일부가 아닌 것으로 정의되고, 자기가 떠 있는 내용 위에 납작하게 붙은 로젠지는 실수처럼 보입니다',
        en: 'Drop shadow depth. `2` against the `0` everything else defaults to, and not an inconsistency: a Pill is defined by not being part of the page, and a lozenge floating flat on the content it floats over reads as a mistake'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '앞자리 — 글리프, 아바타, 상태 점, 사진. 정사각형 상자를 받아 원형으로 잘리므로 img도 icon과 똑같이 들어갑니다',
        en: 'The leading slot — a glyph, an avatar, a status dot, a photo. It is given a square box of its own and clipped to a circle, so an `<img>` lands in it as readily as an icon does'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '가운데의 제목 — 지금 이 pill이 무엇에 관한 것인지. 좌우로 넉넉한 여백을 두고 가운데 정렬됩니다',
        en: 'The headline in the middle — what the pill is currently about. Centred, with generous room either side of it'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 두 번째 줄. 한 단계 작고 한 단계 옅습니다',
        en: 'The second line, under the title. One step down and one step lighter'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '뒷자리. 눌리는 영역 바깥이라 그 자체가 컨트롤이어도 됩니다',
        en: 'The trailing slot. Outside the pressable area, so it can be a control of its own'
      }
    },
    {
      name: 'details',
      type: 'ReactNode',
      description: {
        ko: 'expanded일 때 드러나는 나머지 절반. 다른 모양으로 바뀌는 것이 아니라 아래로 자랍니다 — 하나의 물건이 더 말하는 것, 여기서 빌려 온 것이 그것입니다',
        en: 'The second half, revealed when `expanded`. The pill grows downward into it rather than swapping to a different shape: one object saying more, which is the whole idea being borrowed'
      }
    },
    {
      name: 'expanded',
      type: 'boolean',
      default: 'false',
      description: { ko: 'details가 보이는지', en: 'Whether `details` is showing' }
    },
    {
      name: 'position',
      type: POSITION,
      default: "'static'",
      shared: true,
      description: {
        ko: '페이지 스크롤 안에서 어떻게 앉는지. fixed는 뷰포트에 고정하고 가로로 가운데에 둡니다 — 이 모양이 존재하는 이유가 그 배치입니다',
        en: 'How it sits in the page’s scroll. `fixed` pins it against the viewport and centres it horizontally, which is the arrangement this shape exists for'
      }
    },
    {
      name: 'side',
      type: "'top' | 'bottom'",
      default: "'top'",
      shared: true,
      description: {
        ko: 'static이 아닐 때 어느 가장자리에 붙는지',
        en: 'Which edge it is held against when `position` is not `static`'
      }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler',
      description: {
        ko: '주면 가운데 줄이 진짜 button이 됩니다. endIcon은 그 바깥에 남습니다 — button 안의 button은 브라우저가 파싱 때 풀어 버리는 마크업입니다',
        en: 'Passing it makes the row a real button. `endIcon` stays outside it: a `<button>` inside a `<button>` is markup the browser rewrites on parse'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '가운데 — 한 줄, 작은 읽을거리 한둘',
        en: 'The middle: a line of text, a pair of small readouts'
      }
    }
  ],

  Toolbar: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '바의 무게. 컨테이너의 방식대로 시트에 색을 들이지 않습니다 — 툴바는 남의 컨트롤을 담고, 그 컨트롤들은 자기 색을 가지고 옵니다',
        en: 'Weight of the bar, said the way a container says it — the sheet is never dyed, because a toolbar holds other people’s controls and those arrive with colours of their own'
      },
      sizeDescription: {
        ko: '여백과 모서리의 스케일. 높이는 아닙니다 — 툴바는 안에 든 컨트롤 높이에 여백을 더한 만큼 높습니다',
        en: 'The scale of the padding and the radius. Not a height: a toolbar is as tall as the controls in it plus its padding'
      },
      densityDescription: {
        ko: '여백만 바꿉니다. 별도의 dense prop이 없는 이유가 이것입니다',
        en: 'Padding only — which is why there is no separate `dense` prop meaning the same thing'
      },
      elevationDescription: {
        ko: '그림자 깊이. 고정된 바에서도 기본이 0입니다 — 헤더 밑의 그림자는 "아래에 내용이 있다"는 말이고, 그것은 페이지를 스크롤한 뒤에야 참입니다',
        en: 'Drop shadow depth. `0` even when the bar is pinned: a shadow under a header says "there is content beneath this", and that is only true once the page has been scrolled'
      }
    }),
    {
      name: 'position',
      type: POSITION,
      default: "'static'",
      shared: true,
      description: {
        ko: '페이지 스크롤 안에서 어떻게 앉는지. sticky는 자기 자리를 차지한 채 가장자리에서 멈추므로 아래 내용에 여백을 줄 필요가 없고, fixed는 흐름에서 완전히 빠지므로 페이지가 스스로 여백을 마련해야 합니다',
        en: 'How the bar sits in the page’s scroll. `sticky` takes up its own space and stops at the edge, so nothing underneath has to be padded around it; `fixed` leaves the flow entirely, so the page needs padding of its own'
      }
    },
    {
      name: 'side',
      type: "'top' | 'bottom'",
      default: "'top'",
      shared: true,
      description: {
        ko: 'static이 아닐 때 어느 가장자리에 붙는지',
        en: 'Which edge it is held against when `position` is not `static`'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '내용을 마주 보는 쪽 가장자리에 헤어라인을 긋습니다 — top 바는 아래, bottom 바는 위',
        en: 'Draws a hairline along the edge that faces the content — under a `top` bar, over a `bottom` one'
      }
    },
    {
      name: 'start',
      type: 'ReactNode',
      description: {
        ko: '바의 앞쪽에 고정 — 로고, 제목, 뒤로 가기',
        en: 'Pinned to the start of the bar: a logo, a title, a back button'
      }
    },
    {
      name: 'end',
      type: 'ReactNode',
      description: { ko: '뒤쪽에 고정 — 액션들', en: 'Pinned to the end: the actions' }
    },
    renderProp('render={<header />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '가운데. start와 end가 남긴 폭을 전부 가져갑니다',
        en: 'The middle. Takes whatever width `start` and `end` leave'
      }
    }
  ],

  Blockquote: [
    ...sharedProps({
      variant: "'text'",
      size: "'md'",
      variantDescription: {
        ko: '인용을 얹을 시트의 무게. text가 기본이며 여백의 선 하나뿐입니다 — 표면이 생기기 훨씬 전부터 인용은 그렇게 생겼습니다. 어느 쪽이든 강조선은 그대로 남습니다',
        en: 'Weight of the sheet under the quote. `text` is the default and is a rule in the margin and nothing else. The accent rule stays in all three'
      },
      sizeDescription: {
        ko: '인용문의 타입 스케일과 시트의 여백. 본문보다 한 단계 위이고 행간은 문단이 필요한 만큼 열려 있습니다',
        en: "The quote's type scale and the sheet's padding. One step above body copy, with the leading a paragraph needs"
      },
      colorDescription: {
        ko: '의미론적 색 역할. 시트에는 물들지 않습니다 — 색은 여백의 선과 인용부호에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed; the family shows up in the rule and the mark'
      },
      elevationDescription: {
        ko: '그림자 깊이. 인용은 페이지 위에 떠 있는 것이 아니라 페이지 안에 놓이는 것이라 거의 올리지 않습니다',
        en: 'Drop shadow depth. A quote is set into a page rather than floating over it, so this is rarely raised'
      }
    }),
    {
      name: 'author',
      type: 'ReactNode',
      description: {
        ko: '말한 사람. 이 값이 있으면 전체가 figure + figcaption이 됩니다 — 출처는 인용문 **바깥**에 있어야 한다는 것이 명세의 요구입니다',
        en: 'Who said it. Its presence turns the whole thing into a figure with a figcaption, because the spec puts the attribution outside the quote'
      }
    },
    {
      name: 'source',
      type: 'ReactNode',
      description: {
        ko: '어디서 나온 말인지 — 책, 강연, 문서. cite 요소로 렌더링됩니다. cite는 작품의 제목을 위한 것이지 사람 이름을 위한 것이 아닙니다',
        en: 'Where it is from — a book, a talk, a page. Rendered in a `<cite>`, which is for the title of a work and never for a person'
      }
    },
    {
      name: 'cite',
      type: 'string',
      description: {
        ko: '인용 출처의 URL. blockquote의 cite 속성으로 들어가며 기계만 읽습니다. 사람이 볼 것은 source입니다',
        en: "The source document's URL. Lands on the blockquote's own `cite` attribute, which is machine-readable and shown to nobody"
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '인용문 앞의 표식. 생략하면 기본 글리프, 노드를 넘기면 교체, false면 없앱니다',
        en: 'The mark before the quote. Omit for the house glyph, pass a node to replace it, pass false to take it away'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '인용된 말', en: 'What was said' }
    },
    transitionProp('transition="fade"')
  ],

  Shortcut: [
    {
      name: 'keys',
      type: 'string | string[]',
      required: true,
      description: {
        ko: "키들. 문자열은 +로 나뉩니다('Mod+Shift+P'). 키 자체가 +인 경우에만 배열형을 씁니다",
        en: "The keys. A string is split on `+` — 'Mod+Shift+P'. The array form is for a shortcut whose key is itself a plus"
      }
    },
    {
      name: 'os',
      type: "'auto' | 'mac' | 'windows' | 'linux'",
      default: "'auto'",
      description: {
        ko: '어느 키보드로 읽을지. auto는 브라우저에 묻습니다. 나머지 셋은 읽는 사람의 플랫폼이 아니라 특정 플랫폼을 설명해야 하는 문서를 위한 것입니다',
        en: "Which keyboard to name the modifiers for. `auto` asks the browser; the three explicit values are for pages that have to name a platform rather than the reader's"
      }
    },
    {
      name: 'separator',
      type: 'ReactNode',
      description: {
        ko: '키 사이에 오는 것. 생략하면 플랫폼의 관례를 따릅니다 — Windows/Linux는 +, macOS는 아무것도 없이 ⇧⌘P',
        en: "What goes between two keys. Omit it for the platform's own convention: a `+` off a Mac, and nothing at all on one"
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      color: "'secondary'",
      variantDescription: {
        ko: '키캡의 무게. outline이 기본입니다 — 지금까지 인쇄된 모든 설명서에서 키캡은 얇은 선의 상자였습니다',
        en: 'Weight of the key cap. `outline` is the default: a key cap is a hairline box, which is what it has looked like in every manual ever printed'
      },
      sizeDescription: {
        ko: '키캡의 높이와 타입 스케일. Chip처럼 컨트롤 사다리에서 한 단계 아래입니다 — md 키캡은 sm 컨트롤입니다',
        en: 'Height and type scale of the caps. One step below the control of the same size, exactly as a Chip is'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 키캡은 액션이 아니라 화면의 부속이라 secondary가 기본입니다',
        en: 'Semantic colour role. `secondary` by default, because a key cap is chrome rather than an action'
      },
      density: "'compact'",
      densityDescription: {
        ko: '키캡의 좌우 여백만 바꿉니다. 기본이 compact인 이유는 키캡이 글줄 안에 들어앉기 때문입니다',
        en: 'Horizontal padding of the caps only. `compact` by default, because a cap sits inside a line of text'
      },
      elevationDescription: {
        ko: '그림자 깊이. 이것은 키가 아니라 키의 그림이므로 올리고 싶은 마음이 드는 것이 함정입니다',
        en: 'Drop shadow depth. This is a picture of a key, not a key — which is exactly why raising it is tempting and wrong'
      }
    })
  ],

  Highlight: [
    {
      name: 'query',
      type: 'string | string[] | RegExp',
      required: true,
      description: {
        ko: '무엇을 찾을지. 배열은 긴 것부터 시도하므로 database가 data보다 먼저 잡힙니다. RegExp는 그대로 쓰이며 global 플래그만 강제됩니다 — 이때 caseSensitive와 wholeWord는 무시됩니다',
        en: 'What to find. An array tries the longest term first, so `database` wins over `data`. A RegExp is used as written with the global flag forced on, and then caseSensitive and wholeWord are ignored'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'solid'",
      shared: true,
      description: {
        ko: '표식의 무게. solid는 형광펜, outline은 단어를 두르는 얇은 선, text는 색만',
        en: 'Weight of the mark: `solid` is the highlighter pen, `outline` a hairline box around the word, `text` the colour alone'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'warning'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. warning이 기본인 것은 임의가 아닙니다 — 채움이 밝고 잉크가 어두운 유일한 계열이라, solid warning 표식이 실제로 노란 형광펜처럼 보입니다',
        en: 'Semantic colour role. `warning` by default and not arbitrarily: it is the one family whose fill is light with dark ink, so a solid mark is a yellow highlighter over black text'
      }
    },
    {
      name: 'caseSensitive',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'a와 A를 다른 글자로 볼지',
        en: 'Whether `a` and `A` are different letters'
      }
    },
    {
      name: 'wholeWord',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '단어 전체일 때만 잡을지 — cat이 "cat"은 잡고 "concatenate"는 잡지 않습니다. 여기서 단어는 어떤 문자 체계든 글자·숫자·밑줄의 연속이므로 한국어처럼 띄어쓰기로 구획되지 않는 글에서는 의미가 거의 없습니다',
        en: 'Whether a term has to be a word on its own — `cat` marking "cat" but not "concatenate". A word is a run of letters, digits and underscores in any script, which means very little for text that is not delimited by spaces'
      }
    },
    {
      name: 'underline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '표식에 밑줄도 긋습니다. 모든 variant와 겹쳐 쓸 수 있습니다',
        en: 'Underlines the mark as well. Combines with every variant'
      }
    },
    {
      name: 'weight',
      type: "'regular' | 'medium' | 'semibold' | 'bold'",
      description: {
        ko: '표식의 굵기. 생략하면 주변 글과 같습니다 — 표면이 이미 "이것"이라고 말하고 있고, 문장 안에서 한 단어만 굵어지면 줄 전체의 리듬이 바뀝니다',
        en: 'Weight of the mark. Omit it and it is the weight of the text around it: the surface already says "this one", and a bolded word changes the rhythm of the whole line'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '검색 대상 텍스트. 요소 안까지 들어가므로 strong 안의 일치도 잡히고 strong도 그대로 남습니다',
        en: 'The text to search. Elements are walked into, so a match inside a `<strong>` is marked and the `<strong>` survives'
      }
    }
  ],

  SegmentedButton: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '세그먼트가 놓이는 홈통의 무게. solid는 서리 낀 홈통에 채워진 타일, outline은 같은 홈통에 얇은 선과 밝아진 타일, text는 홈통 없이 선택된 것에만 표면',
        en: 'Weight of the trough. `solid` is a frosted trough with a filled tile, `outline` the same with a hairline and a lit tile, `text` no trough at all'
      },
      sizeDescription: {
        ko: '세그먼트의 높이와 타입 스케일. Button과 같은 사다리입니다',
        en: "The segments' height and type scale, on Button's own ladder"
      },
      elevationDescription: {
        ko: '홈통의 그림자 깊이. 0이 기본입니다',
        en: 'Drop shadow depth of the trough. `0` is the default'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 세그먼트. controlled',
        en: 'The chosen segment, for a controlled set'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      default: 'null',
      description: { ko: '처음 선택된 세그먼트', en: 'Which starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen segment changes' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '전체를 한 번에 사용 불가로', en: 'Disables every segment at once' }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '무엇이 선택되었는지는 보이되 바꿀 수는 없습니다',
        en: 'Shows which one is chosen but does not let it be changed'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 전송 시의 필드 이름',
        en: 'Identifies the value when a form is submitted'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '세그먼트들이 폭을 똑같이 나눠 갖습니다',
        en: 'The segments share the full width, each taking an equal part'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'Segment들', en: 'The Segments' }
    }
  ],

  Segment: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '세그먼트의 식별자. onValueChange가 보고하는 값입니다',
        en: 'Identifies the segment. What onValueChange reports'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤의 내용 — 개수, 상태 점',
        en: 'Content after the label — a count, a status dot'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 집합에는 남습니다',
        en: 'Unavailable, but still part of the set'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '세그먼트의 라벨', en: "The segment's label" }
    }
  ],

  Timeline: [
    {
      name: 'active',
      type: 'number',
      description: {
        ko: '지금 진행 중인 항목의 인덱스. 그 앞은 전부 complete, 뒤는 전부 upcoming이 됩니다. 값이 아니라 인덱스인 이유는 타임라인에 선택이 없기 때문입니다 — 아무것도 고르는 것이 없고, 물어볼 것은 어디까지 왔는가뿐입니다. 생략하면 전부 upcoming, 항목 수를 넘기면 전부 complete',
        en: 'The index of the item being worked on now: everything before it is complete, everything after it is still to come. An index rather than a value, because a timeline has no selection. Omit it and every item is upcoming; pass the item count to mark the whole sequence done'
      }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '항목 사이의 간격만 바꿉니다. 타입 스케일도 불릿도 그대로입니다',
        en: 'The space between items only. Never the type scale, never the bullet'
      }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'vertical'",
      shared: true,
      description: {
        ko: '진행 방향. vertical이 기본이며 단계 수와 설명 길이에 제한이 없습니다. horizontal은 결제 화면 위쪽의 스테퍼로, 라벨이 짧을 때만 정직합니다',
        en: 'Which way the sequence runs. `vertical` is the default and takes any number of steps with anything to say about each; `horizontal` is the stepper across the top of a checkout, and is only honest while every label is short'
      }
    },
    renderProp('render={<ul />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'TimelineItem들. 인덱스는 여기서 매겨지므로 중간에 하나를 끼워 넣어도 뒤의 것을 다시 번호 매길 필요가 없습니다',
        en: 'The TimelineItems. They are numbered here, so inserting one in the middle does not mean renumbering the ones after it'
      }
    }
  ],

  TimelineItem: [
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '이 단계의 제목', en: 'The heading of this step' }
    },
    {
      name: 'meta',
      type: 'ReactNode',
      description: {
        ko: '언제 일어났는지 — 날짜, 소요 시간, 이름',
        en: 'When it happened — a date, a duration, a name'
      }
    },
    {
      name: 'bullet',
      type: 'ReactNode',
      description: {
        ko: '불릿 안에 들어가는 것 — 번호, 아이콘, 아바타. 생략하면 그냥 원입니다',
        en: 'What goes inside the bullet: a number, an icon, an avatar. Omit it and the bullet is a plain disc'
      }
    },
    {
      name: 'status',
      type: "'complete' | 'current' | 'upcoming'",
      description: {
        ko: '타임라인의 active가 계산한 값을 이 항목에 한해 덮어씁니다 — 실패해서 멈춘 단계, 건너뛴 단계',
        en: "Overrides what the timeline's `active` computed for this item — a step that failed and stopped the sequence, a step that was skipped"
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 항목에 한해 색 계열을 덮어씁니다',
        en: "Overrides the timeline's colour family for this item alone"
      }
    },
    {
      name: 'connector',
      type: "'solid' | 'dashed' | 'dotted' | 'none'",
      default: "'solid'",
      description: {
        ko: '다음 항목으로 이어지는 선을 어떻게 그릴지. 선은 도착점이 아니라 출발한 단계의 것이므로, 그 단계에 도달했는지에 따라 색이 정해집니다',
        en: 'How the line to the next item is drawn. The line belongs to the step it leaves, so it is coloured by whether that step has been reached'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '단계의 본문', en: 'The body of the step' }
    }
  ],

  TreeView: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '행 높이, 타입 스케일, 시트의 반경, 그리고 한 단계 들여쓰는 폭',
        en: "The row height, the type scale, the sheet's radius, and how far one level is set in"
      },
      densityDescription: {
        ko: '행의 좌우 여백만 바꿉니다. 행 높이도 들여쓰기도 그대로입니다',
        en: "A row's horizontal padding only. Never the row height, never the indentation"
      }
    }),
    {
      name: 'lines',
      type: "'none' | 'simple' | 'folder'",
      default: "'simple'",
      description: {
        ko: '계층을 어떻게 그릴지. none은 들여쓰기만, simple은 레벨마다 세로선 하나, folder는 거기에 각 행으로 꺾여 들어가는 선까지 — 마지막 자식의 세로선은 그 행에서 끊깁니다',
        en: 'How the hierarchy is drawn. `none` is indentation alone, `simple` is one rail per level, and `folder` adds an elbow into every row and stops the rail under a last child'
      }
    },
    {
      name: 'expanded',
      type: '(string | number)[]',
      description: {
        ko: '열려 있는 가지들. onExpandedChange와 함께 쓰면 controlled가 됩니다',
        en: 'Which branches are open. Use with onExpandedChange for a controlled tree'
      }
    },
    {
      name: 'defaultExpanded',
      type: '(string | number)[]',
      description: { ko: '처음에 열려 있을 가지들', en: 'Which start open' }
    },
    {
      name: 'onExpandedChange',
      type: '(expanded: (string | number)[]) => void',
      description: { ko: '열림 상태가 바뀔 때', en: 'Fires when a branch opens or shuts' }
    },
    {
      name: 'selected',
      type: '(string | number)[]',
      description: {
        ko: '선택된 행들. multiple이 꺼져 있어도 배열입니다 — Accordion의 value와 같은 모양이라, multiple을 켜도 값의 타입은 바뀌지 않습니다',
        en: "Which rows are chosen. An array even with multiple off — the same shape Accordion's value takes, so turning multiple on does not change the type of the value"
      }
    },
    {
      name: 'defaultSelected',
      type: '(string | number)[]',
      description: { ko: '처음에 선택되어 있을 행들', en: 'Which start chosen' }
    },
    {
      name: 'onSelectedChange',
      type: '(selected: (string | number)[]) => void',
      description: { ko: '선택이 바뀔 때', en: 'Fires when the selection changes' }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '여러 행을 동시에 선택할 수 있는지. 켜면 aria-multiselectable도 함께 붙습니다',
        en: 'Whether more than one row may be chosen at a time. Also sets aria-multiselectable'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 모든 행이 반응하지 않습니다',
        en: 'Unavailable. Every row stops answering'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '트리가 읽히는 이름. tree에 aria-label로 붙습니다',
        en: 'The name the tree is announced by, as aria-label on the tree'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '최상위 TreeItem들', en: 'The top-level TreeItems' }
    }
  ],

  TreeItem: [
    {
      name: 'value',
      type: 'string | number',
      description: {
        ko: 'expanded와 selected에서 이 행을 가리키는 식별자. 생략하면 하나가 생성되므로, 코드로 다룰 일이 없는 트리라면 없어도 됩니다',
        en: 'Identifies the row to expanded and selected. One is generated when it is left out, which is fine for a tree nobody drives from code'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '행의 텍스트. children이 아닌 별도 prop인 이유는, 트리에서 children은 그 아래 행들이기 때문입니다',
        en: "The row's text. Its own prop rather than children, because in a tree the children are the rows underneath it"
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 내용 — 폴더 글리프, 파일 종류, 상태 점',
        en: 'Content before the label — a folder glyph, a file type, a status dot'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤의 내용 — 개수, 배지',
        en: 'Content after the label — a count, a badge'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 컨트롤. 누를 수 있는 영역 바깥에 놓입니다 — 열리기도 하고 메뉴 버튼도 가진 행은 누를 것이 두 개입니다',
        en: 'A control pinned to the end of the row, outside the pressable area: a row that both opens and holds a menu button has two things to press'
      }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '행을 링크로 렌더링합니다. 트리가 내비게이션일 때',
        en: 'Renders the row as a link, for a tree that is navigation'
      }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler<HTMLElement>',
      description: {
        ko: '행을 누를 때, 열리거나 선택되기 전에 호출됩니다. preventDefault를 부르면 둘 다 일어나지 않습니다',
        en: 'Fires when the row is pressed, before it opens or is chosen. Calling preventDefault stops both'
      }
    },
    {
      name: 'expandable',
      type: 'boolean',
      description: {
        ko: '아직 children이 없는 행에도 펼침 화살표를 그립니다 — 처음 열 때 가져오는 가지',
        en: 'Forces the disclosure arrow onto a row with no children yet — the branch fetched the first time it is opened'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 열려 있는 가지는 계속 동작합니다',
        en: 'Unavailable. Its branch, if open, keeps working'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '이 행 아래의 TreeItem들', en: 'The TreeItems underneath this one' }
    }
  ],

  OtpField: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '한 칸의 크기와 그 안의 타입 스케일. 컨트롤 사다리와 별개인 이유는, 칸은 줄 안의 컨트롤이 아니라 혼자 서 있는 글자 하나이기 때문입니다',
        en: "A slot's box and the type scale inside it. Its own ladder, because a slot is not a control in a row of controls but a single character standing on its own"
      },
      densityDescription: { ko: '칸 사이의 간격만 바꿉니다', en: 'The space between slots only' }
    }),
    {
      name: 'length',
      type: 'number',
      default: '6',
      description: {
        ko: '코드의 자리수. 2–12로 잘립니다 — 한 칸짜리는 TextField이고, 열두 칸을 넘기면 휴대폰 화면에 들어가지 않습니다',
        en: 'How many characters the code has. Clamped to 2–12: a single box is a TextField, and past twelve the row stops fitting a phone'
      }
    },
    {
      name: 'charset',
      type: "'numeric' | 'alpha' | 'alphanumeric' | 'any'",
      default: "'numeric'",
      description: {
        ko: '입력할 수 있는 문자. 거부된 문자는 표시되지 않고 버려지며 onValueInvalid로 알려집니다. numeric이 기본인 이유는 문자로 오는 코드가 그렇기도 하고, 휴대폰에 숫자 키패드를 띄우기 때문입니다',
        en: 'What may be typed. Rejected characters are dropped rather than shown, and reported through onValueInvalid. numeric is the default because that is what a texted code is, and because it puts a number pad in front of a phone'
      }
    },
    {
      name: 'mask',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '입력한 문자를 가립니다',
        en: 'Hides the characters, the way a password field does'
      }
    },
    {
      name: 'groupSize',
      type: 'number',
      description: {
        ko: '몇 칸마다 구분자를 넣을지. 여섯 자리에 3이면 익숙한 3+3이 됩니다',
        en: 'Splits the row every groupSize slots. 3 on a six digit code gives the familiar two blocks of three'
      }
    },
    {
      name: 'separator',
      type: 'ReactNode',
      default: "'–'",
      description: { ko: '두 그룹 사이에 그려지는 것', en: 'What is drawn between two groups' }
    },
    {
      name: 'value',
      type: 'string',
      description: {
        ko: '코드. onValueChange와 함께 쓰면 controlled가 됩니다',
        en: 'The code. Use with onValueChange for a controlled field'
      }
    },
    {
      name: 'defaultValue',
      type: 'string',
      description: { ko: '처음 값', en: 'What it starts as' }
    },
    {
      name: 'onValueChange',
      type: '(value: string) => void',
      description: { ko: '값이 바뀔 때', en: 'Fires when the value changes' }
    },
    {
      name: 'onComplete',
      type: '(value: string) => void',
      description: {
        ko: '모든 칸이 찼을 때. 코드를 검증할 시점입니다',
        en: 'Fires once every slot is filled — the moment to verify the code'
      }
    },
    {
      name: 'onValueInvalid',
      type: '(value: string) => void',
      description: {
        ko: '입력되거나 붙여넣어진 글자에 charset이 거부하는 문자가 있었을 때',
        en: 'Fires when typed or pasted text held characters the charset rejects'
      }
    },
    {
      name: 'autoSubmit',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '코드가 완성되면 폼을 제출합니다',
        en: 'Submits the owning form as soon as the code is complete'
      }
    },
    ...fieldProps,
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼이 제출될 때 이 필드를 가리키는 이름. 값 전체를 담은 숨겨진 input에 붙습니다',
        en: 'Identifies the field when a form is submitted. It lands on the clipped input carrying the whole value'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '제출 전에 코드가 완성되어 있어야 합니다',
        en: 'The form must have a complete code before it submits'
      }
    },
    ...inertProps,
    {
      name: 'autoFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마운트되면 첫 칸에 커서를 둡니다',
        en: 'Puts the caret in the first slot on mount'
      }
    }
  ],

  ScrollZone: [
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '자식들이 놓이는 방향이자 스크롤되는 방향',
        en: 'Which way the children run, and therefore which way the zone scrolls'
      }
    },
    {
      name: 'lines',
      type: 'number',
      default: '1',
      description: {
        ko: '가로 zone이 새 열로 넘어가기 전까지 쓰는 줄 수(세로 zone에서는 열 수). 2는 같은 너비에 두 배를 담는 선반입니다',
        en: 'How many rows a horizontal zone uses before it starts a new column — columns, in a vertical one. 2 is the shelf that holds twice as much in the same width'
      }
    },
    {
      name: 'spacing',
      type: 'number',
      default: '2',
      description: {
        ko: '자식 사이의 간격. Tailwind 스페이싱 스케일이며 2는 0.5rem으로, GridContainer의 spacing과 같은 사다리입니다',
        en: "The gap between children, on Tailwind's spacing scale: 2 is 0.5rem, the same ladder GridContainer's spacing is on"
      }
    },
    {
      name: 'buttons',
      type: "'auto' | 'always' | 'none'",
      default: "'auto'",
      description: {
        ko: '스크롤 버튼을 언제 그릴지. auto는 갈 곳이 있는 쪽만, always는 둘 다(갈 곳 없는 쪽은 disabled), none은 아예 그리지 않습니다',
        en: 'When the scroll buttons are drawn. auto is only the one that has somewhere to go, always is both with the other disabled, none is neither'
      }
    },
    {
      name: 'buttonPlacement',
      type: "'overlay' | 'inline'",
      default: "'overlay'",
      description: {
        ko: '버튼이 스트립 위에 겹칠지, 옆에 설지. inline이면 스크롤 영역이 버튼 앞에서 끝나므로 항목이 버튼 밑으로 숨는 대신 그 가장자리에서 잘립니다. 버튼이 갈 곳이 없어도 그 자리는 유지됩니다',
        en: 'Whether the buttons sit over the strip or beside it. inline stops the scroller where the button starts, so an item is cut off at its edge rather than sliding under it — and the lane is kept even while that button has nowhere to go'
      }
    },
    {
      name: 'mode',
      type: "'item' | 'page' | 'hold'",
      default: "'item'",
      description: {
        ko: '버튼을 눌렀을 때 하는 일. item은 다음 자식으로, page는 지금 보이는 만큼, hold는 누르고 있는 동안 계속 — hold에서 짧게 누르면 item 한 칸입니다',
        en: 'What pressing a button does: item moves to the next child, page moves by everything on screen, hold scrolls for as long as it is held. A press too short to be a hold falls back to one item'
      }
    },
    {
      name: 'step',
      type: 'number',
      default: '1',
      description: {
        ko: 'item 모드에서 한 번에 지나갈 자식 수',
        en: 'How many children one press moves, in item mode'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '900',
      description: {
        ko: 'hold 모드에서 초당 스크롤되는 픽셀',
        en: 'How fast a held button scrolls, in pixels a second'
      }
    },
    {
      name: 'snap',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '멈출 때 가장 가까운 자식을 시작 가장자리에 맞춥니다. 버튼뿐 아니라 드래그와 휠에도 적용됩니다',
        en: 'Snaps the nearest child to the leading edge when the scrolling stops — dragging and the wheel included, not only the buttons'
      }
    },
    {
      name: 'drag',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마우스나 펜으로도 끌어서 스크롤합니다. 손가락은 브라우저 자신의 스크롤에 맡깁니다 — 관성과 스크롤바가 딸려 오기 때문입니다',
        en: 'Lets a mouse or a pen drag the strip along, the way a finger already does. Touch is left to the browser, whose own scrolling brings momentum and a scrollbar with it'
      }
    },
    {
      name: 'scrollbar',
      type: 'boolean',
      default: 'false',
      description: { ko: '기본 스크롤바를 보입니다', en: 'Shows the native scrollbar' }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'solid'",
      shared: true,
      description: {
        ko: '스크롤 버튼의 무게. zone 자체는 아무것도 그리지 않습니다',
        en: 'Weight of the scroll buttons. The zone itself draws nothing'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '스크롤 버튼의 크기와 가장자리에서 들어온 거리',
        en: "The scroll buttons' size, and how far in from the edge they sit"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '버튼과 포커스 링의 의미론적 색 역할',
        en: 'Semantic colour role of the buttons and the focus ring'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '버튼의 여백만 바꿉니다', en: "The buttons' padding only" }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: '버튼이 자기 이름을 말하는 언어(BCP 47). 지원하지 않는 태그는 영어로 돌아갑니다',
        en: 'Which language the buttons name themselves in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크롤 영역의 이름 — "Categories", "Recent files"',
        en: 'What the scrollable region is called — "Categories", "Recent files"'
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      description: { ko: '뒤로 가는 버튼의 이름', en: "The back button's own name" }
    },
    {
      name: 'nextLabel',
      type: 'string',
      description: { ko: '앞으로 가는 버튼의 이름', en: "The forward button's own name" }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '배치할 것들. 최상위 자식 하나가 스트립의 항목 하나입니다',
        en: 'What is being laid out. Every top-level child is one item of the strip'
      }
    }
  ],

  Panes: [
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: 'pane들이 놓이는 방향. horizontal은 좌우로 늘어놓고 그 사이에 세로 바를, vertical은 위아래로 쌓고 가로 바를 둡니다',
        en: 'Which way the panes run. horizontal puts them side by side with upright handles between them; vertical stacks them'
      }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'pane 사이의 바를 끌 수 있는지. 컨트롤이 아니라 레이아웃으로 쓸 분할이라면 끕니다',
        en: 'Whether the handles can be dragged. Turn it off for a split that is a layout rather than a control'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '바의 두께이자 포인터가 맞춰야 할 과녁의 폭. 보이는 것은 1px 선이지만 잡을 수 있는 폭은 그보다 넓습니다',
        en: "A handle's thickness, which is the width of the target the pointer has to hit. What is drawn is a hairline; what can be grabbed is wider"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '바가 켜질 때의 색 계열. Panes는 시트를 그리지 않으므로 색은 선과 포커스 링에만 나타납니다',
        en: 'The family the handles light up in. A Panes draws no sheet, so the colour only shows in the hairline and the focus ring'
      }
    },
    {
      name: 'onResize',
      type: '(sizes: number[]) => void',
      description: {
        ko: '끄는 동안 모든 pane의 비율(%)을 알려줍니다',
        en: "Fires with every pane's share, in percent, while a handle is dragged"
      }
    },
    {
      name: 'onResizeEnd',
      type: '(sizes: number[]) => void',
      description: {
        ko: '바를 놓았을 때 같은 모양으로 한 번',
        en: 'Fires once, with the same shape, when the handle is let go'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Pane들. 크기 제약은 자식의 props에서 읽으므로 직접 자식이 Pane이어야 합니다 — 무언가로 감싼 Pane은 최소 크기가 없는 pane이 됩니다',
        en: 'The Panes. The constraints are read off the children’s props, so the direct children have to be Panes: a Pane wrapped in something else is a pane with no minimum'
      }
    }
  ],

  Pane: [
    {
      name: 'defaultSize',
      type: 'number | string',
      description: {
        ko: '처음 차지할 몫. 숫자는 퍼센트, 문자열은 길이(240px, 15rem, 20%)입니다. 값을 주지 않은 pane들은 남은 자리를 똑같이 나눠 갖습니다',
        en: 'The share this pane starts with. A number is a percentage; a string is a length (240px, 15rem, 20%). Panes with no defaultSize split what is left equally'
      }
    },
    {
      name: 'minSize',
      type: 'number | string',
      default: '0',
      description: {
        ko: '얼마까지 줄일 수 있는지. 이웃 pane의 최대치이기도 합니다',
        en: "How small it may be dragged, which is also its neighbour's ceiling"
      }
    },
    {
      name: 'maxSize',
      type: 'number | string',
      description: {
        ko: '얼마까지 키울 수 있는지. 생략하면 제한이 없습니다',
        en: 'How large it may be dragged. Unbounded when left out'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'pane 안에 들어가는 것. Pane 자체는 시트를 그리지 않으므로, 표면이 필요하면 안에 Box나 Card를 넣습니다',
        en: 'What is inside the pane. A Pane carries no surface of its own, so put a Box or a Card in it when one is wanted'
      }
    }
  ],

  Breadcrumb: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. nav 이름과 … 버튼의 이름을 이 언어로 씁니다',
        en: 'BCP 47 tag naming the nav landmark and the … button'
      }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '단계 사이의 간격만 바꿉니다', en: 'The space between steps only' }
    },
    {
      name: 'separator',
      type: "'chevron' | 'arrow' | 'slash' | 'dot' | ReactNode",
      default: "'chevron'",
      description: {
        ko: '두 단계 사이에 그려지는 표시. 네 가지 이름 중 하나이거나 아무 노드나 됩니다. chevron과 arrow는 "그다음"을, slash는 "경로"를, dot은 "한 가지의 동급들"을 말합니다',
        en: 'What is drawn between two steps: one of the four names, or any node. chevron and arrow say "and then", slash says "path", dot says "peers of one thing"'
      }
    },
    {
      name: 'maxItems',
      type: 'number',
      description: {
        ko: '이 수를 넘으면 가운데를 …로 접습니다. 생략하면 아무리 길어도 전부 보여줍니다',
        en: 'How many steps to show before the middle is folded away behind a `…`. Left out, the whole trail is shown however long it gets'
      }
    },
    {
      name: 'itemsBeforeCollapse',
      type: 'number',
      default: '1',
      description: {
        ko: '접힌 트레일 앞쪽에 남길 단계 수',
        en: 'How many steps stay at the front of a folded trail'
      }
    },
    {
      name: 'itemsAfterCollapse',
      type: 'number',
      default: '1',
      description: { ko: '뒤쪽에 남길 단계 수', en: 'How many stay at the end' }
    },
    {
      name: 'expandable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '…를 누르면 그 자리에서 펼쳐지는지. 끄면 접힘 표시로만 남습니다',
        en: 'Whether pressing the `…` unfolds the trail in place. Turn it off to leave the fold as a plain mark'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '트레일이 읽히는 이름. nav의 aria-label입니다',
        en: "The name the trail is announced by, as the nav's aria-label"
      }
    },
    {
      name: 'expandLabel',
      type: 'string',
      description: { ko: '…가 읽히는 이름', en: 'What the `…` is announced as' }
    },
    {
      name: 'structuredData',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'schema.org BreadcrumbList를 JSON-LD로 함께 내보냅니다. 접힌 단계도 모두 포함됩니다',
        en: 'Also emits a schema.org BreadcrumbList as JSON-LD, folded steps included'
      }
    },
    {
      name: 'baseUrl',
      type: 'string',
      description: {
        ko: 'structuredData에서 상대 href를 절대 URL로 만들 기준 — 사이트의 origin',
        en: "What relative hrefs are resolved against for structuredData — the site's origin"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'BreadcrumbItem들', en: 'The BreadcrumbItems' }
    }
  ],

  BreadcrumbItem: [
    {
      name: 'href',
      type: 'string',
      description: { ko: '단계를 링크로 렌더링합니다', en: 'Renders the step as a link' }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler<HTMLElement>',
      description: {
        ko: '단계를 누를 때. href가 없으면 버튼으로 렌더링됩니다',
        en: 'Fires when the step is pressed. Renders it as a button when there is no href'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞의 내용 — 홈 글리프, 저장소 아바타',
        en: 'Content before the label — a home glyph, a repository avatar'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤의 내용', en: 'Content after the label' }
    },
    {
      name: 'current',
      type: 'boolean',
      description: {
        ko: '지금 보고 있는 페이지로 표시하고 링크를 걷어냅니다. 마지막 단계는 그냥 두어도 현재이므로, 트레일이 독자가 있는 곳에서 끝나지 않을 때만 필요합니다 — 어디든 한 번 지정하면 마지막 단계에서 표시가 걷힙니다. 한 트레일에 현재는 하나뿐이기 때문입니다',
        en: 'Marks this step as the page you are on, which stops it being a link. The last step is the current one on its own, so this is only needed for a trail that ends somewhere the reader is not — and setting it anywhere takes the mark off the last step, because only one step in a trail can be it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 트레일에는 그대로 남습니다',
        en: 'Unavailable. Keeps its place in the trail'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '단계의 라벨', en: "The step's label" }
    }
  ],

  TextLink: [
    {
      name: 'href',
      type: 'string',
      required: true,
      description: { ko: '링크가 가리키는 곳', en: 'Where the link goes' }
    },
    {
      name: 'underline',
      type: "'always' | 'hover' | 'none'",
      default: "'always'",
      description: {
        ko: '밑줄을 언제 그릴지. color가 기본적으로 없으므로 always가 기본값입니다 — 선이 없으면 문장 속에서 링크를 구분할 단서가 남지 않습니다',
        en: 'When the underline is drawn. always is the default because color is not: with no line there is nothing telling a link from the sentence around it'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 기본값이 없습니다 — 문단 안의 링크는 대개 그 문단의 색을 그대로 씁니다',
        en: 'Semantic colour role. No default — a link in a paragraph is usually the paragraph’s own colour'
      }
    },
    {
      name: 'size',
      type: SIZE,
      shared: true,
      description: {
        ko: '타입 스케일. 이것도 기본값이 없습니다. 문장 속 링크는 그 문장의 크기입니다',
        en: 'The type scale. Also no default: a link inside a sentence is the size of the sentence'
      }
    },
    {
      name: 'newTab',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '새 탭에서 엽니다. rel로 window.opener를 끊고, icon을 켜며, screen reader용 문장을 덧붙입니다',
        en: 'Opens in a new tab, with the rel that closes window.opener. Turns icon on and adds a line for a screen reader'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | boolean',
      default: 'newTab',
      description: {
        ko: '라벨 뒤의 표식. true는 newTab이면 상자를 벗어나는 화살표를, 아니면 사슬을 그립니다. 노드를 주면 그 글리프로 바뀝니다',
        en: 'The mark after the label. true draws the arrow leaving its box when newTab is on and the chain otherwise; a node replaces the glyph'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: 'screen reader용 문장의 언어. BCP 47 태그(ko, pt-BR, zh-Hant). 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the line for a screen reader is written in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'a 대신 다른 요소로 렌더링합니다 — 대개 router가 주는 Link. href는 그대로 전달되므로 한 번만 쓰면 됩니다',
        en: 'Renders something other than an a — the Link a router brings, most of the time. href still goes through, so it is written once'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '링크의 라벨', en: 'The label' }
    }
  ],

  ChatBubble: [
    {
      name: 'side',
      type: "'start' | 'end'",
      default: "'start'",
      description: {
        ko: '누구의 메시지인지. 줄이 어느 방향으로 흐르고 어느 모서리를 짧게 자를지를 정합니다',
        en: 'Whose message this is. Decides which way the row runs and which corner of the sheet is cut short'
      }
    },
    {
      name: 'name',
      type: 'ReactNode',
      description: { ko: '보낸 사람. 말풍선 위에 놓입니다', en: 'Who sent it, above the bubble' }
    },
    {
      name: 'time',
      type: 'ReactNode',
      description: { ko: '보낸 시각. 이름 옆에 놓입니다', en: 'When it was sent, beside the name' }
    },
    {
      name: 'avatar',
      type: 'ReactNode',
      description: {
        ko: '보낸 사람의 그림 — 보통 Avatar. 없으면 말풍선이 줄 전체를 씁니다',
        en: 'The sender’s picture — an Avatar. Left out, the bubble takes the whole row'
      }
    },
    {
      name: 'status',
      type: "'sending' | 'sent' | 'delivered' | 'read' | 'failed'",
      description: {
        ko: '전달 상태. 말풍선 아래에 표식으로 그려집니다. 없으면 아무것도 그리지 않습니다',
        en: 'How far the message has got, drawn as a mark under the bubble. Left out, nothing is drawn'
      }
    },
    {
      name: 'statusLabel',
      type: 'string',
      description: {
        ko: '표식을 읽어 줄 단어를 직접 씁니다',
        en: 'Overrides the word the mark is read out as'
      }
    },
    {
      name: 'typing',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '메시지 대신 점 세 개를 그립니다. children은 그대로 두므로 같은 말풍선이 다시 돌아올 수 있습니다',
        en: 'Draws the three dots instead of the message. children is left alone, so the same bubble can go back to it'
      }
    },
    {
      name: 'media',
      type: 'ReactNode',
      description: {
        ko: '사진·영상·지도. 텍스트 위에 가장자리까지 채워 그려지고 말풍선의 모서리가 잘라 냅니다',
        en: 'A picture, a video, a map — drawn edge to edge above the text, cropped by the bubble’s corners'
      }
    },
    {
      name: 'preview',
      type: 'ChatBubbleLinkPreview',
      description: {
        ko: '메시지 안의 링크를 카드로 펼칩니다. url · title · description · image · site · newTab',
        en: 'A link in the message, unfurled into a card: url · title · description · image · site · newTab'
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '메시지의 액션 — 보통 Menu의 trigger. 말풍선 옆에 놓이고, 줄에 hover나 focus가 오기 전까지는 비켜서 있습니다',
        en: 'The message’s own actions — usually a Menu trigger. Sits beside the bubble and stays out of the way until the row is hovered or focused'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '표식을 읽어 주는 언어. BCP 47 태그. 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the marks are read out in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '말풍선 표면의 무게. 내 메시지를 구분하는 보통의 방법이 solid입니다. side가 이것을 정하지 않는 것은 의도한 것입니다',
        en: 'Weight of the bubble’s surface. solid is the usual way to tell your own messages apart; side deliberately does not decide it'
      },
      densityDescription: {
        ko: '말풍선 안쪽 여백만 바꿉니다',
        en: 'Padding inside the bubble, and nothing else'
      }
    }),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메시지', en: 'The message' }
    }
  ],

  Spoiler: [
    {
      name: 'revealed',
      type: 'boolean',
      description: {
        ko: '내용이 열려 있는지. 직접 제어할 때 씁니다',
        en: 'Whether the content is uncovered. Pass it to drive the Spoiler yourself'
      }
    },
    {
      name: 'defaultRevealed',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '제어하지 않을 때의 시작 상태',
        en: 'Where an uncontrolled Spoiler starts'
      }
    },
    {
      name: 'onRevealedChange',
      type: '(revealed: boolean) => void',
      description: {
        ko: '열기 또는 닫기 버튼을 눌렀을 때',
        en: 'Called when the reveal or hide button is pressed'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '기본 라벨과 안내 문구의 언어. BCP 47 태그(ko, pt-BR, zh-Hant). 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the default label and notice are written in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '열기 버튼의 라벨. 기본값은 locale이 정합니다',
        en: 'The reveal button’s label. Defaults to the locale’s word for it'
      }
    },
    {
      name: 'hideLabel',
      type: 'ReactNode',
      description: {
        ko: 'reversible일 때 닫기 버튼의 라벨',
        en: 'The hide button’s label, when reversible is on'
      }
    },
    {
      name: 'description',
      type: 'ReactNode | false',
      description: {
        ko: '버튼 위의 안내 문구. 기본값은 locale이 정하고, false면 아무것도 쓰지 않습니다',
        en: 'The line above the button. Defaults to the locale’s wording; false writes nothing at all'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '기본 열기 버튼을 통째로 바꿉니다. 이 경우 revealed와 onRevealedChange로 직접 제어해야 합니다',
        en: 'Replaces the default reveal button entirely. The replacement is yours to wire up through revealed and onRevealedChange'
      }
    },
    {
      name: 'reversible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '열고 난 뒤 다시 닫을 수 있게 아래에 닫기 버튼을 둡니다',
        en: 'Keeps the content coverable: once revealed, a hide button appears under it'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '가려진 상자의 높이를 제한합니다. CSS 길이 또는 픽셀 수. 열면 풀립니다',
        en: 'Clamps the covered box to this height — a CSS length, or a number in pixels. Revealing releases it'
      }
    },
    {
      name: 'blur',
      type: 'number',
      default: '10',
      description: { ko: '흐림의 세기(px)', en: 'How hard the content is blurred, in pixels' }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '내용 주변의 여백. 사진이나 영상처럼 가장자리까지 채워야 할 때 끕니다',
        en: 'Inner padding around the content. Turn it off for something that should reach the edges'
      }
    },
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '상자 표면의 무게. text는 상자를 그리지 않습니다',
        en: 'Weight of the box’s surface. text draws no box at all'
      },
      sizeDescription: {
        ko: '시트의 반경과 그 위 버튼의 크기',
        en: 'The sheet’s radius, and the size of the button on it'
      },
      densityDescription: {
        ko: '덮개의 문구와 버튼 주위 여백만 바꿉니다',
        en: 'Padding around the cover’s own text and button, and nothing else'
      }
    }),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '가려지는 내용', en: 'What is being covered' }
    }
  ],

  Drawer: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. ×의 접근성 이름을 이 언어로 씁니다. 지원하지 않는 태그는 영어로',
        en: 'BCP 47 tag naming the × in that language. Unsupported tags fall back to English'
      }
    },
    {
      name: 'side',
      type: SIDE,
      default: "'left'",
      description: {
        ko: '패널이 붙는 창의 변. NebaSide가 어디서나 그렇듯 물리적입니다 — 창 위쪽의 drawer는 어떤 쓰기 방향에서도 위쪽입니다',
        en: 'Which edge of the window the panel is attached to. Physical, as NebaSide is everywhere'
      }
    },
    {
      name: 'mode',
      type: "'overlay' | 'inline'",
      default: "'overlay'",
      description: {
        ko: 'overlay는 스크림 위에 뜨고 focus를 가두며 닫을 수 있습니다. inline은 레이아웃의 일부이며 스크림도, portal도, 닫을 것도 없습니다',
        en: 'overlay floats on a scrim, holds focus and is dismissed. inline is part of the layout — no scrim, no portal, nothing to dismiss'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백, 그리고 옆면 패널의 기본 너비까지 함께 정합니다',
        en: "The type scale, the padding, and a side panel's default width"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 시트는 물들지 않으므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed, so it reaches the edge and the focus ring'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께 쓰면 제어 컴포넌트가 됩니다. inline에서는 패널이 레이아웃에 있는지를 뜻합니다',
        en: 'Whether it is shown. With onOpenChange, a controlled drawer. In inline mode it is whether the panel is in the layout'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      description: {
        ko: '비제어 drawer의 초기 상태. overlay에서는 false, inline에서는 true가 기본입니다 — 열어야 나타나는 고정 사이드바는 고정 사이드바가 아니기 때문입니다',
        en: 'The initial state of an uncontrolled drawer. false in overlay mode, true in inline mode: a fixed sidebar that had to be opened would not be fixed'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: 'drawer를 여는 요소. Base UI가 연결합니다. overlay 전용 — inline drawer는 열 것이 없으므로 렌더링되지 않습니다',
        en: 'The element that opens it, wired up by Base UI. overlay only — an inline drawer has nothing to open, so it is not rendered'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. drawer의 이름이 되는 heading으로 렌더링됩니다',
        en: 'The heading. Rendered as the element that names the drawer'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 drawer의 접근성 설명',
        en: "A line under the title, and the drawer's accessible description"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '패널 바닥에 고정되는 버튼 줄. 끝 정렬됩니다. DrawerClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, held against the foot of the panel and end-aligned. DrawerClose is what makes one of them dismiss'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '구역 사이를 여백 대신 하이라인으로 나눕니다. 본문이 스크롤되는 순간부터 켜는 편이 좋습니다',
        en: 'Separates the sections with hairlines instead of space. Worth turning on the moment the body scrolls'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      description: {
        ko: '모서리의 ×. overlay에서는 켜짐, inline에서는 꺼짐이 기본입니다 — 다시 열 방법 없이 고정 사이드바를 닫는 ×는 되돌릴 수 없는 문입니다',
        en: 'The × in the corner. On in overlay mode, off in inline mode: a × that closes a fixed sidebar with nothing to reopen it is a one-way door'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'extent',
      type: 'number | string',
      description: {
        ko: '패널이 자기 변에서 얼마나 들어오는지 — left/right에서는 너비, top/bottom에서는 높이입니다. 숫자는 픽셀입니다',
        en: 'How far the panel reaches in from its edge: a width for left and right, a height for top and bottom. Numbers are pixels'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '페이지를 향한 변의 두 모서리만 깎습니다. 창 가장자리에 닿은 모서리는 언제나 각집니다',
        en: 'Cuts the two corners on the edge that faces the page. The corners against the window edge are always square'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 가져갈지. trap-focus는 스크롤과 클릭은 남기고 focus만 가둡니다. overlay 전용',
        en: 'Whether the page behind is taken away. trap-focus keeps it scrollable and clickable while holding focus inside. overlay only'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape나 스크림 클릭으로 닫히는지. overlay 전용',
        en: 'Whether Escape or a click on the scrim closes it. overlay only'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '본문. 스크롤되는 유일한 부분입니다',
        en: 'The body — the only part that scrolls'
      }
    }
  ],

  Popover: [
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: 'BCP 47 태그. ×의 접근성 이름을 이 언어로 씁니다. 지원하지 않는 태그는 영어로',
        en: 'BCP 47 tag naming the × in that language. Unsupported tags fall back to English'
      }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: 'popup이 매달리고 또 popup을 여는 요소. ref를 받고 props를 펼치는 요소 하나여야 합니다 — 모든 Neba 컴포넌트가 그렇습니다',
        en: 'The element the popup hangs off and that opens it. One element that accepts a ref and spreads props — every Neba component does'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백, 그리고 popup이 넓어질 수 있는 한계까지 함께 정합니다',
        en: 'The type scale, the padding, and how wide the popup may get'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 시트는 물들지 않으므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed, so it reaches the edge and the focus ring'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. popup의 이름이 되는 요소로 렌더링됩니다',
        en: 'The heading. Rendered as the element that names the popup'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 popup의 접근성 설명',
        en: "A line under the title, and the popup's accessible description"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '본문', en: 'The body' }
    },
    {
      name: 'side',
      type: SIDE,
      default: "'bottom'",
      description: {
        ko: '트리거의 어느 쪽에 뜨는지. 자리가 없으면 반대쪽으로 넘어갑니다',
        en: 'Which edge of the trigger it appears on. Flips to the opposite side when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: { ko: '그 변을 따라 놓이는 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'alignOffset',
      type: 'number',
      default: '0',
      description: { ko: '그 변을 따라 밀어내는 거리(px)', en: 'Shift along that edge, in pixels' }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거를 가리키는 작은 쐐기. Tooltip과 달리 기본이 꺼짐입니다 — 이 표면은 반투명이고, popup의 상자 밖으로 튀어나온 쐐기는 그 backdrop을 함께 가져갈 수 없습니다',
        en: 'The little wedge pointing at the trigger. Off by default, unlike Tooltip: this surface is translucent, and a wedge outside the popup cannot carry that backdrop with it'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께',
        en: 'Whether it is open. With onOpenChange'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비제어 popover의 초기 상태',
        en: 'The initial state of an uncontrolled popover'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'false',
      description: {
        ko: '뒤 페이지를 가져갈지. 기본이 꺼짐인 것이 popover와 Dialog를 가릅니다 — popover는 페이지 대신이 아니라 페이지 옆의 한 부분입니다',
        en: 'Whether the page behind is taken away. Off by default, and that is what separates a popover from a Dialog: it sits beside the page, not instead of it'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Escape나 바깥 클릭으로 닫히는지. 꺼도 PopoverClose는 통과하므로 갇히지 않습니다',
        en: 'Whether Escape or a click outside closes it. A PopoverClose still gets through when it is off, so it is never a trap'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      default: 'false',
      description: { ko: '모서리의 ×', en: 'The × in the corner' }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정한 최대 너비를 대신할 값. 숫자는 픽셀입니다',
        en: 'A hard cap overriding the one size implies. Numbers are pixels'
      }
    }
  ],

  Skeleton: [
    {
      name: 'shape',
      type: "'line' | 'rect' | 'circle'",
      default: "'line'",
      description: {
        ko: '무엇을 대신하는지 — 글줄, 블록(이미지·차트·카드), 원형(avatar)',
        en: 'What it stands in for: a run of text, a block (image, chart, card), or something round (an avatar)'
      }
    },
    {
      name: 'lines',
      type: 'number',
      default: '1',
      description: {
        ko: 'shape="line"에서 그릴 줄 수. 마지막 줄은 문단의 마지막 줄처럼 짧게 그려집니다. 다른 shape에서는 무시됩니다',
        en: 'How many lines to draw, for shape="line". The last is drawn short, the way the last line of a paragraph is. Ignored by the other shapes'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '대신하는 것의 크기 — line은 타입 스케일, circle은 지름, rect는 기본 블록 높이',
        en: 'The scale of the thing being stood in for: the type scale for a line, the diameter for a circle, the default block height for a rect'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '색 계열. 그대로 두는 편이 좋습니다 — 아직 도착하지 않은 내용에 대해 의미론적 색을 입히는 것은 없는 것을 말하는 셈입니다',
        en: 'Colour family. Worth leaving alone: a placeholder carrying a semantic colour is saying something about content that has not arrived'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: '명시적 너비. 숫자는 픽셀입니다',
        en: 'An explicit width. Numbers are pixels'
      }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: '명시적 높이. 숫자는 픽셀입니다',
        en: 'An explicit height. Numbers are pixels'
      }
    },
    {
      name: 'animated',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '지나가는 하이라이트. 축소된 모션 설정은 묻지 않고도 색 맥동으로 바꾸므로, 이것은 접근성 스위치가 아닙니다',
        en: 'The travelling highlight. A reduced-motion preference already swaps it for a colour pulse, so this is not the accessibility switch'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크린 리더가 듣는 말. 비워 두면 aria-hidden입니다 — 상자 열둘이 저마다 자기를 알리는 것보다 침묵이 낫기 때문입니다. 한 영역을 대표하는 하나에만 붙이면 그것이 status가 됩니다',
        en: 'What a screen reader is told. Unset it is aria-hidden, because a dozen boxes each announcing themselves is worse than silence. Give it to the one that stands for a whole region and it becomes a status'
      }
    },
    renderProp('render={<span />}')
  ],

  Empty: [
    ...sharedProps({
      variant: "'text'",
      size: "'md'",
      color: "'secondary'",
      variantDescription: {
        ko: '표면의 무게. 기본이 text인 곳은 여기뿐입니다 — 빈 상태는 거의 언제나 이미 무언가(Card의 본문, Table의 아래) 안에 놓이고, 사각형 안에 사각형을 하나 더 그리는 것은 하나가 더 많은 것입니다',
        en: 'Weight of the surface. text is the default here and nowhere else: an empty state is nearly always already inside something — a Card body, a Table — and a second rectangle drawn inside the first is one rectangle too many'
      },
      sizeDescription: {
        ko: '타입 스케일과 글리프 크기, 그리고 상태가 차지하는 세로 여백',
        en: 'The type scale, the glyph, and how much room the state takes vertically'
      },
      colorDescription: {
        ko: '색 계열. 시트는 물들지 않고 하이라인과 focus ring까지만 닿습니다. secondary에서 옮길 만한 때는 비어 있다는 사실 자체가 문제일 때입니다 — 불러오지 못한 영역의 danger처럼',
        en: 'Colour family. The sheet is never dyed; it reaches the hairline and the focus ring and stops. Worth moving off secondary only when the emptiness is itself a problem — danger on a region that failed to load'
      },
      elevationDescription: {
        ko: '그림자 깊이. 0이 거의 언제나 맞습니다 — 빈 상태는 이미 있는 표면에 뚫린 구멍이지 그 자체로 한 장의 시트가 아닙니다',
        en: 'Drop shadow depth. 0 is almost always right: an empty state is a hole in a surface that already exists rather than a sheet of its own'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode | false',
      default: "locale's wording",
      description: {
        ko: '제목 줄. 기본값은 locale이 “여기에는 아무것도 없다”를 말하는 방식이고, false면 글리프와 문장만 남습니다',
        en: "The headline. Defaults to the locale's way of saying that there is nothing here; false leaves the glyph and the sentence with no heading over them"
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '제목 위의 글리프. 기본값은 빈 트레이, false면 생략. svg는 size 사다리에 맞춰지고 그 밖의 것(일러스트, 브랜드 마크)은 원래 크기 그대로입니다',
        en: 'The glyph above the headline. Defaults to the empty tray; false drops it. An svg is sized off the size ladder, and anything else — an illustration, a brand mark — is left at the size it came in at'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '본문 아래에 놓이는 다음 할 일 — “첫 항목 만들기” 버튼, “필터 지우기” 링크. 여럿이면 한 줄에 놓이고 함께 줄바꿈됩니다',
        en: 'What to do about it, under the text — a "Create the first one" button, a "Clear filters" link. Several sit in a row and wrap together'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '기본 제목의 언어. BCP 47 태그(ko, pt-BR, zh-Hant). title을 주면 무시되고, 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the default headline is written in — a BCP 47 tag. Ignored once title is given, and unsupported tags fall back to English'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 문장 — 왜 비어 있는지, 다음에 무엇을 할지',
        en: 'The sentence under the headline: why it is empty, or what to do next'
      }
    },
    transitionProp('transition="fade"'),
    renderProp('render={<td colSpan={5} />}')
  ],

  AspectRatio: [
    {
      name: 'ratio',
      type: 'number | string',
      default: '1',
      description: {
        ko: "상자가 지키는 비율. CSS가 쓰는 그대로 — 숫자(1.5)나 비('16 / 9')가 aspect-ratio에 그대로 전달됩니다",
        en: "The proportion the box holds, written the way CSS writes it — a number (1.5) or a ratio ('16 / 9'), reaching aspect-ratio untouched"
      }
    },
    {
      name: 'fit',
      type: "'cover' | 'contain' | 'fill' | 'none'",
      default: "'cover'",
      description: {
        ko: '안의 미디어를 상자에 맞추는 방식. 직계 자식인 img, video, canvas, svg, iframe에 적용되며 그 밖의 것은 평소대로 배치됩니다',
        en: 'How a single piece of media inside is fitted. Applies to an img, video, canvas, svg or iframe that is a direct child; anything else is laid out normally'
      }
    },
    {
      name: 'rounded',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '모서리를 size 단계의 반경 사다리로 깎습니다. 레이아웃 컴포넌트는 아무것도 그리지 않으므로 기본은 꺼짐입니다',
        en: 'Rounds the corners to the size step of the radius ladder. Off by default, because a layout component draws nothing'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: 'rounded가 쓰는 반경 사다리의 단계. Box에서처럼 높이도 타입 스케일도 건드리지 않습니다',
        en: 'Which step of the radius ladder rounded uses. As on Box, it never touches a height or the type scale'
      }
    },
    renderProp('render={<figure />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '비율 안에 담기는 것', en: 'What is held to the proportion' }
    }
  ],

  WindowPane: [
    {
      name: 'os',
      type: "'macos' | 'macosx' | 'windows11' | 'windows10' | 'windows8' | 'windows7' | 'windowsxp' | 'linux'",
      default: "'macos'",
      description: {
        ko: '어느 시스템의 창인지. 컨트롤의 위치와 모양, 제목표시줄의 높이와 색, 테두리의 두께와 모서리를 정합니다. 제목표시줄이 달라진 버전마다 별도 항목입니다 — XP는 Luna 블루와 그 색의 테두리, 7은 아크릴 유리, 8은 납작한 사각형, 10은 바 아래의 선, 11은 둥근 모서리, macosx는 Aqua입니다',
        en: 'Whose window this is a picture of. Decides where the controls sit and how they are drawn, how tall the title bar is and what colour, and how thick the frame is and how its corners are cut. A version is its own entry wherever the title bar is what changed: XP painted it Luna blue and framed the window in it, 7 made it glass, 8 threw both away, 10 ruled it off from the body, 11 rounded the corners, and macosx is Aqua'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목표시줄의 이름. 창 자체의 접근성 이름이기도 합니다',
        en: 'The window’s name, in the title bar. Also what names the window itself'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '제목 옆의 글리프 — 앱의 마크',
        en: 'A glyph beside the title — the app’s mark'
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '제목표시줄이 함께 나르는 것. 컨트롤 옆에 놓입니다',
        en: 'Anything else the title bar carries, set beside the controls'
      }
    },
    {
      name: 'controls',
      type: "boolean | ('minimize' | 'maximize' | 'close')[]",
      default: 'true',
      description: {
        ko: '어떤 버튼을 둘지. 순서는 배열이 아니라 시스템이 정합니다 — macOS는 닫기가 앞, Windows는 뒤입니다',
        en: 'Which of the three buttons the title bar has. The order is the system’s rather than the array’s: macOS puts close first and Windows puts it last'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '크롬의 스케일 — 제목표시줄 높이, 버튼, 글자. 내용은 건드리지 않습니다',
        en: 'The scale of the chrome — the title bar’s height, its buttons and its type. It does not touch the content'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '포커스 링과 accent 제목표시줄이 입는 색 계열',
        en: 'The colour family the focus rings and an accent title bar take'
      }
    },
    {
      name: 'accent',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'Windows가 제공하는 것처럼 제목표시줄에 색 계열을 입힙니다',
        en: 'Dyes the title bar with the colour family, the way Windows offers to'
      }
    },
    {
      name: 'transparency',
      type: 'number',
      default: '0',
      description: {
        ko: '0에서 1 사이. 제목표시줄과 본문의 바탕, 테두리에만 적용되며 내용에는 적용되지 않습니다. 0보다 크면 아크릴(블러)이 함께 켜집니다',
        en: 'From 0 to 1. It applies to the title bar, the body’s own fill and the border — never to the content. Anything above 0 also turns the acrylic on'
      }
    },
    {
      name: 'active',
      type: 'boolean',
      description: {
        ko: '앞에 있는 창인지. 넘기지 않으면 스스로 판단합니다 — 페이지의 다른 WindowPane이 눌리거나 포커스를 가져갈 때까지 앞에 있습니다. 창들 *주변*의 페이지를 누르는 것은 아무것도 바꾸지 않습니다. 뒤에 있는 창은 모양을 지키고 강조만 잃으며(회색 신호등, 강조색 없는 제목표시줄, 한 단계 낮은 그림자) 흐려지지는 않습니다',
        en: 'Whether this is the window in front. Left out, the window works it out for itself: it is in front until another WindowPane on the page is pressed or takes the focus, and a press on the page *around* the windows changes nothing. A window behind keeps its shape and loses its emphasis — grey traffic lights, no accent, one step less shadow — never its opacity'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '2',
      shared: true,
      description: {
        ko: '창 주위의 그림자. 0은 그림자 없음입니다',
        en: 'The shadow around the window. 0 means no shadow at all'
      }
    },
    {
      name: 'position',
      type: "'static' | 'absolute' | 'fixed'",
      default: "'static'",
      shared: true,
      description: {
        ko: '어떻게 배치되는지. static은 흐름 안(relative로 놓여 offset이 주변을 밀지 않습니다), absolute는 가장 가까운 positioned 조상 안, fixed는 뷰포트에 고정',
        en: 'How the window is laid out. static leaves it in the flow (as a relatively positioned box, so offset moves nothing around it), absolute pins it inside the nearest positioned ancestor, fixed pins it to the viewport'
      }
    },
    {
      name: 'draggable',
      type: 'boolean',
      default: 'false',
      description: { ko: '제목표시줄을 끌 수 있게 합니다', en: 'Lets the title bar be dragged' }
    },
    {
      name: 'resizable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '가장자리와 모서리를 끌 수 있게 합니다',
        en: 'Lets the edges and corners be dragged'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      description: { ko: '창의 너비', en: 'The window’s width' }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: '창의 높이. 없으면 담긴 것만큼입니다',
        en: 'And its height. Left out, the window is as tall as what is in it'
      }
    },
    {
      name: 'minWidth',
      type: 'number',
      default: '180',
      description: {
        ko: '끌어서 줄일 수 있는 최소 너비(px)',
        en: 'How small it may be dragged, in pixels'
      }
    },
    {
      name: 'minHeight',
      type: 'number',
      description: {
        ko: '최소 높이. 기본값은 제목표시줄 자신의 높이입니다',
        en: 'The same downward. Defaults to the title bar’s own height'
      }
    },
    {
      name: 'offset',
      type: '{ x: number; y: number }',
      description: {
        ko: '레이아웃이 놓아준 자리에서 얼마나 끌려왔는지',
        en: 'How far it has been dragged from where the layout put it'
      }
    },
    {
      name: 'defaultOffset',
      type: '{ x: number; y: number }',
      default: '{ x: 0, y: 0 }',
      description: {
        ko: '제어하지 않을 때 시작하는 자리',
        en: 'Where an uncontrolled window starts'
      }
    },
    {
      name: 'onOffsetChange',
      type: '(offset: { x: number; y: number }) => void',
      description: { ko: '끌리는 동안 호출됩니다', en: 'Called while the window is dragged' }
    },
    {
      name: 'onResize',
      type: '(size: { width: number; height: number }) => void',
      description: {
        ko: '가장자리를 끄는 동안 창의 픽셀 크기와 함께 호출됩니다',
        en: 'Fires with the window’s size, in pixels, while an edge is dragged'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '창이 화면에 있는지. 닫히면 아무것도 렌더링하지 않습니다',
        en: 'Whether the window is on screen at all. Closing it renders nothing'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'true',
      description: { ko: '제어하지 않을 때의 시작 상태', en: 'Where an uncontrolled window starts' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '닫기를 눌렀을 때', en: 'Called when the close button is pressed' }
    },
    {
      name: 'minimized',
      type: 'boolean',
      description: {
        ko: '제목표시줄만 남기고 말아 올렸는지. 페이지에는 창을 보낼 독이 없으므로 최소화는 이 뜻입니다',
        en: 'Whether the window is rolled up to its title bar. A page has no dock to send it to, so this is what minimizing means'
      }
    },
    {
      name: 'defaultMinimized',
      type: 'boolean',
      default: 'false',
      description: { ko: '제어하지 않을 때의 시작 상태', en: 'Where an uncontrolled window starts' }
    },
    {
      name: 'onMinimizedChange',
      type: '(minimized: boolean) => void',
      description: { ko: '최소화를 눌렀을 때', en: 'Called when the minimize button is pressed' }
    },
    {
      name: 'maximized',
      type: 'boolean',
      description: {
        ko: '담고 있는 것을 가득 채우는지. 그동안 모서리는 각져집니다',
        en: 'Whether the window fills whatever is holding it. Its corners go square while it does'
      }
    },
    {
      name: 'defaultMaximized',
      type: 'boolean',
      default: 'false',
      description: { ko: '제어하지 않을 때의 시작 상태', en: 'Where an uncontrolled window starts' }
    },
    {
      name: 'onMaximizedChange',
      type: '(maximized: boolean) => void',
      description: {
        ko: '최대화를 눌렀을 때, 그리고 제목표시줄을 더블클릭했을 때',
        en: 'Called when the maximize button is pressed, and on a double click of the title bar'
      }
    },
    {
      name: 'scroll',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '창보다 큰 내용이 스크롤될지',
        en: 'Whether content taller than the window scrolls'
      }
    },
    {
      name: 'locale',
      type: 'string',
      description: {
        ko: '제목표시줄 버튼이 자기 이름을 말하는 언어(BCP 47)',
        en: 'Which language the title bar’s buttons name themselves in — a BCP 47 tag'
      }
    },
    {
      name: 'minimizeLabel',
      type: 'string',
      description: { ko: '최소화 버튼의 이름', en: 'The minimize button’s own name' }
    },
    {
      name: 'maximizeLabel',
      type: 'string',
      description: { ko: '최대화 버튼의 이름', en: 'The maximize button’s own name' }
    },
    {
      name: 'restoreLabel',
      type: 'string',
      description: {
        ko: '창이 최대화된 동안 그 버튼이 불리는 이름',
        en: 'And what that button is called while the window is maximized'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      description: { ko: '닫기 버튼의 이름', en: 'The close button’s own name' }
    },
    {
      name: 'resizeLabel',
      type: 'string',
      description: {
        ko: '키보드로 크기를 바꾸는 모서리의 이름',
        en: 'The name of the corner a keyboard resizes with'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div 대신 다른 요소로 렌더링합니다 (render={<section />})',
        en: 'Renders something other than a div (render={<section />})'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '창 안에 있는 것', en: 'What is in the window' }
    }
  ],

  Mockup: [
    {
      name: 'device',
      type: "'desktop' | 'tablet' | 'mobile'",
      required: true,
      description: {
        ko: '무엇을 그린 그림인지. 형태와 해상도 사다리, 고를 수 있는 시스템이 여기서 정해집니다',
        en: 'Which machine this is a picture of. It picks the shape, the resolution ladder and which systems are on offer'
      }
    },
    {
      name: 'os',
      type: "'macos' | 'windows' | 'linux' | 'ios' | 'ipados' | 'android'",
      default: "device's own",
      description: {
        ko: '화면에 크롬을 그릴 시스템. 데스크톱은 macos·windows·linux, 태블릿은 ipados·android, 휴대폰은 ios·android입니다. 그 기기가 돌리지 않는 값은 기본값으로 되돌아갑니다',
        en: 'The system whose chrome is drawn. A desktop runs macos, windows or linux; a tablet ipados or android; a phone ios or android. Anything else falls back to the device default'
      }
    },
    {
      name: 'hardware',
      type: "'monitor' | 'laptop'",
      default: "'monitor'",
      description: {
        ko: '데스크톱 화면을 받치는 것 — 아래의 받침대인지 앞의 키보드인지. 태블릿과 휴대폰에서는 무시됩니다',
        en: 'What holds a desktop screen up: a stand under it, or a keyboard in front of it. Ignored on a tablet and a phone'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '기기의 크기 — 기기별 실제 해상도 다섯 단계. Box에서처럼 높이도 타입 스케일도 아닙니다',
        en: 'How big the device is, on a five-step ladder of real resolutions per device. As on Box, it is neither a height nor a type scale'
      }
    },
    {
      name: 'resolution',
      type: '{ width: number; height: number }',
      description: {
        ko: '화면의 논리 해상도(CSS 픽셀). 다섯 단계 중 맞는 것이 없을 때 씁니다. 패널의 물리 픽셀 수가 아니라 내용이 배치되는 viewport입니다',
        en: "The screen's logical resolution in CSS pixels, when none of the five steps is the machine you mean. The viewport the content lays out against, not the panel's physical pixel count"
      }
    },
    {
      name: 'orientation',
      type: "'portrait' | 'landscape'",
      default: "'portrait'",
      description: {
        ko: '손에 드는 기기를 돌립니다. 화면과 bezel과 구멍이 함께 돌아갑니다. 데스크톱에서는 무시됩니다',
        en: 'Which way a handheld is held. The screen, the bezel and the cut-out turn together. Ignored on a desktop'
      }
    },
    {
      name: 'bezel',
      type: "'none' | 'thin' | 'standard' | 'thick'",
      default: "'standard'",
      description: {
        ko: '화면을 둘러싼 하드웨어의 양. none은 얇은 테두리가 아니라 하드웨어 없음이고, thick은 위아래가 넓은 옛날 기기입니다',
        en: 'How much hardware there is around the screen. none is no hardware at all rather than a thinner frame; thick is an older device with a forehead and a chin'
      }
    },
    {
      name: 'finish',
      type: "'graphite' | 'silver' | 'white'",
      default: "'graphite'",
      description: {
        ko: '하드웨어의 재질. 테마 토큰이 아니라 고정된 색이므로 dark로 바뀌어도 그대로입니다',
        en: 'What the hardware is made of. Fixed colours rather than theme tokens, so it stays the same on a page switched to dark'
      }
    },
    {
      name: 'notch',
      type: "'none' | 'notch' | 'dynamic-island' | 'punch-hole'",
      default: "device's own",
      description: {
        ko: '카메라 구멍. 크롬이 아니라 하드웨어이므로 systemUi를 꺼도 그려집니다. 기본값은 그 기기가 실제로 가졌을 것입니다',
        en: 'The camera cut-out. Hardware rather than chrome, so it is drawn even with systemUi off. Defaults to what the device would have'
      }
    },
    {
      name: 'systemUi',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '시스템 자신의 바 — 상태바와 home indicator, 메뉴 바와 dock, 작업 표시줄. 각 바는 내용을 덮지 않고 자기 자리를 차지합니다',
        en: "The system's own bars: a status bar and a home indicator, a menu bar and a dock, a taskbar. Each takes its own space rather than covering the content"
      }
    },
    {
      name: 'scroll',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '화면보다 긴 내용이 스크롤되는지. 꺼져 있으면 잘리며, 기기의 정지된 사진이 원하는 것이 그것입니다',
        en: 'Whether content taller than the screen scrolls. Off it is clipped, which is what a still picture of a device wants'
      }
    },
    {
      name: 'wallpaper',
      type: 'string',
      default: '페이지의 surface 색',
      description: {
        ko: '내용 뒤에 놓이는 것. 색, gradient, url() 등 임의의 CSS background 값',
        en: 'What is behind the content: any CSS background value — a colour, a gradient, a url()'
      }
    },
    {
      name: 'time',
      type: 'string',
      default: "'9:41'",
      description: {
        ko: '상태바나 작업 표시줄의 시계이자 크롬이 그리는 유일한 글자. Date가 아니라 문자열입니다 — 진짜 시각을 읽으면 서버와 브라우저가 어긋납니다',
        en: 'The clock in the status bar or the taskbar, and the only text the chrome draws. A string rather than a Date: reading the real one would differ between the server and the browser'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: '기기가 페이지에 그려지는 너비. 숫자는 픽셀입니다. 화면은 자기 해상도를 유지하고 기기 전체가 여기에 맞춰 축소됩니다',
        en: 'The rendered width of the device on the page. Numbers are pixels. The screen keeps its own resolution and the whole device is scaled to fit'
      }
    },
    {
      name: 'height',
      type: 'number | string',
      description: {
        ko: '그려지는 높이. 혼자 주면 너비가 기기의 비율을 따릅니다',
        en: "The rendered height. Given on its own, the width follows the device's proportion"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '크롬의 강조색 — dock이나 작업 표시줄의 첫 아이콘',
        en: "The accent in the chrome: a dock's first icon, a taskbar's"
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: {
        ko: '기기가 페이지에서 떠 있는 높이. 상자가 아니라 실루엣으로 그려지며 기기와 함께 줄어들지 않습니다',
        en: 'How far off the page the device sits. Drawn as a silhouette rather than a box, and it does not shrink with the device'
      }
    },
    transitionProp('transition="fade"'),
    renderProp('render={<figure />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '화면에 놓이는 것', en: 'What is on the screen' }
    }
  ],
  ColorPicker: [
    {
      name: 'value',
      type: 'string',
      description: {
        ko: 'CSS 색상 문자열. 직접 제어할 때 씁니다',
        en: 'The colour, as a CSS string. Pass it to drive the picker yourself'
      }
    },
    {
      name: 'defaultValue',
      type: 'string',
      default: "'#1a58d1'",
      description: { ko: '제어하지 않을 때의 시작 색', en: 'Where an uncontrolled picker starts' }
    },
    {
      name: 'onValueChange',
      type: '(value: string) => void',
      description: {
        ko: 'format이 정한 표기로 새 색을 전달합니다',
        en: 'Called with the new colour, written in format'
      }
    },
    {
      name: 'format',
      type: "'hex' | 'rgb' | 'hsl'",
      default: "'hex'",
      description: {
        ko: '값을 내보낼 때의 표기법',
        en: 'Which notation the value is written in on the way out'
      }
    },
    {
      name: 'alpha',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '불투명도 레일을 추가하고 값에 네 번째 채널을 싣습니다',
        en: 'Offers an opacity rail, and lets the value carry a fourth channel'
      }
    },
    {
      name: 'swatches',
      type: 'readonly string[] | false',
      description: {
        ko: '패널 아래의 기본 색들. false면 그리지 않고, 배열이면 내장 세트를 대체합니다',
        en: 'The ready-made colours under the panel. false draws none; an array replaces the built-in set'
      }
    },
    {
      name: 'inline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '팝업 대신 페이지에 패널을 직접 그립니다. 트리거는 없습니다',
        en: 'Draws the panel in the page instead of in a popup, with no trigger'
      }
    },
    {
      name: 'editable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '패널 아래에 값을 직접 입력할 수 있는 필드',
        en: 'The field under the panel that the value can be typed into'
      }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: { ko: '값을 비우는 ×를 답니다', en: 'Offers the × that empties the control' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '팝업이 열려 있는지. onOpenChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether the popup is open. Use with onOpenChange for a controlled one'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음에 열린 채로 시작', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when the popup opens or closes' }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '접근성 이름들의 언어. BCP 47 태그(ko, pt-BR, zh-Hant). 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the accessible names are written in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    {
      name: 'labels',
      type: 'Partial<ColorPickerLabels>',
      description: {
        ko: '그 이름들을 하나씩 덮어씁니다. 색 사각형, 두 레일, 입력란, 스와치 묶음 — 글자가 없는 부분들의 이름입니다',
        en: 'Overrides for those names, one at a time — the square, the two rails, the field and the swatch grid all have no text on them'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: { ko: '폼과 함께 전송될 이름', en: 'Submits with a form under this name' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    ...fieldProps,
    ...inertProps,
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '트리거의 높이, 그리고 패널과 그 안 사각형의 크기',
        en: "The trigger's height, and the size of the panel and the square on it"
      },
      colorDescription: {
        ko: '테두리와 focus ring의 색 역할입니다. 고르는 색과는 무관합니다',
        en: 'The family of the edge and the focus ring. Nothing to do with the colour being chosen'
      }
    })
  ],

  Collapsible: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '시트의 무게. 컨테이너의 방식대로 색을 들이지 않습니다. text는 상자를 아예 그리지 않으므로 본문 속이나 Card 안의 fold에 맞습니다',
        en: 'Weight of the sheet, said the way a container says it — never dyed. `text` draws no sheet at all, which is what a fold inside running prose or inside a Card wants'
      },
      sizeDescription: {
        ko: '여백과 모서리, 그리고 제목과 본문의 타입 스케일',
        en: 'The scale of the padding and the radius, and the type scale of the title and the body'
      }
    }),
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '패널이 열려 있는지. 직접 제어할 때 씁니다',
        en: 'Whether the panel is showing. Pass it to drive the Collapsible yourself'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '제어하지 않을 때의 시작 상태',
        en: 'Where an uncontrolled Collapsible starts'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: {
        ko: 'trigger가 패널을 열거나 닫았을 때',
        en: 'Called when the trigger opens or closes the panel'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: 'trigger에 쓰이는 제목', en: 'The heading on the trigger' }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 한 단계 작고 흐린 글씨',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '제목 앞의 내용 — 아이콘, 상태 점, 개수',
        en: 'Content before the title — an icon, a status dot, a count'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '헤더 끝에 고정되는 컨트롤. trigger 바깥이라 따로 누를 수 있습니다',
        en: 'A control pinned to the end of the header, outside the trigger so it can be pressed on its own'
      }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '헤더를 여러분의 컨트롤로 통째로 갈아 끼웁니다. 넘긴 요소가 곧 trigger가 되어 클릭 핸들러와 aria-expanded, aria-controls를 받습니다',
        en: 'Replaces the header entirely with a control of your own. The element you pass becomes the trigger, and is handed the click handler, aria-expanded and aria-controls'
      }
    },
    {
      name: 'indicator',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '헤더 끝의 chevron. 상태에 따라 회전합니다',
        en: 'The chevron at the end of the header, turned to report the state'
      }
    },
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '패널 내용의 안쪽 여백. 가장자리까지 채워야 하는 것에는 끄면 됩니다',
        en: 'Inner padding around the panel’s content. Turn it off for something that should reach the edges'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. trigger가 응답을 멈춥니다',
        en: 'Unavailable. The trigger stops answering'
      }
    },
    {
      name: 'hiddenUntilFound',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남겨 브라우저의 페이지 내 찾기가 찾아 열 수 있게 합니다. keepMounted보다 우선합니다',
        en: 'Keeps a closed panel in the DOM so the browser’s own page search can find and open it. Overrides keepMounted'
      }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남깁니다. 만드는 비용이 크거나 폼 상태를 쥐고 있는 내용에',
        en: 'Keeps a closed panel in the DOM. For content that is expensive to build, or that holds form state'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '본문', en: 'The body' }
    }
  ],

  Rating: [
    {
      name: 'value',
      type: 'number',
      description: {
        ko: '지금 점수. onValueChange와 함께 제어할 때 씁니다',
        en: 'How much is rated. Use with onValueChange for a controlled Rating'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      default: '0',
      description: { ko: '제어하지 않을 때의 시작 점수', en: 'Where an uncontrolled Rating starts' }
    },
    {
      name: 'onValueChange',
      type: '(value: number) => void',
      description: {
        ko: '새 점수와 함께 호출됩니다. 지워진 Rating은 0을 보고합니다',
        en: 'Called with the new score. 0 is what a cleared Rating reports'
      }
    },
    {
      name: 'count',
      type: 'number',
      default: '5',
      description: {
        ko: '별의 개수이자 만점',
        en: 'How many stars there are, and therefore the highest score'
      }
    },
    {
      name: 'precision',
      type: 'number',
      default: '1',
      description: {
        ko: '고를 수 있는 최소 단위. 0.5면 반 개씩입니다. 고르는 범위만 정할 뿐, 4.3 같은 평균값은 언제나 그대로 그려집니다',
        en: 'The smallest step that can be chosen — 0.5 gives half stars. It bounds what a reader can pick and nothing else: a value of 4.3 is drawn as 4.3 at every precision'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '채워진 별을 그리는 글리프', en: 'The glyph a filled star is drawn with' }
    },
    {
      name: 'emptyIcon',
      type: 'ReactNode',
      description: {
        ko: '빈 별을 그리는 글리프. 채워진 쪽과 같은 모양이어야 합니다',
        en: 'And the one an empty star is drawn with. Has to be the same shape'
      }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '이미 고른 점수를 다시 고르면 0으로 지웁니다',
        en: 'Choosing the score that is already chosen clears it back to 0'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '바꿀 수 없는 점수 — 평균 별점, 남이 남긴 평가. input이 사라지고 role="img" 하나만 남으며, 라이브러리에서 유일하게 채도를 빼지 않는 readOnly입니다',
        en: 'Shows the score without letting it be changed — an average, somebody else’s rating. The inputs go and one role="img" is left; the one readOnly in the library that does not drain the saturation'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
        en: 'Unavailable. Drops the colour family for neutral grey'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 전송 시 값을 식별합니다',
        en: 'Identifies the value when a form is submitted'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '별을 고르기 전에는 폼이 제출되지 않습니다',
        en: 'A form will not submit until a star has been chosen'
      }
    },
    ...scaleProps("'md'", "'warning'", {
      ko: '의미론적 색 역할. 기본값이 warning인 유일한 컴포넌트입니다 — 별에 기대되는 호박색이기 때문입니다',
      en: 'Semantic colour role. warning by default — the amber a star is expected to be — which makes this the one component whose default colour is chosen by what the object is'
    }),
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '접근성 이름의 언어. BCP 47 태그(ko, pt-BR, zh-Hant). 모르는 태그는 영어로 돌아갑니다',
        en: 'Which language the accessible names are written in — a BCP 47 tag. Unsupported tags fall back to English'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '컨트롤 전체의 이름. 기본값은 locale이 정합니다',
        en: 'Names the whole control. Defaults to the locale’s word for "Rating"'
      }
    },
    {
      name: 'valueLabel',
      type: '(value: number, count: number) => string',
      description: {
        ko: '별 하나와, readOnly일 때 컨트롤 전체를 뭐라고 부를지. 기본값은 locale의 "5점 만점에 3점"입니다',
        en: 'What one star, and the whole control once it is read only, is called. Defaults to the locale’s way of saying "3 out of 5"'
      }
    }
  ],

  BottomNavigation: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '바의 무게. 컨테이너의 방식대로 시트에 색을 들이지 않습니다 — 색 계열을 입는 것은 지금 있는 목적지 하나뿐입니다',
        en: 'Weight of the bar, said the way a container says it — the sheet is never dyed. What carries the colour family is the one item that is current'
      },
      sizeDescription: {
        ko: '행의 최소 높이와 글리프, 이름의 스케일. md는 56px입니다',
        en: 'The row’s floor and the scale of the glyph and the name. md is 56px'
      },
      elevationDescription: {
        ko: '그림자 깊이. 기본이 0입니다 — 바는 창 가장자리에 붙어 있지 떠 있지 않고, 내용과의 구분은 divider가 합니다',
        en: 'Drop shadow depth. 0 by default: the bar is attached to the edge of the window rather than floating over it, and divider is what separates it from the content'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '지금 있는 목적지. onValueChange와 함께 제어할 때 씁니다',
        en: 'The destination the reader is on. Use with onValueChange for a controlled bar'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: {
        ko: '제어하지 않을 때 처음 선택되는 목적지',
        en: 'Which starts current, for an uncontrolled bar'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number) => void',
      description: {
        ko: '눌린 목적지와 함께 호출됩니다',
        en: 'Called with the destination that was pressed'
      }
    },
    {
      name: 'position',
      type: POSITION,
      default: "'fixed'",
      shared: true,
      description: {
        ko: '페이지 스크롤 안에서 어떻게 앉는지. 다른 컴포넌트와 달리 fixed가 기본입니다 — 하단 내비게이션은 창 아래 가장자리에 고정되는 것이기 때문입니다',
        en: 'How the bar sits in the page’s scroll. fixed by default, against the static everything else defaults to: a bottom navigation is held against the bottom edge of the window'
      }
    },
    {
      name: 'labels',
      type: "'all' | 'selected' | 'none'",
      default: "'all'",
      description: {
        ko: '어떤 이름을 그릴지. 그리지 않은 이름도 문서에는 남아 스크린 리더가 읽습니다',
        en: 'Which names are drawn. An undrawn name is still in the document for a screen reader'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '내용을 마주 보는 위쪽 가장자리에 헤어라인을 긋습니다. Toolbar와 반대로 기본이 켜짐입니다',
        en: 'Draws a hairline along the top edge, against the content. On by default, the other way round from Toolbar'
      }
    },
    {
      name: 'safeArea',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'env(safe-area-inset-bottom)만큼 아래를 띄워 홈 인디케이터를 피합니다. 시트는 화면 아래 끝까지 그대로 닿습니다',
        en: 'Keeps the bar clear of the home indicator by adding env(safe-area-inset-bottom) under it. The sheet still reaches the bottom of the screen'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 목적지가 응답을 멈춥니다', en: 'Every destination stops answering' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '바가 읽히는 이름 — "Main", "Sections"',
        en: 'The name the bar is announced by — "Main", "Sections"'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'nav 대신 다른 요소로 렌더링합니다 (render={<footer />}). Base UI의 render prop 그대로이며, 여기서는 거의 필요하지 않습니다 — 목적지의 줄은 내비게이션입니다',
        en: 'Renders something other than a nav (render={<footer />}). Base UI’s own escape hatch, and rarely what you want here: a row of destinations is navigation'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'BottomNavigationItem들', en: 'The BottomNavigationItems' }
    }
  ],

  BottomNavigationItem: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '목적지를 식별합니다. onValueChange가 보고하는 값',
        en: 'Identifies the destination. What onValueChange reports'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '이름 위의 글리프', en: 'The glyph above the name' }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '버튼 대신 링크로 렌더링합니다',
        en: 'Renders the item as a link rather than as a button'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 자리는 지킵니다',
        en: 'Unavailable, but still part of the set'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '목적지의 이름. labels가 그리지 않을 때에도 읽힙니다',
        en: 'The destination’s name. Read out even when labels keeps it undrawn'
      }
    }
  ],

  FloatingBottomNavigation: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      elevation: '2',
      variantDescription: {
        ko: '시트의 무게. 컨테이너의 방식대로 색을 들이지 않으며, 페이지 위에 떠 있는 만큼 헤어라인이 있는 outline이 기본입니다',
        en: 'Weight of the sheet, said the way a container says it — never dyed. outline is the default here because the bar is over the page rather than against its edge'
      },
      sizeDescription: {
        ko: '행의 최소 높이와 글리프, 이름의 스케일. BottomNavigation과 같은 사다리로, md는 56px입니다',
        en: 'The row’s floor and the scale of the glyph and the name. The same ladder BottomNavigation is on: md is 56px'
      },
      elevationDescription: {
        ko: '그림자 깊이. Pill과 같은 이유로 기본이 2입니다 — 이 바는 페이지의 일부가 아니라 그 위에 떠 있습니다',
        en: 'Drop shadow depth. 2 for the reason Pill’s is: this bar is not part of the page, it hovers over it'
      }
    }),
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '지금 있는 목적지. onValueChange와 함께 제어할 때 씁니다',
        en: 'The destination the reader is on. Use with onValueChange for a controlled bar'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: {
        ko: '제어하지 않을 때 처음 선택되는 목적지',
        en: 'Which starts current, for an uncontrolled bar'
      }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number) => void',
      description: {
        ko: '눌린 목적지와 함께 호출됩니다',
        en: 'Called with the destination that was pressed'
      }
    },
    {
      name: 'position',
      type: `${POSITION} | 'absolute'`,
      default: "'fixed'",
      shared: true,
      description: {
        ko: '페이지 스크롤 안에서 어떻게 앉는지. absolute는 창이 아니라 가장 가까운 positioned 조상에 붙입니다 — FloatingActionButton과 같은 확장입니다',
        en: 'How the bar sits in the page’s scroll. absolute holds it against the nearest positioned ancestor rather than the window — the same addition FloatingActionButton makes'
      }
    },
    {
      name: 'offset',
      type: 'number | string',
      default: '16',
      description: {
        ko: '아래 가장자리에서 얼마나 떠 있는지. BottomNavigation과의 차이 전부가 여기서 나옵니다 — 그 아래로 페이지가 계속 이어집니다',
        en: 'How far the bar floats above the bottom edge. This is the whole difference from BottomNavigation: the page keeps going underneath'
      }
    },
    {
      name: 'labels',
      type: "'all' | 'selected' | 'none'",
      default: "'selected'",
      description: {
        ko: '어떤 이름을 그릴지. 전체 너비 바의 all과 달리 기본이 selected입니다 — 담긴 것만큼만 넓은 바에서 이름 다섯 개는 화면을 가로지릅니다. 그리지 않은 이름도 문서에는 남습니다',
        en: 'Which names are drawn. selected here, against the all a full-width bar defaults to: this bar is only as wide as what is in it. An undrawn name is still in the document'
      }
    },
    {
      name: 'safeArea',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'offset에 env(safe-area-inset-bottom)을 더합니다. 시트 전체가 올라갑니다 — 아래에 덮어야 할 것이 없기 때문입니다',
        en: 'Adds env(safe-area-inset-bottom) to offset. The whole sheet moves up: there is nothing under it to keep covered'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '모든 목적지가 응답을 멈춥니다', en: 'Every destination stops answering' }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '바가 읽히는 이름 — "Main", "Sections"',
        en: 'The name the bar is announced by — "Main", "Sections"'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'nav 대신 다른 요소로 렌더링합니다. 여기서는 거의 필요하지 않습니다',
        en: 'Renders something other than a nav. Rarely what you want here'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'BottomNavigationItem들 — 두 바가 같은 항목을 씁니다',
        en: 'The BottomNavigationItems. The same item both bars take'
      }
    }
  ],

  FloatingActionButton: [
    ...sharedProps({
      variant: "'solid'",
      size: "'lg'",
      elevation: '2',
      sizeDescription: {
        ko: '높이. 사다리는 Button과 같고 시작점만 한 칸 위입니다 — 보지 않고 엄지로 찾아 누르는 유일한 컨트롤이기 때문입니다',
        en: 'Height. The same ladder a Button is on, started a step up: this is the one control that has to be found and hit with a thumb without being looked at'
      },
      elevationDescription: {
        ko: '그림자 깊이. Pill과 같은 이유로 기본이 2입니다 — 이 버튼은 페이지의 일부가 아니라 그 위에 떠 있습니다',
        en: 'Drop shadow depth. 2 for the reason Pill’s is: this button is not part of the page, it hovers over it'
      }
    }),
    {
      name: 'icon',
      type: 'ReactNode',
      default: 'a plus',
      description: { ko: '버튼의 글리프', en: 'The glyph on the button' }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '버튼이 무엇을 하는지, 말로. 필수입니다 — 그림만으로 된 버튼은 접근성 이름이 아예 없습니다. extended일 때는 버튼에 쓰이는 말이기도 합니다',
        en: 'What the button does, in words. Required: a button whose whole label is a drawing has no accessible name at all. With extended it is also the word written on it'
      }
    },
    {
      name: 'extended',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'label을 글리프 옆에 씁니다. 원이 스타디움이 됩니다',
        en: 'Writes label beside the glyph, which turns the disc into a stadium'
      }
    },
    {
      name: 'openIcon',
      type: 'ReactNode',
      description: {
        ko: '다이얼이 열려 있는 동안의 글리프. 액션이 있으면 기본이 ×입니다. icon과 같은 노드를 넘기면 바뀌지 않습니다',
        en: 'The glyph while the dial is open. Defaults to a × when the button has actions; pass the same node as icon to keep it unchanged'
      }
    },
    {
      name: 'position',
      type: "'static' | 'sticky' | 'fixed' | 'absolute'",
      default: "'fixed'",
      description: {
        ko: '어디에 앉는지. fixed는 창의 모서리에, absolute는 가장 가까운 positioned 조상의 모서리에 고정합니다',
        en: 'How it sits. fixed pins it to a corner of the window; absolute pins it to a corner of the nearest positioned ancestor'
      }
    },
    {
      name: 'corner',
      type: "'top-start' | 'top-end' | 'bottom-start' | 'bottom-end'",
      default: "'bottom-end'",
      shared: true,
      description: { ko: '어느 모서리에 붙는지', en: 'Which corner it is pinned to' }
    },
    {
      name: 'offset',
      type: 'number | string',
      default: '16',
      description: {
        ko: '양쪽 가장자리에서 얼마나 안쪽인지. CSS 길이 또는 픽셀 수',
        en: 'How far in from both edges, as a CSS length or a number of pixels'
      }
    },
    {
      name: 'direction',
      type: "'top' | 'bottom'",
      description: {
        ko: '액션이 펼쳐지는 방향. 지정하지 않으면 corner에서 가져옵니다',
        en: 'Which way the actions fan out. Taken from corner when it is left out'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '다이얼이 열려 있는지. 직접 제어할 때',
        en: 'Whether the dial is open. Use with onOpenChange for a controlled dial'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '제어하지 않을 때의 시작 상태', en: 'Where an uncontrolled dial starts' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '다이얼이 열리거나 닫혔을 때', en: 'Called when the dial opens or closes' }
    },
    {
      name: 'openOnHover',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마우스가 버튼에 머무르면 다이얼을 엽니다. 터치와 펜은 제외됩니다',
        en: 'Opens the dial when a mouse comes to rest on the button. Touch and pen are excluded'
      }
    },
    {
      name: 'closeOnAction',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '액션을 누르면 다이얼을 닫습니다',
        en: 'Closes the dial when one of the actions is pressed'
      }
    },
    {
      name: 'showLabels',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '각 액션의 이름을 옆의 로젠지에 그립니다. 꺼도 이름은 그대로 읽힙니다',
        en: 'Draws each action’s name on a lozenge beside it. Turned off, the names are still read out'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '버튼과 모든 액션이 응답을 멈춥니다',
        en: 'Unavailable. The button and every action stop answering'
      }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler<HTMLButtonElement>',
      description: {
        ko: '버튼을 눌렀을 때. 액션이 있어도 그대로 발생하며, 그때는 누름이 다이얼도 여닫습니다',
        en: 'Fires when the button is pressed. It still fires when the button has actions, where the press also opens and closes the dial'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'FloatingAction들, 있다면', en: 'The FloatingActions, if there are any' }
    }
  ],

  FloatingAction: [
    {
      name: 'icon',
      type: 'ReactNode',
      description: { ko: '글리프', en: 'The glyph' }
    },
    {
      name: 'label',
      type: 'string',
      required: true,
      description: {
        ko: '액션이 무엇을 하는지, 말로. 옆에 그려지고 언제나 읽힙니다',
        en: 'What the action does, in words. Drawn beside it, and always read out'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 다이얼에는 남습니다',
        en: 'Unavailable, but still part of the dial'
      }
    },
    {
      name: 'onClick',
      type: 'MouseEventHandler<HTMLButtonElement>',
      description: { ko: '액션을 눌렀을 때', en: 'Fires when the action is pressed' }
    }
  ],

  AnimateFade: [
    {
      name: 'from',
      type: 'number',
      default: '0',
      description: {
        ko: '시작 불투명도, 0에서 1 사이',
        en: 'The opacity it starts from, between 0 and 1'
      }
    },
    ...animateProps({ duration: '320' }),
    renderProp('render={<section />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '나타나거나 사라지는 것', en: 'What arrives or leaves' }
    }
  ],

  AnimateGrow: [
    {
      name: 'from',
      type: 'number',
      default: '0.8',
      description: {
        ko: '최종 크기에 대한 시작 배율. 1보다 크면 커진 채로 등장해 제자리로 내려앉습니다',
        en: 'The scale it starts from, as a multiple of its final size. Above 1 it settles down onto the page'
      }
    },
    {
      name: 'origin',
      type: 'string',
      default: "'center'",
      description: {
        ko: '펼쳐지는 기준점. CSS transform-origin 그대로입니다',
        en: 'Which point stays put while the rest moves — any CSS transform-origin'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '커지면서 함께 페이드인합니다',
        en: 'Fades in as it grows'
      }
    },
    ...animateProps({ duration: '340' }),
    renderProp('render={<li />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '펼쳐지는 것', en: 'What unfolds' }
    }
  ],

  AnimateZoom: [
    {
      name: 'from',
      type: 'number',
      default: '0.4',
      description: {
        ko: '최종 크기에 대한 시작 배율. 1보다 크면 앞에서 다가와 제자리에 놓입니다',
        en: 'The scale it starts from. Above 1 it arrives oversized and settles back, which reads as coming towards the reader'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: { ko: '확대되면서 함께 페이드인합니다', en: 'Fades in as it zooms' }
    },
    ...animateProps({ duration: '340' }),
    renderProp('render={<section />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '다가오는 것', en: 'What comes forward' }
    }
  ],

  AnimateSlide: [
    {
      name: 'from',
      type: SIDE,
      default: "'bottom'",
      shared: true,
      description: {
        ko: '어느 변에서 들어오는지. NebaSide가 어디서나 그렇듯 물리적입니다',
        en: 'Which edge it travels from. Physical, as NebaSide is everywhere'
      }
    },
    {
      name: 'distance',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: '이동 거리 — CSS 길이 또는 픽셀 수. 100%는 자기 자신의 크기입니다',
        en: "How far it travels — a CSS length, or a number in pixels. '100%' is the element's own size"
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: { ko: '이동하면서 함께 페이드인합니다', en: 'Fades in as it slides' }
    },
    ...animateProps({ duration: '380' }),
    renderProp('render={<aside />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '미끄러져 들어오는 것', en: 'What travels in' }
    }
  ],

  AnimateRotate: [
    {
      name: 'from',
      type: 'number',
      default: '-180',
      description: {
        ko: '시작 각도(도). 음수는 반시계 방향',
        en: 'The angle it starts at, in degrees. Negative is anticlockwise'
      }
    },
    {
      name: 'to',
      type: 'number',
      default: '0',
      description: {
        ko: '끝 각도(도). from과 함께 쓰면 하나의 컴포넌트가 제자리에 안착하는 회전과 끝없는 회전을 모두 표현합니다',
        en: 'The angle it ends at. Together with from this covers both a turn into place and an endless spin'
      }
    },
    {
      name: 'origin',
      type: 'string',
      default: "'center'",
      description: {
        ko: '회전축. CSS transform-origin 그대로입니다',
        en: 'Which point it turns about — any CSS transform-origin'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '회전하면서 함께 페이드인합니다. 계속 도는 경우에는 꺼야 합니다',
        en: 'Fades in as it turns. Turn it off for a continuous spin'
      }
    },
    ...animateProps({ duration: '460' }),
    renderProp('render={<span />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '회전하는 것', en: 'What turns' }
    }
  ],

  AnimateBlink: [
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: {
        ko: '가장 흐릴 때의 불투명도, 0에서 1 사이',
        en: 'How faint it gets at the bottom of the cycle, between 0 and 1'
      }
    },
    ...animateProps({ duration: '900', repeat: "'infinite'", mode: false }),
    renderProp('render={<span />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '깜박이는 것', en: 'What pulses' }
    }
  ],

  AnimateAppear: [
    {
      name: 'stagger',
      type: 'number',
      default: '80',
      description: {
        ko: '자식 하나와 다음 자식 사이의 간격(ms). 이 효과 자체입니다',
        en: 'How long after one child the next one starts, in milliseconds. This is the whole effect'
      }
    },
    {
      name: 'from',
      type: SIDE,
      default: "'bottom'",
      shared: true,
      description: { ko: '각 자식이 밀려 들어오는 변', en: 'Which edge each child drifts in from' }
    },
    {
      name: 'distance',
      type: 'number | string',
      default: "'0.75rem'",
      description: {
        ko: '각 자식의 이동 거리. 화면 밖에서 들어오는 것이 아니라 제자리에 내려앉는 정도로 짧습니다',
        en: 'How far each child travels. Short on purpose: this is a settling, not an entrance from off screen'
      }
    },
    {
      name: 'fade',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '내려앉으면서 함께 페이드인합니다',
        en: 'Fades each child in as it settles'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '마지막 자식부터 실행합니다',
        en: 'Runs the list from the last child to the first'
      }
    },
    ...animateProps({ duration: '420', mode: false }),
    renderProp('render={<ul />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '하나씩 나타나는 것들. 각 자식이 한 걸음입니다',
        en: 'The things that appear, one after another. Each child is one step'
      }
    }
  ],

  AnimateTyping: [
    {
      name: 'text',
      type: 'string',
      description: {
        ko: '타이핑할 문자열. children보다 우선합니다',
        en: 'The text, when it is easier to pass than to nest. Overrides children'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '24',
      description: { ko: '초당 글자 수', en: 'How fast it is typed, in characters per second' }
    },
    {
      name: 'hold',
      type: 'number',
      default: '1400',
      description: {
        ko: '다 쓴 뒤 반복 전까지 머무는 시간(ms)',
        en: 'How long the finished text is held before it repeats, in milliseconds'
      }
    },
    {
      name: 'erase',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '반복 전에 한 번에 지우지 않고 한 글자씩 지웁니다',
        en: 'Deletes the text again before repeating, rather than clearing it in one frame'
      }
    },
    {
      name: 'eraseSpeed',
      type: 'number',
      description: {
        ko: '지우는 속도(초당 글자 수). 기본값은 speed의 두 배',
        en: 'How fast it is deleted, in characters per second. Defaults to twice speed'
      }
    },
    {
      name: 'caret',
      type: 'boolean',
      default: 'true',
      description: { ko: '글자 뒤의 커서', en: 'The block after the text' }
    },
    {
      name: 'caretChar',
      type: 'ReactNode',
      default: "'|'",
      description: { ko: '커서로 그릴 것', en: 'What the caret is drawn as' }
    },
    ...animateProps({ duration: '—', mode: false }),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '타이핑할 텍스트. 텍스트만 타이핑됩니다 — 자식 중 요소가 있으면 그 안의 글자만 쓰이고 마크업은 무시됩니다',
        en: 'The text to type. Only text is typed — an element among the children contributes its text and nothing about its markup'
      }
    }
  ],

  AnimateLighting: [
    {
      name: 'glow',
      type: 'string',
      description: {
        ko: '의미론적 색이 아닌 임의의 CSS 색상. color보다 우선합니다',
        en: 'A CSS colour, when a semantic family is not what is wanted. Overrides color'
      }
    },
    {
      name: 'spread',
      type: 'number',
      default: '3',
      description: {
        ko: '내용 바깥으로 빛이 번지는 거리(px)',
        en: 'How far past the content the light reaches, in pixels'
      }
    },
    {
      name: 'arc',
      type: 'number',
      default: '50',
      description: {
        ko: '한 번에 밝아지는 호의 길이(도). 작으면 스치는 불꽃, 크면 훑는 빛입니다',
        en: 'How much of the outline is lit at once, in degrees. Small is a travelling spark; large is a sweep'
      }
    },
    {
      name: 'blur',
      type: 'number',
      default: '4',
      description: {
        ko: '빛의 부드러움(px). 0이면 빛이 아니라 도형처럼 보입니다',
        en: 'How soft the light is, in pixels. At 0 it reads as a graphic rather than as light'
      }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: { ko: '빛이 반대 방향으로 돕니다', en: 'Runs the light the other way round' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '빛이 따라가는 반경. 안에 든 것의 반경과 맞아야 합니다',
        en: 'The radius the light follows. It has to match what is inside'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '빛의 색 역할', en: 'Which family the light is drawn in' }
    },
    ...animateProps({ duration: '3000', repeat: "'infinite'", mode: false }),
    renderProp('render={<section />}'),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '빛이 둘러싸는 것', en: 'What the light travels around' }
    }
  ],

  AnimateMarquee: [
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: { ko: '흐르는 방향의 축', en: 'Which way the strip runs' }
    },
    {
      name: 'reverse',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '반대 방향으로 흐릅니다',
        en: 'Runs it the other way — left to right, or bottom to top'
      }
    },
    {
      name: 'speed',
      type: 'number',
      default: '60',
      description: {
        ko: '초당 이동 픽셀. 시간이 아니라 속도이므로, 짧은 띠와 긴 띠가 같은 속도로 흐릅니다',
        en: 'How fast the content travels, in pixels per second. A speed rather than a duration, so a short strip and a long one move at the same pace'
      }
    },
    {
      name: 'gap',
      type: 'number | string',
      default: "'2rem'",
      description: {
        ko: '항목 사이, 그리고 한 바퀴의 끝과 다음 시작 사이의 간격',
        en: 'The gap between items, and between the last item and the first of the next pass'
      }
    },
    {
      name: 'copies',
      type: 'number',
      default: '2',
      description: {
        ko: '이어 붙이는 복제본 수. 내용이 상자보다 짧아 빈 구간이 생길 때만 올리면 됩니다',
        en: 'How many copies are laid end to end. Raise it only when the content is short enough to leave a hole behind itself'
      }
    },
    {
      name: 'pauseOnHover',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '포인터가 올라가 있는 동안 멈춥니다. 지나가는 내용은 클릭할 수 없기 때문입니다',
        en: 'Stops while the pointer is on it, because content moving past a pointer cannot be clicked'
      }
    },
    ...animateProps({ duration: '—', repeat: "'infinite'", mode: false }),
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '흘러가는 것들', en: 'The things that scroll past' }
    }
  ],

  AnimateHeadline: [
    {
      name: 'interval',
      type: 'number',
      default: '2600',
      description: {
        ko: '한 줄이 머무는 시간(ms). 줄이 도착한 순간부터 세므로 읽는 시간입니다',
        en: 'How long each line is held, in milliseconds. Counted from the moment a line arrives, so it is reading time'
      }
    },
    {
      name: 'index',
      type: 'number',
      description: {
        ko: '지금 보이는 줄. 직접 제어할 때 씁니다',
        en: 'Which line is showing. Pass it to drive the reel yourself'
      }
    },
    {
      name: 'defaultIndex',
      type: 'number',
      default: '0',
      description: { ko: '제어하지 않을 때 시작하는 줄', en: 'Where an uncontrolled reel starts' }
    },
    {
      name: 'onIndexChange',
      type: '(index: number) => void',
      description: { ko: '새 줄이 올라왔을 때', en: 'Called with the line that has just come up' }
    },
    {
      name: 'loop',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 줄 다음에 처음으로 돌아갑니다. 끄면 마지막 줄에서 멈춥니다',
        en: 'Starts again after the last line. Off, the reel stops on the last one'
      }
    },
    {
      name: 'rise',
      type: 'number | string',
      default: "'100%'",
      description: {
        ko: '한 줄이 올라오거나 나가며 이동하는 거리. 100%는 한 줄의 높이입니다',
        en: "How far a line travels as it comes up or leaves. '100%' is one line's own height"
      }
    },
    ...animateProps({ duration: '480', repeat: "'infinite'", mode: false }),
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '읽히는 순서대로의 줄들',
        en: 'The lines, in the order they should be read'
      }
    }
  ],

  CodeBlock: [
    {
      name: 'code',
      type: 'string',
      required: true,
      description: {
        ko: '코드 자체. 문자열이라서 children이 아닌 prop입니다 — 템플릿 리터럴은 자기 들여쓰기를 유지하지만 JSX는 그것을 뭉갭니다. 끝의 빈 줄만 잘라냅니다',
        en: 'The code itself. A prop rather than children because it is a string: a template literal keeps its own indentation and JSX would collapse it. Only trailing blank lines are trimmed'
      }
    },
    {
      name: 'language',
      type: 'string',
      description: {
        ko: '무엇으로 쓰였는지 — ts, bash, yml, dockerfile. 흔한 표기와 파일 확장자를 알아듣습니다. 모르는 이름은 거부하지 않고 하이라이팅 없이 그립니다',
        en: 'What it is written in — ts, bash, yml, dockerfile. Common spellings and file extensions are understood; a name nothing here knows is drawn plain rather than refused'
      }
    },
    {
      name: 'theme',
      type: 'CodeBlockTheme | (string & {})',
      default: "'dark'",
      description: {
        ko: "블록이 입는 팔레트. 집안 것 넷 — dark, light, auto, mono — 과 공개된 값을 그대로 옮겨 온 여덟 — one-dark, dracula, monokai, nord, night-owl, gruvbox, github, solarized-light. auto를 뺀 나머지는 페이지의 light·dark와 무관합니다. 아무 문자열이나 받으므로, [data-code-theme='ours']에 --n-code-* 를 써 두면 그것이 곧 테마입니다",
        en: "The palette it wears. Four of the library's own — dark, light, auto, mono — and eight ports kept at their published values: one-dark, dracula, monokai, nord, night-owl, gruvbox, github, solarized-light. Independent of the page's light and dark except on auto. Any string works, so writing --n-code-* under [data-code-theme='ours'] in your own CSS is a theme"
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백. 어느 단계에서든 본문보다 한 칸 작습니다 — 고정폭 서체는 같은 크기여도 한 치수 커 보입니다',
        en: 'The type scale and the padding. One step under the running text at every size: a monospace face at the same nominal size reads a size larger'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '코드에는 닿지 않습니다. focus ring만 이 색을 씁니다 — 코드의 색은 theme의 것입니다',
        en: "It does not reach the code. Only the focus ring takes it: the code's colours are the theme's"
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 is no shadow at all'
      }
    },
    {
      name: 'highlight',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드에 색을 입힙니다. 꺼두면 아무것도 내려받지 않습니다 — 문법 엔진이 dynamic import 뒤에 있습니다. 켜져 있으면 첫 프레임은 색 없이 그려지고 문법이 도착하면 스스로 칠합니다',
        en: 'Colours the code. Off, nothing is fetched at all — the grammar engine is behind a dynamic import. On, the block draws plain on the first frame and colours itself when the grammar lands'
      }
    },
    {
      name: 'toolbar',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드 위의 바이자 그것의 주 스위치. 꺼두면 showLanguage·copyable·rawToggle이 무엇이라고 하든 아무것도 그려지지 않습니다',
        en: 'The bar over the code, and the master switch for it: with it off, showLanguage, copyable and rawToggle draw nothing whatever they say'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '바 맨 앞의 이름. 대개 파일 경로이며, 스크롤 영역의 접근성 이름이 되기도 합니다',
        en: "A name at the start of the bar — a file path, usually. It also becomes the scrollable region's accessible name"
      }
    },
    {
      name: 'showLanguage',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '바 앞쪽에 language를 적습니다',
        en: 'Names the language at the start of the bar'
      }
    },
    {
      name: 'copyable',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '코드를 클립보드에 넣는 버튼. 클립보드가 거부하면 그렇게 말합니다 — 평문 HTTP로 서빙되는 페이지가 대표적입니다',
        en: 'The button that puts the code on the clipboard. It says so when the clipboard refuses — a page served over plain HTTP, mostly'
      }
    },
    {
      name: 'rawToggle',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '하이라이팅을 걷어내고 문자를 있는 그대로 보여주는 토글. highlight가 꺼져 있으면 아무 의미가 없습니다',
        en: 'The toggle that drops the colouring and shows the characters as they are. It means nothing at all when highlight is off'
      }
    },
    {
      name: 'highlightLines',
      type: 'number | string | Array<number | string>',
      description: {
        ko: "표시할 줄. 숫자는 한 줄, 문자열은 줄과 범위의 목록('4', '4-9', '1,4-9,12'), 배열은 둘의 조합입니다. 거터가 세는 방식 그대로 세므로 startLine을 따릅니다. 틴트는 그 테마 자신의 잉크에서 섞여 나옵니다",
        en: "Lines to mark. A number is one line, a string is a list of lines and ranges ('4', '4-9', '1,4-9,12'), an array is any mix. Counted the way the gutter counts, so it follows startLine. The tint is mixed from the theme's own ink"
      }
    },
    {
      name: 'lineNumbers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '옆에 붙는 번호. 거터는 마지막 번호에 맞춰 잡히므로 스크롤해도 번호가 밀리지 않습니다',
        en: 'Numbers down the side. The gutter is sized for the last number, so it does not step as the block scrolls'
      }
    },
    {
      name: 'startLine',
      type: 'number',
      default: '1',
      description: {
        ko: '첫 줄에 매길 번호. 발췌한 코드가 실제로 시작하는 자리',
        en: 'What the first line is numbered — where an excerpt actually starts'
      }
    },
    {
      name: 'prompt',
      type: 'string',
      description: {
        ko: '내용이 있는 줄 앞의 셸 기호 — $, #, C:\\>, >>>. 그려지되 거기 있지는 않습니다: 생성된 콘텐츠라 선택도, 페이지 내 찾기도, 복사도 되지 않습니다',
        en: 'A shell symbol in front of every line that has something on it — $, #, C:\\>, >>>. Drawn but never present: it is generated content, so it cannot be selected, found or copied'
      }
    },
    {
      name: 'wrap',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '긴 줄을 가로 스크롤 대신 접습니다',
        en: 'Wraps long lines instead of scrolling them sideways'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '코드가 안에서 스크롤되기 전까지 블록이 커질 수 있는 높이. 숫자는 픽셀',
        en: 'How tall the block may get before the code scrolls inside it. Numbers are pixels'
      }
    },
    {
      name: 'fontFamily',
      type: 'string',
      default: 'font-mono',
      description: {
        ko: '서체. 기본은 페이지의 고정폭 스택',
        en: "The typeface. Defaults to the page's own monospace stack"
      }
    },
    {
      name: 'fontSize',
      type: 'number | string',
      default: 'size',
      description: {
        ko: 'size가 고른 크기를 덮어씁니다. 숫자는 픽셀',
        en: 'Overrides the size the size ladder chose. Numbers are pixels'
      }
    },
    {
      name: 'lineHeight',
      type: 'number | string',
      default: 'size',
      description: {
        ko: '행간. CSS에서처럼 맨숫자는 비율입니다',
        en: 'The leading. A bare number is a ratio, as in CSS'
      }
    },
    {
      name: 'letterSpacing',
      type: 'number | string',
      description: {
        ko: '자간. 숫자는 픽셀이고 -0.01em 같은 값도 됩니다',
        en: 'Tracking. Numbers are pixels, and -0.01em and the like work too'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '복사 버튼과 raw 토글, region 이름이 쓰이는 언어. 지원하지 않는 태그는 영어로 돌아갑니다',
        en: "Which language the copy button, the raw toggle and the region's name are in. Unsupported tags fall back to English"
      }
    },
    {
      name: 'copyLabel · copiedLabel · rawLabel',
      type: 'string',
      default: 'locale',
      description: { ko: '그 단어들을 직접 씁니다', en: 'Those words, written out' }
    },
    {
      name: 'onCopy',
      type: '(code: string) => void',
      description: {
        ko: '클립보드가 코드를 받아간 뒤 그 문자열과 함께 호출됩니다',
        en: 'Fires with the copied text once the clipboard has taken it'
      }
    }
  ],

  HowToSteps: [
    {
      name: 'steps',
      type: 'HowToStep[]',
      required: true,
      description: {
        ko: '해야 하는 순서대로의 단계들. children이 아니라 배열인 이유는, 옆의 목록과 본문이 같은 데이터를 두 번 그린 것이고 본문 높이가 지금 보이는 단계가 아니라 모든 단계에 맞춰 정해지기 때문',
        en: 'The steps, in the order they are to be done. An array rather than children because the list beside the body and the body itself are two renderings of the same data, and the panel is sized against every step rather than the one showing'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '안내서 자신의 제목. 두 열 위에 놓입니다',
        en: "The guide's own heading, over both columns"
      }
    },
    {
      name: 'step',
      type: 'number',
      description: {
        ko: '지금 보이는 단계. 직접 몰고 가려면 onStepChange와 함께 넘깁니다',
        en: 'Which step is showing. Pass it with onStepChange to drive the guide yourself'
      }
    },
    {
      name: 'defaultStep',
      type: 'number',
      default: '0',
      description: {
        ko: 'uncontrolled일 때 시작하는 자리',
        en: 'Where an uncontrolled guide starts'
      }
    },
    {
      name: 'onStepChange',
      type: '(step: number) => void',
      description: {
        ko: '단계가 바뀔 때마다 인덱스와 함께 호출됩니다. 버튼으로 바뀌었든 목록에서 바뀌었든',
        en: 'Fires with the index whenever the step changes, however it changed'
      }
    },
    {
      name: 'completed',
      type: 'boolean',
      description: {
        ko: '끝났는지. 이것도 직접 몰고 갈 수 있습니다',
        en: 'Whether the guide is finished. Controllable too'
      }
    },
    {
      name: 'defaultCompleted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'uncontrolled일 때 끝난 상태로 시작할지',
        en: 'Whether an uncontrolled guide starts finished'
      }
    },
    {
      name: 'onCompletedChange',
      type: '(completed: boolean) => void',
      description: {
        ko: '끝났을 때, 그리고 처음으로 돌아갔을 때 호출됩니다',
        en: 'Fires when the guide is finished, and again when it is started over'
      }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'vertical'",
      shared: true,
      description: {
        ko: '목록이 흐르는 방향. vertical은 번호가 옆으로 내려가고 본문이 그 옆에 놓이며 sm 아래에서는 쌓입니다. horizontal은 위쪽에 가로로 늘어놓는데, 제목이 짧을 때에만 정직합니다',
        en: 'Which way the list runs. vertical puts the numbers down one side with the body beside them, stacking below sm; horizontal runs them across the top, and is only honest while every title is short'
      }
    },
    {
      name: 'maxHeight',
      type: 'number | string',
      description: {
        ko: '스크롤이 시작되기 전까지 커질 수 있는 높이. 시트가 커지는 대신 목록과 본문이 각자 스크롤되고, 현재 행은 보이는 자리로 따라옵니다. 숫자는 픽셀',
        en: 'How tall the guide may get before it scrolls. The list and the body scroll inside it rather than the sheet growing, and the current row is kept in view. Numbers are pixels'
      }
    },
    {
      name: 'railWidth',
      type: 'number | string',
      default: "'15rem'",
      description: {
        ko: '목록이 열일 때의 너비. 숫자는 픽셀',
        en: 'How wide the list is while it is a column. Numbers are pixels'
      }
    },
    {
      name: 'navigation',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '본문 아래의 버튼 줄. 꺼두면 목록이 유일한 이동 수단이 됩니다 — 자체 내비게이션을 가진 페이지 안에 넣을 때',
        en: 'The row of buttons under the body. Off, the list is the only way to move — for a guide inside a page that has navigation of its own'
      }
    },
    {
      name: 'divider',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '목록과 본문 사이의 얇은 선. 두 열일 때는 안쪽 모서리를 따라, 쌓인 뒤에는 목록 아래를 따라 그려집니다',
        en: 'A hairline between the list and the body — down the inner edge while they are two columns, along the bottom of the list once they have stacked'
      }
    },
    {
      name: 'transition',
      type: "NebaTransition | 'none'",
      default: "'fade'",
      shared: true,
      description: {
        ko: '독자가 옮겨간 단계가 등장하는 방식. 어디서나 쓰는 그 어휘 그대로이며, none이면 꺼집니다. 눌리는 것이 아니라 패널에서 실행되고, reduced-motion 설정에서는 전부 꺼집니다',
        en: 'How a step arrives when the reader moves to it, from the same vocabulary transition uses everywhere. none turns it off. It runs on the panel rather than on anything that is pressed, and a reduced-motion preference switches it off entirely'
      }
    },
    {
      name: 'completion',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '완료 상태가 있는지. 켜져 있으면 마지막 단계의 버튼이 “완료”가 되고 누르면 끝났다고 말하는 패널로 바뀝니다. 꺼두면 마지막 단계는 그냥 마지막 단계입니다',
        en: "Whether there is a finished state at all. On, the last step's button says Done and pressing it replaces the body with a panel that says so. Off, the last step is simply the last step"
      }
    },
    {
      name: 'completedContent',
      type: 'ReactNode',
      default: "locale('All steps complete')",
      description: { ko: '완료 패널이 하는 말', en: 'What the finished panel says' }
    },
    {
      name: 'variant',
      type: VARIANT,
      default: "'outline'",
      shared: true,
      description: {
        ko: '시트의 weight, 컨테이너가 말하는 방식으로. 시트는 물들지 않습니다 — 색을 지니는 것은 번호와 연결선과 버튼입니다',
        en: 'Weight of the sheet, said the way a container says it. The sheet is never dyed: what carries the family is the numbers, the connector and the buttons'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '번호 원의 지름, 타입 스케일, 버튼의 크기',
        en: "The disc's diameter, the type scale, and the buttons' size"
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '번호와 연결선과 버튼이 입는 계열',
        en: 'The family the numbers, the connector and the buttons wear'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      shared: true,
      description: {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 is no shadow at all'
      }
    },
    {
      name: 'locale',
      type: 'string',
      default: "'en'",
      description: {
        ko: '네 개의 버튼과 마지막 문장이 쓰이는 언어. 지원하지 않는 태그는 영어로 돌아갑니다',
        en: 'Which language the four buttons and the closing sentence are in. Unsupported tags fall back to English'
      }
    },
    {
      name: 'previousLabel · nextLabel · doneLabel · restartLabel',
      type: 'string',
      default: 'locale',
      description: { ko: '그 네 단어를 직접 씁니다', en: 'Those four words, written out' }
    }
  ],

  HowToStep: [
    {
      name: 'title',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '제목. 목록에도, 그 단계 본문 위에도 같은 것이 놓입니다',
        en: "The heading, shown both in the list and over the step's own body"
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '그 단계 본문의 제목 앞에 그려지는 glyph. 목록에는 그리지 않습니다 — 거기에는 이미 번호가 붙은 원이 있고, 옆의 glyph는 같은 말을 두 번 합니다',
        en: "A glyph before the title over the step's own body. Not in the list: a row there already carries a numbered disc, and a glyph beside it is a second mark making the same claim"
      }
    },
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '독자가 해야 하는 일. 문장이든 CodeBlock이든 폼이든',
        en: 'What the reader has to do — prose, a CodeBlock, a form'
      }
    },
    {
      name: 'image',
      type: 'string',
      description: {
        ko: 'content 위의 그림. 말하기보다 보여주기가 쉬운 단계용',
        en: 'A picture above the content, for a step that is easier shown than said'
      }
    },
    {
      name: 'imageAlt',
      type: 'string',
      default: 'title',
      description: {
        ko: '그 그림이 볼 수 없는 독자에게 하는 말',
        en: 'What that picture says for a reader who cannot see it'
      }
    }
  ]
};

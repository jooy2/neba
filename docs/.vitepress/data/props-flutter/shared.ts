/**
 * What a Flutter props table is written with.
 *
 * A Flutter parameter means what the React prop of the same name means, so a
 * row is derived from the React row in `props.ts` and states only what Dart
 * spells differently: its type, its default, sometimes its name. The
 * description, in both locales, comes along unchanged, and a change to it on
 * the React side reaches both tables. A parameter only Flutter has is written
 * out in full.
 */
import { propTables, type PropRow } from '../props';

export type { PropRow };

/** The shared vocabulary's Dart types, as `packages/flutter/lib/src/types.dart` spells them. */
export const SIZE = 'NebaSize';
export const COLOR = 'NebaColor';
export const VARIANT = 'NebaVariant';
export const DENSITY = 'NebaDensity';
export const ELEVATION = 'NebaElevation';
export const WIDGET = 'Widget';

/**
 * The React row `name` of `component`, with `patch` laid over it.
 *
 * Throws when React has no such prop, so a Flutter row cannot outlive the prop
 * it was derived from.
 */
export function from(component: string, name: string, patch: Partial<PropRow> = {}): PropRow {
  const row = propTables[component]?.find((candidate) => candidate.name === name);

  if (!row) {
    throw new Error(`[neba docs] no React prop named '${name}' on ${component}`);
  }

  return { ...row, ...patch };
}

/** [from], under the name Dart gives it: `children` is `child`, `onClick` is `onPressed`. */
export function renamed(
  component: string,
  name: string,
  dartName: string,
  patch: Partial<PropRow> = {}
): PropRow {
  return { ...from(component, name, patch), name: dartName };
}

/**
 * The shared axes. Each is nullable in Dart, because a widget's own argument,
 * its group and `NebaProvider`'s defaults answer it in that order.
 */
export function sizeRow(component: string, fallback = 'NebaSize.md'): PropRow {
  return from(component, 'size', { type: `${SIZE}?`, default: fallback });
}

export function colorRow(component: string, fallback = 'NebaColor.primary'): PropRow {
  return from(component, 'color', { type: `${COLOR}?`, default: fallback });
}

export function variantRow(component: string, fallback = 'NebaVariant.solid'): PropRow {
  return from(component, 'variant', { type: `${VARIANT}?`, default: fallback });
}

export function densityRow(component: string, fallback = 'NebaDensity.standard'): PropRow {
  return from(component, 'density', { type: `${DENSITY}?`, default: fallback });
}

export function elevationRow(component: string, fallback = '0'): PropRow {
  return from(component, 'elevation', { type: `${ELEVATION}?`, default: fallback });
}

/**
 * The `transition` row, on every widget that displays rather than acts. The
 * description is Flutter's own, because React's names its string form and the
 * `Animate*` components.
 */
export function transitionRow(component: string, example = 'const NebaTransition.fade()'): PropRow {
  return from(component, 'transition', {
    type: 'NebaTransition?',
    description: {
      ko: `처음 빌드될 때 한 번 실행되는 등장 애니메이션 (\`${example}\`). blink는 repeat를 주지 않으면 계속 반복합니다`,
      en: `An entrance animation, run once when the widget is first built (\`${example}\`). blink repeats unless its repeat says otherwise`
    }
  });
}

/** What an `Animate*` widget's settings default to where they are not React's. */
interface AnimateRowOptions {
  /** The widget's own duration, in milliseconds. */
  duration: number;
  /** Left out by the three that have nothing to reverse. */
  mode?: false;
  repeat?: string;
  curve?: string;
  alternate?: string;
  trigger?: string;
  /**
   * The rows a widget does not take, or takes with a meaning of its own and
   * writes out itself: the step and the scroll timeline are not on the ones
   * that read what their children are.
   */
  omit?: ReadonlyArray<string>;
}

/**
 * The settings every `Animate*` widget takes, in the order React's table
 * lists them. Each row is React's with Dart's type and default, and the
 * description is Flutter's own wherever React's speaks of milliseconds, CSS
 * or the browser.
 */
export function animateRows(component: string, options: AnimateRowOptions): PropRow[] {
  const omitted = new Set<string>(options.omit ?? []);

  if (options.mode === false) {
    omitted.add('mode');
  }

  // Each row is built only when it is kept, since `from` throws for a prop
  // React does not have, and a component without a step has no step row.
  const rows: Array<[string, () => PropRow]> = [
    [
      'stagger',
      () =>
        from(component, 'stagger', {
          type: 'Duration',
          default: 'Duration.zero',
          description: {
            ko: '한 자식 뒤 다음 자식이 시작하기까지의 간격. 0이면 children 전체가 하나로 재생되고, 그보다 크면 효과가 자식 하나하나에게 넘어갑니다',
            en: 'How long after one of children the next one starts. Zero animates them as one; anything above it moves the effect onto each child in turn'
          }
        })
    ],
    [
      'durationStep',
      () =>
        from(component, 'durationStep', {
          type: 'Duration',
          default: 'Duration.zero',
          description: {
            ko: '자식마다 재생 시간에 더해지는 값. 음수면 뒤로 갈수록 빨라지며, 0 아래로는 내려가지 않습니다',
            en: 'How much longer each successive child takes. Negative speeds them up down the list, and never past zero'
          }
        })
    ],
    ['reverse', () => from(component, 'reverse', { type: 'bool' })],
    [
      'timeline',
      () =>
        from(component, 'timeline', {
          type: 'NebaAnimateTimeline',
          default: 'NebaAnimateTimeline.time',
          description: {
            ko: '무엇이 진행을 이끄는지. view면 위젯이 세로로 스크롤되는 가장 가까운 뷰를 지나가는 정도가 효과를 재생하고, duration, delay, repeat, trigger는 무시됩니다',
            en: "What drives the progress. With view, the widget's way up through the nearest scroll view that scrolls down the page plays the effect, and duration, delay, repeat and trigger are ignored"
          }
        })
    ],
    [
      'range',
      () =>
        from(component, 'range', {
          type: 'NebaViewRange',
          default: 'NebaViewRange()',
          description: {
            ko: 'view timeline이 매핑되는 구간. 단계(NebaViewPhase)와 그 안의 비율로 양 끝을 정하며, 기본값은 entry 0에서 cover 0.45까지입니다',
            en: 'The part of the way a view timeline is mapped over, each end a phase (NebaViewPhase) and a fraction of it: from entry 0 to cover 0.45 by default'
          }
        })
    ],
    [
      'mode',
      () =>
        from(component, 'mode', {
          type: 'NebaAnimateMode',
          default: 'NebaAnimateMode.enter',
          description: {
            ko: '들어오는지(enter) 나가는지(exit). exit은 같은 애니메이션을 거꾸로 재생하고 그 자리에서 멈춥니다. React의 in과 out입니다',
            en: "Whether the content arrives (enter) or leaves (exit). exit is the same animation run backwards, and it is held there. React's in and out"
          }
        })
    ],
    [
      'duration',
      () =>
        from(component, 'duration', {
          type: 'Duration',
          default: `Duration(milliseconds: ${options.duration})`,
          description: { ko: '한 번 재생되는 시간', en: 'How long one run takes' }
        })
    ],
    [
      'delay',
      () =>
        from(component, 'delay', {
          type: 'Duration',
          default: 'Duration.zero',
          description: { ko: '시작 전 대기 시간', en: 'How long before it starts' }
        })
    ],
    [
      'easing',
      () =>
        renamed(component, 'easing', 'curve', {
          type: 'Curve?',
          default: options.curve,
          description:
            options.curve === undefined
              ? {
                  ko: '이징 곡선. 생략하면 라이브러리의 곡선인 NebaScale.ease',
                  en: 'The easing curve. Left out, it is the house curve, NebaScale.ease'
                }
              : { ko: '이징 곡선', en: 'The easing curve' }
        })
    ],
    [
      'repeat',
      () =>
        from(component, 'repeat', {
          type: 'num',
          default: options.repeat ?? '1',
          description: {
            ko: '반복 횟수. double.infinity면 화면 밖에 있는 동안 멈췄다가 돌아오면 이어서 재생합니다',
            en: 'How many times it runs. A double.infinity one holds while it is off the screen and carries on when it is back'
          }
        })
    ],
    [
      'alternate',
      () => from(component, 'alternate', { type: 'bool', default: options.alternate ?? 'false' })
    ],
    [
      'trigger',
      () =>
        from(component, 'trigger', {
          type: 'NebaAnimateTrigger',
          default: options.trigger ?? 'NebaAnimateTrigger.mount',
          description: {
            ko: '무엇이 재생을 시작하는지. visible은 화면에 들어올 때, hover는 포인터가 올라올 때(포커스와 터치 화면의 손가락 포함), manual은 play가 정합니다',
            en: 'What starts it. visible is on scrolling into view, hover is under the pointer (focus and a finger on a touch screen count), manual is whatever play says'
          }
        })
    ],
    [
      'play',
      () =>
        from(component, 'play', {
          type: 'Object?',
          description: {
            ko: 'trigger가 manual일 때 재생합니다. bool이나 숫자를 받습니다. false → true 될 때와 숫자가 바뀔 때마다 처음부터 다시 시작하고, false, 0, null이면 멈춰 있습니다',
            en: 'Runs it when trigger is manual: a bool, or a number. Each false → true, and each change of number, starts it over; false, 0 and null hold it'
          }
        })
    ],
    ['once', () => from(component, 'once', { type: 'bool' })],
    [
      'threshold',
      () =>
        from(component, 'threshold', {
          type: 'double',
          description: {
            ko: 'trigger가 visible일 때 화면에 얼마나 들어와야 하는지, 0에서 1 사이. 창보다 큰 위젯에서는 창에 대한 비율입니다',
            en: 'With trigger visible, how much of the widget has to be on screen, from 0 to 1; of the window, for a widget larger than it'
          }
        })
    ],
    ['paused', () => from(component, 'paused', { type: 'bool' })]
  ];

  return rows.filter(([name]) => !omitted.has(name)).map(([, row]) => row());
}

/**
 * What an `Animate*` widget wraps: a `child`, or `children` laid out by
 * `layoutBuilder`, where React takes one `children` and lays it out with the
 * root's own class names. `child` keeps React's description.
 */
export function animateChildRows(component: string): PropRow[] {
  return [
    {
      name: 'layoutBuilder',
      type: 'Widget Function(List<Widget>)?',
      description: {
        ko: 'children을 배치합니다. 생략하면 children은 각자 시작 쪽에 붙은 Column입니다',
        en: 'Lays out children. Left out, they are a Column, each at the start'
      }
    },
    {
      name: 'children',
      type: `List<${WIDGET}>?`,
      description: {
        ko: '목록으로 받는 내용. 각 자식이 stagger의 한 걸음이며, child와 함께 줄 수 없습니다',
        en: 'What arrives, as a list: each one is a step of a stagger. Not together with child'
      }
    },
    renamed(component, 'children', 'child', { type: `${WIDGET}?` })
  ];
}

/** The name a screen reader announces: React's `aria-label`. */
export const semanticLabelRow: PropRow = {
  name: 'semanticLabel',
  type: 'String?',
  description: {
    ko: '화면 낭독기가 읽는 이름. 보이는 내용 대신 읽히며, React의 `aria-label`에 해당합니다',
    en: "The name a screen reader announces in place of what is shown: React's `aria-label`"
  }
};

/** Focus, which a Flutter widget takes as arguments rather than as DOM attributes. */
export const focusRows: PropRow[] = [
  {
    name: 'focusNode',
    type: 'FocusNode?',
    description: {
      ko: '포커스를 밖에서 다룰 때 넘기는 노드',
      en: 'Drives the focus from outside'
    }
  },
  {
    name: 'autofocus',
    type: 'bool',
    default: 'false',
    description: {
      ko: '처음 그려질 때 포커스를 받을지 여부',
      en: 'Whether it takes the focus when it is first built'
    }
  }
];

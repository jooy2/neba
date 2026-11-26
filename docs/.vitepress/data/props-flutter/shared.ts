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

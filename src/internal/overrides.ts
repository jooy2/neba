/**
 * Which properties a caller's `className` sets, read off Tailwind's own names.
 *
 * Typography and TextLink write their defaults at two-class strength, through
 * `[&.neba-typography]` and `[&.neba-link]`, because the tags they render are
 * the ones a host stylesheet styles by name: `.prose h2` and `.vp-doc a` are a
 * class plus a tag, which a one-class utility cannot outrank. A caller's own
 * utility is one class too, so the guard that held off the host held off the
 * caller as well — `className="mb-8"` on a Typography came out with no margin
 * and nothing said why. No specificity sits above the host's rule and below a
 * plain utility, so the cascade cannot settle it; the component has to know
 * what the caller asked for.
 *
 * So it asks this, once per render. A property the caller's classes set leaves
 * the guard, and the component states its default through `[:where(&)]`
 * instead, at zero specificity: any utility the caller wrote beats it, under
 * any variant, and it is still there below a class that only applies at a
 * breakpoint or on hover. What the caller gives up is the guard against the
 * host for that one property, and that is a fight the caller's class is in on
 * any other element too.
 *
 * Two rules decide what counts:
 *
 * - **A class it cannot place counts as everything it might set.** `text-brand`
 *   is a colour in one theme and a size in another, and the stylesheet that
 *   would say which is not something a render can read. Counting a property
 *   wrongly costs one element its guard against a host stylesheet; missing one
 *   is the silent loss this module exists to end.
 * - **An important class does not count.** `mb-8!` wins already, and keeping the
 *   guard under it is what leaves a call site written with `!` exactly as it
 *   was.
 *
 * It reads Tailwind's names and nothing else. A class from the caller's own
 * stylesheet, `.hero-title`, is invisible to it and still needs two classes or
 * `!important` to beat the guard.
 */

export const MARGIN_TOP = 1;
export const MARGIN_BOTTOM = 2;
export const FONT_SIZE = 4;
export const LINE_HEIGHT = 8;
export const LETTER_SPACING = 16;
export const FONT_WEIGHT = 32;
export const COLOR = 64;
export const TEXT_DECORATION_LINE = 128;
export const TEXT_DECORATION_THICKNESS = 256;
export const TEXT_DECORATION_COLOR = 512;
export const TEXT_UNDERLINE_OFFSET = 1024;
export const TEXT_UNDERLINE_POSITION = 2048;

/** Tailwind's own sizes. Their paired leading is read through `--tw-leading`. */
const TEXT_SIZE = /^(xs|sm|base|lg|[2-9]?xl)$/;

/** The `text-*` utilities that set neither a size nor a colour. */
const TEXT_OTHER =
  /^(left|center|right|justify|start|end|wrap|nowrap|balance|pretty|ellipsis|clip)$|^shadow(-|$)/;

/** Tailwind's colour keywords and every palette shade, `red-500` and the like. */
const NAMED_COLOR = /^(inherit|current|transparent|black|white)$|-\d+$/;

/** The `decoration-*` thicknesses Tailwind names. */
const DECORATION_THICKNESS = /^(\d+|from-font|auto)$/;

/** The `font-*` utilities that are not a weight. */
const FONT_OTHER = /^(sans|serif|mono)$|^(stretch|features)-|^[[(]family:/;

/** What an arbitrary property, `[margin-bottom:2rem]`, sets. */
const PROPERTIES: Record<string, number> = {
  margin: MARGIN_TOP | MARGIN_BOTTOM,
  'margin-block': MARGIN_TOP | MARGIN_BOTTOM,
  'margin-top': MARGIN_TOP,
  'margin-block-start': MARGIN_TOP,
  'margin-bottom': MARGIN_BOTTOM,
  'margin-block-end': MARGIN_BOTTOM,
  font: FONT_SIZE | LINE_HEIGHT | FONT_WEIGHT,
  'font-size': FONT_SIZE,
  'line-height': LINE_HEIGHT,
  'letter-spacing': LETTER_SPACING,
  'font-weight': FONT_WEIGHT,
  color: COLOR,
  'text-decoration': TEXT_DECORATION_LINE | TEXT_DECORATION_THICKNESS | TEXT_DECORATION_COLOR,
  'text-decoration-line': TEXT_DECORATION_LINE,
  'text-decoration-thickness': TEXT_DECORATION_THICKNESS,
  'text-decoration-color': TEXT_DECORATION_COLOR,
  'text-underline-offset': TEXT_UNDERLINE_OFFSET,
  'text-underline-position': TEXT_UNDERLINE_POSITION
};

/** Where `char` last occurs outside brackets and parentheses, or `-1`. */
function lastTopLevel(value: string, char: string): number {
  let depth = 0;
  let found = -1;

  for (let index = 0; index < value.length; index += 1) {
    const current = value[index];

    if (current === '[' || current === '(') {
      depth += 1;
    } else if (current === ']' || current === ')') {
      depth -= 1;
    } else if (current === char && depth === 0) {
      found = index;
    }
  }

  return found;
}

/**
 * What a bracketed value sets on a utility that takes either a length or a
 * colour, `text-*` and `decoration-*`, read the way Tailwind reads it.
 *
 * Untyped, Tailwind takes a number or a math function as a length and anything
 * else as a colour — `text-(--x)` and `text-[var(--x)]` included. A bare word
 * is the one case it decides by name, `large` from `red`, so that counts as
 * both.
 */
function lengthOrColor(value: string, length: number, color: number): number {
  const inner = value.slice(1, -1);

  if (/^(length|percentage|absolute-size|relative-size):/.test(inner)) {
    return length;
  }

  if (inner.startsWith('color:') || value.startsWith('(')) {
    return color;
  }

  if (/^([\d.]|(calc|clamp|min|max)\()/.test(inner)) {
    return length;
  }

  return /^[a-z-]+$/.test(inner) ? length | color : color;
}

/**
 * What a `text-*` utility sets, given what follows `text-`.
 *
 * A size with a modifier, `text-xl/7`, writes `line-height` itself. One
 * without leaves it alone or reaches it through `--tw-leading`, which the
 * component's own default sets, so a size from `className` keeps the level's
 * ratio until a `leading-*` says otherwise.
 */
function textSets(rest: string): number {
  const slash = lastTopLevel(rest, '/');
  const value = slash === -1 ? rest : rest.slice(0, slash);
  const size = FONT_SIZE | (slash === -1 ? 0 : LINE_HEIGHT);

  if (TEXT_OTHER.test(value)) {
    return 0;
  }

  if (TEXT_SIZE.test(value)) {
    return size;
  }

  if (NAMED_COLOR.test(value)) {
    return COLOR;
  }

  if (value.startsWith('[') || value.startsWith('(')) {
    return lengthOrColor(value, size, COLOR);
  }

  // A name from the caller's own theme.
  return COLOR | size;
}

/** What a `decoration-*` utility sets, given what follows `decoration-`. */
function decorationSets(rest: string): number {
  // `decoration-red-500/50` is the colour at half strength.
  const slash = lastTopLevel(rest, '/');
  const value = slash === -1 ? rest : rest.slice(0, slash);

  if (/^(solid|double|dotted|dashed|wavy)$/.test(value)) {
    return 0;
  }

  if (DECORATION_THICKNESS.test(value)) {
    return TEXT_DECORATION_THICKNESS;
  }

  if (NAMED_COLOR.test(value)) {
    return TEXT_DECORATION_COLOR;
  }

  if (value.startsWith('[') || value.startsWith('(')) {
    return lengthOrColor(value, TEXT_DECORATION_THICKNESS, TEXT_DECORATION_COLOR);
  }

  return TEXT_DECORATION_THICKNESS | TEXT_DECORATION_COLOR;
}

/** What one utility, its variants already taken off, sets. */
function utilitySets(utility: string): number {
  const name = utility.startsWith('-') ? utility.slice(1) : utility;

  if (name.startsWith('[') && name.endsWith(']')) {
    return PROPERTIES[name.slice(1, name.indexOf(':'))] ?? 0;
  }

  const margin = /^m(bs|be|[tby])?-/.exec(name);

  if (margin) {
    const axis = margin[1];

    if (axis === 't' || axis === 'bs') {
      return MARGIN_TOP;
    }

    return axis === 'b' || axis === 'be' ? MARGIN_BOTTOM : MARGIN_TOP | MARGIN_BOTTOM;
  }

  if (name.startsWith('text-')) {
    return textSets(name.slice(5));
  }

  if (name.startsWith('font-')) {
    return FONT_OTHER.test(name.slice(5)) ? 0 : FONT_WEIGHT;
  }

  if (name.startsWith('leading-')) {
    return LINE_HEIGHT;
  }

  if (name.startsWith('tracking-')) {
    return LETTER_SPACING;
  }

  if (name.startsWith('decoration-')) {
    return decorationSets(name.slice(11));
  }

  if (name.startsWith('underline-offset-')) {
    return TEXT_UNDERLINE_OFFSET;
  }

  return /^(underline|overline|line-through|no-underline)$/.test(name) ? TEXT_DECORATION_LINE : 0;
}

/**
 * The properties `className` sets, as the flags above.
 *
 * Variants are read past rather than weighed: `md:mb-4` and `hover:text-red-500`
 * count, since the default beneath them is the floor, not the guard.
 */
export function overriddenBy(className: string | undefined): number {
  let sets = 0;

  for (const token of className ? className.split(/\s+/) : []) {
    const utility = token.slice(lastTopLevel(token, ':') + 1);

    if (utility && !utility.startsWith('!') && !utility.endsWith('!')) {
      sets |= utilitySets(utility);
    }
  }

  return sets;
}

/**
 * The pieces every Neba component is built out of.
 *
 * None of this is exported from `src/index.ts` — it is the library talking to
 * itself. It lives here for one reason: a `size` of `md` has to be 32px on a
 * Button, a TextField, a Select and a Chip, and a table copied into eleven
 * files is a table that will disagree with itself by the twelfth.
 *
 * The two things that cannot move out of a component are its variant classes
 * and its layout — those genuinely differ. Heights, radii, type scale, padding
 * tracks, the frosted surface, the transition and the colour slots do not.
 *
 * Tailwind only sees class names written out literally, so everything here is a
 * complete class string rather than something assembled at runtime. `@source
 * '.'` in `styles.css` covers this folder in the repository and in `dist/`.
 */

import type * as React from 'react';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../types';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/**
 * Corner radius. ~45% of the control height at every step, held just short of
 * the 50% that would make it a pill.
 */
export const radiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-(--neba-radius-xs)',
  sm: 'rounded-(--neba-radius-sm)',
  md: 'rounded-(--neba-radius-md)',
  lg: 'rounded-(--neba-radius-lg)',
  xl: 'rounded-(--neba-radius-xl)'
};

/**
 * The height of a control, and the one number the whole library lines up on:
 * a Button, a TextField, a Select and a Chip of the same `size` sit on the same
 * baseline in the same row.
 *
 * The steps are deliberately uneven. `md` (32px) is the desktop workhorse,
 * `xs`/`sm` are for dense toolbars and table rows, `lg`/`xl` are for the one
 * action a screen is actually about — so the gaps widen at both ends rather
 * than marching up in equal 4px increments.
 *
 * Density never touches these.
 */
export const controlHeightClasses: Record<NebaSize, string> = {
  xs: 'h-5.5',
  sm: 'h-6.5',
  md: 'h-8',
  lg: 'h-10',
  xl: 'h-12'
};

/** The same numbers as a width, for a control with nothing to pad against. */
export const controlSquareClasses: Record<NebaSize, string> = {
  xs: 'w-5.5',
  sm: 'w-6.5',
  md: 'w-8',
  lg: 'w-10',
  xl: 'w-12'
};

/** A control's label. One line, so the leading comes from `leading-none`. */
export const controlTextClasses: Record<NebaSize, string> = {
  xs: 'text-[0.6875rem]',
  sm: 'text-[0.75rem]',
  md: 'text-[0.8125rem]',
  lg: 'text-[0.9375rem]',
  xl: 'text-[1.0625rem]'
};

/**
 * The same type scale with an explicit leading, for the controls that hold text
 * which may wrap — a textarea, a select option, a table cell. The line heights
 * have to agree with `controlHeightClasses` or a one-row control would stop
 * lining up with a single-line one.
 */
export const controlTextLeadingClasses: Record<NebaSize, string> = {
  xs: 'text-[0.6875rem]/[0.875rem]',
  sm: 'text-[0.75rem]/[1rem]',
  md: 'text-[0.8125rem]/[1.25rem]',
  lg: 'text-[0.9375rem]/[1.375rem]',
  xl: 'text-[1.0625rem]/[1.625rem]'
};

/** Labels, descriptions and error messages: one step below the control's text. */
export const metaTextClasses: Record<NebaSize, string> = {
  xs: 'text-[0.625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.75rem]',
  lg: 'text-[0.8125rem]',
  xl: 'text-[0.875rem]'
};

/**
 * Horizontal padding, and the only thing `density` is allowed to touch. The two
 * tracks are roughly 2:1 so the difference is legible at a glance rather than a
 * two-pixel nudge.
 */
export const paddingXClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'px-2.5', sm: 'px-3', md: 'px-4', lg: 'px-5', xl: 'px-6' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-4' }
};

/**
 * A tick box: the square a Checkbox draws and the circle a Radio draws.
 *
 * Its own ladder rather than a step off `controlHeightClasses`, because a tick
 * is not a control you can put a label inside — it is an indicator next to one,
 * and it is sized against the text beside it rather than against the row.
 */
export const tickSizeClasses: Record<NebaSize, string> = {
  xs: 'size-3.5',
  sm: 'size-4',
  md: 'size-4.5',
  lg: 'size-5',
  xl: 'size-6'
};

/**
 * And its own radius, at ~30% rather than the ~45% the control ladder uses.
 * `--neba-radius-md` is 14px, which on an 18px box is a circle — and a checkbox
 * that is round is a radio button. The intent is the same as everywhere else:
 * a sheet with the corners cut off, never a pill.
 */
export const tickRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.25rem]',
  sm: 'rounded-[0.3125rem]',
  md: 'rounded-[0.375rem]',
  lg: 'rounded-[0.4375rem]',
  xl: 'rounded-[0.5rem]'
};

/**
 * The same two tracks again, as raw lengths.
 *
 * These exist for one element: a table cell. `<td>` and `<th>` are among the
 * very few tags that host stylesheets still style by name — VitePress's
 * `.vp-doc td`, Tailwind Typography's `.prose td`, every CSS framework ever —
 * and all of those are two-class selectors that a utility cannot outrank. A
 * Table therefore writes its cell padding inline, where nothing can reach it.
 *
 * Keep these in step with `paddingXClasses`. They are the same numbers: the
 * Tailwind spacing scale is 0.25rem per step.
 */
export const paddingXValues: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: '0.625rem', sm: '0.75rem', md: '1rem', lg: '1.25rem', xl: '1.5rem' },
  compact: { xs: '0.375rem', sm: '0.5rem', md: '0.625rem', lg: '0.75rem', xl: '1rem' }
};

/** Between a control's own parts — an icon and its label. */
export const gapClasses: Record<NebaSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1.5',
  md: 'gap-1.5',
  lg: 'gap-2',
  xl: 'gap-2.5'
};

/** Between a label, the control under it and the text under that. */
export const stackGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1',
  md: 'gap-1.5',
  lg: 'gap-1.5',
  xl: 'gap-2'
};

/* ---------------------------------------------------------------------------
 * Sheet typography
 *
 * A control holds one line of text at a fixed height. A *sheet* — a Card, an
 * Alert, a Dialog, a List row — holds a heading, a paragraph and a footer, all
 * of which wrap. That is a different problem, and these four tables are its
 * answer: they are what Card was written with, moved here the moment a second
 * sheet-shaped component needed the same ladder.
 *
 * The subtitle deliberately has no table of its own — it is `metaTextClasses`,
 * the same step below the body that a field's description sits on.
 * ------------------------------------------------------------------------- */

/**
 * A sheet's heading: one step above the body, on the same ladder the controls
 * use, so a card's title lines up with the buttons that end up inside it.
 */
export const sheetTitleClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]/[1rem]',
  sm: 'text-[0.8125rem]/[1.125rem]',
  md: 'text-[0.9375rem]/[1.25rem]',
  lg: 'text-[1.0625rem]/[1.5rem]',
  xl: 'text-[1.25rem]/[1.75rem]'
};

/**
 * Body copy: the control type scale with the leading opened up, because a
 * label is one line and a body is a paragraph.
 */
export const sheetBodyClasses: Record<NebaSize, string> = {
  xs: 'text-[0.6875rem]/[1rem]',
  sm: 'text-[0.75rem]/[1.125rem]',
  md: 'text-[0.8125rem]/[1.375rem]',
  lg: 'text-[0.9375rem]/[1.5rem]',
  xl: 'text-[1.0625rem]/[1.75rem]'
};

/** Title to subtitle. Tight — they are one block of text, not two sections. */
export const sheetHeaderGapClasses: Record<NebaSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/** Between a sheet's sections, when there are no dividers to separate them. */
export const sheetSectionGapClasses: Record<NebaSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/* ---------------------------------------------------------------------------
 * Surface
 * ------------------------------------------------------------------------- */

/**
 * The frosted surface: a translucent fill over a blurred backdrop, a tile of
 * noise blended into it for tooth, and an angled sheen. The blur makes it a
 * sheet of something; the noise makes that something acrylic rather than glass.
 */
export const surfaceClasses =
  '[background-image:var(--neba-grain),var(--neba-sheen)] [background-blend-mode:overlay,normal] [backdrop-filter:var(--neba-blur)]';

/**
 * The house transition. Per-property durations in the order the property list
 * declares them: the fill drains back slowly while edges and shadows keep up
 * with the pointer.
 *
 * No `transform` is in the list, and none should ever be added — scaling a
 * control resamples its label, and a label that shimmers under the cursor is
 * what reads as cheap.
 */
export const transitionClasses = [
  '[transition-property:background-color,border-color,box-shadow,color]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]'
].join(' ');

/**
 * Press is instant, release is slow — the house interaction signature. Pressing
 * zeroes every duration, so the whole control lands on the frame of the click
 * and then decays.
 */
export const pressTransitionClasses = 'active:[transition-duration:0ms]';

/**
 * The focus ring, written as the `outline` shorthand rather than Tailwind's
 * `outline-2` + colour pair: the utilities route the style through
 * `--tw-outline-style`, which any `outline-none` on the element (ours or a
 * consumer's) would zero out.
 */
export const focusRingClasses =
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2';

/** The same ring, drawn by whichever descendant actually takes focus. */
export const focusWithinRingClasses =
  'has-[:focus-visible]:[outline:2px_solid_var(--n-ring)] has-[:focus-visible]:outline-offset-2';

/** Icons track their label rather than carrying a size of their own. */
export const iconClasses = '[&_svg]:pointer-events-none [&_svg]:size-[1.2em] [&_svg]:shrink-0';

/* ---------------------------------------------------------------------------
 * Colour slots
 *
 * These are inline styles rather than Tailwind arbitrary properties on purpose:
 * Tailwind only sees class names that appear literally in the source, so the
 * alternative is one hardcoded `[--n-fill:var(--neba-primary-fill)]` per family
 * per component. Generating the slots keeps adding a colour family down to one
 * entry in `NebaColor` plus its tokens in `styles.css`.
 * ------------------------------------------------------------------------- */

/**
 * Every slot a control reads, with the panel ladder dyed by the family.
 *
 * A control's surface *is* the thing being coloured, so it takes the tint. The
 * two light slots switch with the variant: light thrown onto a filled surface is
 * white; onto a tinted or bare one it has to be the accent, or the surface
 * washes out to grey.
 */
export function controlSlots(
  color: NebaColor,
  elevation: NebaElevation,
  variant: NebaVariant
): React.CSSProperties {
  const onFill = variant === 'solid';

  return {
    '--n-fill': `var(--neba-${color}-fill)`,
    '--n-fill-hover': `var(--neba-${color}-fill-hover)`,
    '--n-fill-active': `var(--neba-${color}-fill-active)`,
    '--n-on-solid': `var(--neba-${color}-on-solid)`,
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-soft-press': `var(--neba-${color}-soft-press)`,
    '--n-panel': `var(--neba-${color}-panel)`,
    '--n-panel-hover': `var(--neba-${color}-panel-hover)`,
    '--n-panel-press': `var(--neba-${color}-panel-press)`,
    '--n-line': `var(--neba-${color}-line)`,
    '--n-line-hover': `var(--neba-${color}-line-hover)`,
    '--n-ring': `var(--neba-${color}-ring)`,
    '--n-glow': onFill ? 'var(--neba-glow-on-fill)' : `var(--neba-${color}-soft)`,
    '--n-flash': onFill ? 'var(--neba-flash-on-fill)' : `var(--neba-${color}-soft-press)`,
    '--n-elev': `var(--neba-shadow-${elevation})`,
    '--n-elev-hover': `var(--neba-shadow-${Math.min(elevation + 1, 4)})`,
    '--n-elev-press': `var(--neba-shadow-${Math.max(elevation - 1, 0)})`
  } as React.CSSProperties;
}

/**
 * The same slots with the panel ladder left *undyed* — the neutral
 * `--neba-panel*` steps rather than the family's own.
 *
 * This is what a container uses. A Box, a Card, a TextField or a Select popup
 * holds other people's content, and that content arrives with its own colours;
 * tinting the sheet under it puts every one of them on a background they were
 * not chosen against. So the family shows up in the hairline, the focus ring and
 * the caret, and the sheet stays white.
 */
export function surfaceSlots(color: NebaColor, elevation: NebaElevation): React.CSSProperties {
  return {
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-soft-press': `var(--neba-${color}-soft-press)`,
    '--n-panel': 'var(--neba-panel)',
    '--n-panel-hover': 'var(--neba-panel-hover)',
    '--n-panel-press': 'var(--neba-panel-press)',
    '--n-line': `var(--neba-${color}-line)`,
    '--n-line-hover': `var(--neba-${color}-line-hover)`,
    '--n-ring': `var(--neba-${color}-ring)`,
    '--n-elev': `var(--neba-shadow-${elevation})`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * Shared state treatments
 * ------------------------------------------------------------------------- */

/**
 * Disabled drops the colour family entirely. Fading the coloured surface would
 * still read as "this is the primary action", only blurrier.
 */
export const disabledClasses: Record<NebaVariant, string> = {
  solid: 'cursor-not-allowed bg-(--neba-disabled-bg) text-(--neba-disabled-fg) shadow-none',
  outline:
    'cursor-not-allowed border bg-transparent text-(--neba-disabled-fg) [border-color:var(--neba-disabled-border)] shadow-none',
  text: 'cursor-not-allowed bg-transparent text-(--neba-disabled-fg) shadow-none'
};

/**
 * The shell a field-shaped control is drawn on — a TextField's box and a
 * Select's trigger, which have to be indistinguishable or a form looks like two
 * different forms stacked on each other.
 *
 * The variants say the same three things they say on Button — filled, hairline,
 * bare — with one deliberate difference: `solid` does not flood the control with
 * `--n-fill`. What a field holds is user data, and a caret, a text selection, a
 * placeholder and a chosen option all have to stay legible on top of it, which
 * they are not on an accent fill.
 *
 * So the sheet is not dyed at all — `--n-panel` is the *undyed* acrylic, and the
 * three steps below it are opacity rather than tint. `solid` rests one step up
 * the ladder from `outline`, and hover and focus climb it; the colour family
 * shows up in the edge, the ring and the caret instead.
 */
export const fieldRestClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]',
    'hover:bg-(--n-panel-press)',
    'focus-within:bg-(--n-panel-press)'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]',
    'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
    'focus-within:bg-(--n-panel-hover) focus-within:[border-color:var(--n-ring)]'
  ].join(' '),
  // No surface until it is wanted — the field in a table cell that only looks
  // like a field once you go near it.
  text: [
    'text-(--neba-fg) bg-transparent',
    'hover:bg-(--n-soft)',
    'focus-within:bg-(--n-soft-hover)'
  ].join(' ')
};

/**
 * Read-only keeps the colour and the edge, goes flat, and drains most of the
 * saturation — the same axis Button uses. The caret and the text selection stay,
 * because a read-only field is still something you copy out of.
 */
export const fieldReadOnlyClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--neba-plate-solid)] [filter:saturate(0.55)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)] [box-shadow:var(--neba-plate-glass)] [filter:saturate(0.55)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent [filter:saturate(0.55)]'
};

/**
 * Read-only keeps the shape and the edge but goes flat, loses its sheen and
 * drains most of the saturation. It reads as a label that happens to be
 * control-shaped, which is what a read-only control is.
 *
 * The desaturation is doing the work: with `elevation` defaulting to 0 there is
 * no drop shadow on a normal control either, so "flat" alone says nothing.
 *
 * The cursor is left to the component. A read-only button stops being something
 * you click; a read-only field is still something you select text out of.
 */
export const readOnlyFilterClasses = '[filter:saturate(0.55)]';

/** `false`, `null`, `undefined` and `''` all mean "this slot is not filled". */
export function hasContent(node: React.ReactNode): boolean {
  return node !== undefined && node !== null && node !== false && node !== '';
}

/** Joins class name fragments, dropping the empty ones. */
export function cx(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ');
}

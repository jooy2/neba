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
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../types.js';

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

/**
 * The same ladder as raw lengths, for the arithmetic a class cannot do.
 *
 * `paddingXValues` is here for the same reason one level down: Tailwind only
 * ever sees class names written out literally, so "three rows of tabs tall" is a
 * number a component has to multiply. **Keep the two in step** — a height that
 * disagrees with its class is a cap that lands half a row out.
 */
export const controlHeightValues: Record<NebaSize, string> = {
  xs: '1.375rem',
  sm: '1.625rem',
  md: '2rem',
  lg: '2.5rem',
  xl: '3rem'
};

/**
 * How wide content is allowed to get — a Container's `maxWidth`, and the same
 * prop on a Header and a Footer whose bar spans the window while what is on it
 * lines up with the page.
 *
 * Written here once because the three had a copy each, and in `rem` rather than
 * in Tailwind's named `max-w-*` steps so that a Container's `lg` and a `lg:`
 * variant are the same 64rem. Tailwind's own container scale is a different set
 * of numbers, and two ladders called `lg` on one page is how a layout drifts by
 * a few pixels for no reason anybody can find later.
 *
 * Four of the five are exactly the breakpoint floors. `xs` is the one that is
 * not — a measure of zero is not a thing — and that is the whole of the
 * difference between this ladder and `NebaBreakpoint`.
 */
export const measureWidths: Record<NebaSize, string> = {
  xs: '30rem',
  sm: '40rem',
  md: '48rem',
  lg: '64rem',
  xl: '80rem'
};

/**
 * One value of a `maxWidth`, as the length the `--n-max-w` slot takes.
 *
 * A step of the ladder resolves to its `rem`; anything else is a length the
 * caller wrote and is passed through untouched, so `'48rem'`, `'60ch'`,
 * `'min(90vw, 72rem)'` and `640` all reach `max-width` meaning what they say.
 * `'none'` is not in the table and therefore falls through to the CSS keyword,
 * which is what it already was.
 */
export function measureValue(value: NebaSize | 'none' | number | string): string {
  if (typeof value === 'number') return `${value}px`;

  return measureWidths[value as NebaSize] ?? value;
}

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
 * `metaTextClasses` as raw lengths, for text whose size has to travel in the
 * same inline style object as the rest of what positions it — an Image's
 * watermark, which is placed, tinted and turned inline. Keep the two in step.
 */
export const metaTextValues: Record<NebaSize, string> = {
  xs: '0.625rem',
  sm: '0.6875rem',
  md: '0.75rem',
  lg: '0.8125rem',
  xl: '0.875rem'
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
 * A glyph standing on its own, rather than one riding on a label.
 *
 * `iconClasses` below sizes an icon *inside* a control at `1.2em`, which is
 * right when there is a word next to it to be measured against. An `Icon` on its
 * own has no word, so it needs a box — and the box is its own ladder rather than
 * a step off `controlHeightClasses`, because an icon is not a control: at 32px a
 * `md` glyph would be the size of the button it usually sits in.
 *
 * The steps are the sizes icon sets are actually drawn at — 14, 16, 20, 24, 28 —
 * so a Neba `Icon` lands on the same grid as whatever library the glyph came
 * from and never has to be resampled.
 */
export const iconSizeClasses: Record<NebaSize, string> = {
  xs: 'size-3.5',
  sm: 'size-4',
  md: 'size-5',
  lg: 'size-6',
  xl: 'size-7'
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
 * The dot inside a checked Radio.
 *
 * Whole pixels at every step rather than a percentage of the ring around it.
 * `38%` of an 18px box is 6.08px, and a circle whose diameter lands between two
 * device pixels is antialiased unevenly on its four sides — which is exactly
 * what reads as "the dot is not centred" even when the box says it is.
 */
export const tickDotClasses: Record<NebaSize, string> = {
  xs: 'size-[0.3125rem]',
  sm: 'size-1.5',
  md: 'size-[0.4375rem]',
  lg: 'size-2',
  xl: 'size-[0.5625rem]'
};

/**
 * The line box a tick and its label share.
 *
 * Both the tick's wrapper and the label are measured against it: the wrapper is
 * `h-[1lh]` so the box centres on the label's *first* line rather than on the
 * whole block, and that only lines up if the two agree on what a line is. Left
 * to inherit, `1lh` picks up whatever leading the host page happens to set and
 * the tick drifts a pixel or two off the text beside it.
 */
export const tickRowLeadingClasses = 'leading-[1.4]';

/**
 * What a finger gets, on a control drawn smaller than one.
 *
 * A tick, a switch and the × on a Chip are all sized against the text beside
 * them, and text is smaller than 24px — which is what WCAG 2.5.8 asks a target
 * to be in both directions. The class grows the pressable box and draws
 * nothing; `styles.css` says how, and why it is CSS rather than an arbitrary
 * variant. It needs `relative` on the element, which every control that uses it
 * already has.
 *
 * Not applied to the controls on the height ladder. A Button at `xs` is 22px
 * tall and equally short of the minimum, but a Button sits in a row of other
 * Buttons and its label is the target — growing it two pixels past its own edge
 * would take the press off whatever it was next to.
 */
export const hitAreaClasses = 'neba-hit';

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
 * The two ends of a popup's fade: not there yet, and not there any more.
 *
 * Split out from `popupFadeClasses` below for exactly one caller —
 * NavigationMenu's popup also travels in width and height as the reader moves
 * between two menus, so its `transition` shorthand has to name three properties
 * and a second shorthand beside it would win or lose by stylesheet order rather
 * than by intent. Everything else wants the whole thing.
 */
export const popupFadeStateClasses =
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0';

/**
 * How every floating surface in the library arrives and leaves.
 *
 * Opacity, and nothing else. A popup that scales or slides has spent 160ms
 * dragging its own text across the screen — and unlike a control, a popup is
 * mostly text: a menu row the pointer was already reaching for, a dialog
 * somebody has started reading, a calendar cell under a finger that is already
 * moving. The house rule against transforming a control is the same rule, and
 * this is where it lands for the things that float.
 *
 * It is written here rather than in each of them because there were fourteen
 * copies of it and the fifteenth and sixteenth — Select's popup and Combobox's —
 * were never written at all, which is the failure mode a shared table exists to
 * prevent. Base UI supplies the `data-starting-style` / `data-ending-style` pair
 * on every popup, backdrop and toast, so the same two lines fit all of them.
 */
export const popupFadeClasses = [
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  popupFadeStateClasses
].join(' ');

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

/**
 * Text for a screen reader and nobody else: the sentence behind a bare number
 * on a Badge, the page number under a Pagination chevron, the file count a
 * FilePicker reports.
 *
 * Not `hidden`, not `display:none` and not `opacity:0` — the first two take the
 * text off the accessibility tree along with the screen, and the third leaves a
 * clickable ghost the size of the words. A 1px clipped box is the one form that
 * is invisible to a sighted reader and present to every other kind.
 */
export const srOnlyClasses =
  'absolute size-px overflow-hidden whitespace-nowrap [clip-path:inset(50%)]';

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

/**
 * The × that removes a chip.
 *
 * Written once because two components draw it: Chip's own `onDelete`, and the
 * chips a multi-select Combobox puts inside its field. The second one is a Base
 * UI `Combobox.ChipRemove` rather than a plain button, so what is shared is the
 * class string and not the element — which is exactly the split the rest of
 * this file makes.
 *
 * Sized in `em` so it tracks the chip's label at every step of the scale, and
 * it is the one place in the library where `opacity` carries a state: this is
 * not a control changing what it is, it is an affordance that stays out of the
 * way of the word beside it until the pointer is on it.
 */
export const chipRemoveClasses = [
  'relative ms-0.5 inline-flex shrink-0 items-center justify-center rounded-full',
  'size-[1.15em] cursor-pointer opacity-70',
  // Drawn at the size of the word beside it, pressed at the size of a finger.
  hitAreaClasses,
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'hover:opacity-100 focus-visible:opacity-100',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
  'disabled:cursor-not-allowed'
].join(' ');

/** `false`, `null`, `undefined` and `''` all mean "this slot is not filled". */
export function hasContent(node: React.ReactNode): boolean {
  return node !== undefined && node !== null && node !== false && node !== '';
}

/**
 * A number is pixels; a string is already a CSS length, and nothing at all
 * stays nothing.
 *
 * The one rule the library makes about a length a caller writes: `width={240}`
 * and `width="15rem"` are both accepted and the number is never guessed at. It
 * lives here rather than in whichever component needed it first because a
 * second copy would eventually disagree about `0` — which is falsy, and is a
 * length.
 */
export function toLength(value: number | string | undefined): string | undefined {
  if (value === undefined || value === null) return undefined;

  return typeof value === 'number' ? `${value}px` : value;
}

/** The four units a length prop is allowed to be written in. */
const LENGTH = /^\s*(-?[\d.]+)\s*(px|rem|em|%)\s*$/;

/**
 * The other direction: a CSS length a caller wrote, as the number a drag can do
 * arithmetic on.
 *
 * `toLength` is what a component hands the browser; this is what it needs back
 * the moment a gesture has to clamp against the value — a Sidebar's `minWidth`,
 * a Panes' `maxSize`. Both wrote their own, and the copies disagreed: one of
 * them resolved `em` against the document root, which is what `rem` means, so a
 * `minWidth="2em"` on a sidebar with type of its own came out wrong.
 *
 * `percentOf` is what a percentage is a percentage *of*, because that differs:
 * a Sidebar is bounded against the window and a pane against the split it sits
 * in. `relativeTo` is the element `em` is measured against — its own font size,
 * which is the whole difference between the two units.
 *
 * A bare number is deliberately **not** handled. It means pixels on one of them
 * and a percentage on the other, and that is a question about the prop rather
 * than about the length.
 */
export function toPixels(
  value: string,
  options: { percentOf: number; relativeTo?: Element | null }
): number | undefined {
  const match = LENGTH.exec(value);

  if (!match) return undefined;

  const amount = Number(match[1]);

  if (Number.isNaN(amount)) return undefined;

  switch (match[2]) {
    case 'px':
      return amount;
    case '%':
      return (options.percentOf * amount) / 100;
    case 'em':
      return amount * fontSize(options.relativeTo);
    default:
      return amount * fontSize(typeof document === 'undefined' ? null : document.documentElement);
  }
}

/** An element's own type size, in pixels, with the browser's default as the floor. */
function fontSize(element: Element | null | undefined): number {
  if (!element || typeof getComputedStyle === 'undefined') return 16;

  return parseFloat(getComputedStyle(element).fontSize) || 16;
}

/** Joins class name fragments, dropping the empty ones. */
export function cx(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(' ');
}

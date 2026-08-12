import * as React from 'react';
import type { NebaColor } from '../types';

/**
 * The glyphs more than one component draws.
 *
 * All of them are 16×16 with a 1.5px stroke and no fill except where a dot is
 * meant to read as solid, and none of them carries a size: `iconClasses` in
 * `styles.ts` sizes every icon in `em`, so one drawing serves every step of the
 * scale.
 *
 * They live here rather than in the components for the ordinary reason — the ×
 * on a Chip, an Alert, a Dialog and a Toast is one × — and for one that matters
 * more: the severity set is a piece of the design language. An alert that says
 * "this went wrong" only in red says it only to some readers, so the shape has
 * to carry the meaning too, and that only holds if every component uses the
 * same shape for the same family.
 */

export function CloseIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m4.5 4.5 7 7m0-7-7 7"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * The disclosure chevron, drawn pointing **down**.
 *
 * One drawing for every direction: a Select's trigger, an Accordion's header, a
 * submenu's arrow and a Pagination's steppers all want the same wedge turned a
 * different way, and turning it is the one allowance the no-transform rule
 * makes — a glyph has no text in it to resample.
 */
export function ChevronIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m4.5 6.5 3.5 3.5 3.5-3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** The tick: a chosen option, a ticked menu item. */
export function CheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m3.5 8.5 3 3 6-6"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The two steppers, and the `+` that offers a value the list does not have.
 *
 * They are a pair and stay one: a minus drawn to a different weight from the
 * plus beside it reads as two toolkits in one control. NumberField draws both;
 * Combobox draws the plus on its "add this" row.
 */
export function MinusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

export function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

/**
 * The two trend arrows a comparison draws.
 *
 * A pair, and they stay one: an arrow that rises at a different angle from the
 * one that falls beside it reads as two toolkits in one report. Statistic draws
 * both, and reaches for `MinusIcon` above when a figure has not moved — the
 * third state of a comparison is genuinely the absence of an arrow.
 *
 * The shape carries the meaning for the same reason the severity set does: a
 * delta that says "down" only in red says it only to some readers.
 */
export function TrendUpIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3 11 6.5 7.5 9 10l4-4"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M9.5 6h3.5v3.5"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export function TrendDownIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3 5 6.5 8.5 9 6l4 4"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M9.5 10h3.5V6.5"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The two glyphs a picker's trigger wears.
 *
 * They are a pair in the same sense the steppers are: a DateTimePicker draws
 * only the calendar, because a control cannot say two things at once and the
 * date is the part you scan for. Drawn on the same 16×16 grid at the same
 * weight, so a row of a DatePicker and a TimePicker does not look like two
 * icon sets pushed together.
 */
export function CalendarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect
        x="2"
        y="3.25"
        width="12"
        height="10.75"
        rx="2"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path d="M2 6.75h12" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M5.25 1.75v2.5M10.75 1.75v2.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function ClockIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M8 4.5V8l2.4 1.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The arrow between the two ends of a range.
 *
 * Drawn pointing right and turned under RTL by the component, for the same
 * reason the chevron is: it is a glyph, and there is no text in it to resample.
 */
export function ArrowRightIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3 8h10m-3.5-3.5L13 8l-3.5 3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The two marks a link wears.
 *
 * A pair for the same reason the steppers are: they answer the same question —
 * "where does this go" — and a chain drawn at one weight beside an arrow drawn
 * at another reads as two icon sets in one paragraph. The chain says "this is a
 * link", the arrow leaving its box says "and it leaves this page", which is the
 * one thing about a link that is invisible until it has already happened.
 *
 * TextLink draws whichever one matches its `newTab`; a ChatBubble's link
 * preview draws the chain beside the site it points at.
 */
export function LinkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.5 9.5a2.75 2.75 0 0 0 4 .25l1.75-1.75a2.75 2.75 0 0 0-3.9-3.9L7.75 5.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 6.5a2.75 2.75 0 0 0-4-.25L3.75 8a2.75 2.75 0 0 0 3.9 3.9l.6-.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function ExternalLinkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M12.75 9.25v2.5a1.5 1.5 0 0 1-1.5 1.5h-7a1.5 1.5 0 0 1-1.5-1.5v-7a1.5 1.5 0 0 1 1.5-1.5h2.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 2.75h3.75V6.5M7.25 8.75l5.75-5.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The three dots that stand for what has been left out.
 *
 * Drawn rather than typed: `…` is a single glyph whose dots are spaced by
 * whatever font the page happens to load, and it sits on the baseline rather
 * than in the middle of the row it is standing in for. Breadcrumb draws it on
 * the button that opens the collapsed middle of a trail.
 */
export function EllipsisIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="3.5" cy="8" r="1.15" fill="currentColor" />
      <circle cx="8" cy="8" r="1.15" fill="currentColor" />
      <circle cx="12.5" cy="8" r="1.15" fill="currentColor" />
    </svg>
  );
}

/**
 * The star a Rating is drawn out of, as one path used twice.
 *
 * Two components rather than one with a prop, and one geometry rather than two
 * drawings, because the empty star and the filled one are laid *on top of each
 * other*: a Rating shows a fraction by clipping the filled copy to a percentage
 * of the width, and a half star only lands on the outline if the two shapes are
 * congruent to the pixel. Two hand-drawn stars would be half a pixel apart at
 * some size, and that shows up as a shadow along one edge of every star.
 *
 * The points are a regular five-pointed star about (8, 8) — outer radius 6.6,
 * inner 2.9 — with round joins, which is what keeps the stroked copy inside the
 * 16×16 box that every other glyph here is drawn in.
 */
const starPath =
  'M8 1.4 9.71 5.65 14.28 5.96 10.76 8.9 11.88 13.34 8 10.9 4.12 13.34 5.24 8.9 1.72 5.96 6.29 5.65Z';

export function StarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d={starPath} fill="currentColor" stroke="currentColor" strokeLinejoin="round" />
    </svg>
  );
}

export function StarOutlineIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d={starPath} stroke="currentColor" strokeWidth="1.25" strokeLinejoin="round" />
    </svg>
  );
}

/** The filled dot: the chosen one of a set, where a tick would say "and". */
export function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="3.25" fill="currentColor" />
    </svg>
  );
}

/** The neutral note: a circled `i` without the serif problem an `i` has at 16px. */
function NoteIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="M8 7.25v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="8" cy="4.9" r="0.85" fill="currentColor" />
    </svg>
  );
}

/**
 * One drawing per colour family.
 *
 * `primary` and `secondary` have no severity to draw, so they take the note the
 * informational one uses — three shapes for six families, because the three
 * that mean something are the three worth telling apart.
 */
export const severityIcons: Record<NebaColor, React.ReactNode> = {
  primary: <NoteIcon />,
  secondary: <NoteIcon />,
  info: <NoteIcon />,
  success: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m5.25 8.25 1.9 1.9 3.6-3.9"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  ),
  warning: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M7.13 2.6 1.9 11.7a1 1 0 0 0 .87 1.5h10.46a1 1 0 0 0 .87-1.5L8.87 2.6a1 1 0 0 0-1.74 0Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8 6.1v3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="8" cy="11.2" r="0.85" fill="currentColor" />
    </svg>
  ),
  danger: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m5.9 5.9 4.2 4.2m0-4.2-4.2 4.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  )
};

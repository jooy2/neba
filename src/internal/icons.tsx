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

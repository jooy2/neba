/**
 * The chrome a WindowPane draws, and the tables that say how big it is.
 *
 * It lives here for the reason `internal/mockup.tsx` does. One component reads
 * it, but what it holds is reference data rather than a piece of that component
 * — four systems' worth of title bars, three buttons each, drawn four different
 * ways — and a component file with all of that in it would be a table with a
 * `forwardRef` at the bottom.
 *
 * Two conventions run through it:
 *
 * **Every length is a CSS pixel at `md`, scaled once by `size`.** A title bar is
 * 36px on Windows and 38px on macOS because those are the heights they are, not
 * because a ladder in `internal/styles.ts` says so — this is the one place in
 * the library where the numbers come from somewhere else. `size` multiplies
 * them, which is why they are written as numbers rather than as utilities.
 *
 * **The buttons are drawings of what they do and carry no other party's marks.**
 * A traffic light is three circles, a Windows control is a line, a box and a
 * cross. Their names come from `internal/i18n.ts` and are read out; nothing here
 * writes a word.
 */

import * as React from 'react';
import { cx } from './styles';
import type { NebaColor, NebaSize } from '../types';

/* ---------------------------------------------------------------------------
 * The vocabulary
 *
 * WindowPane's public types, declared here because the drawings below need
 * them. `WindowPane.tsx` re-exports them, so a caller never learns this file
 * exists.
 * ------------------------------------------------------------------------- */

/**
 * Whose window this is a picture of.
 *
 * Windows is two entries rather than one, and it is the only system here that
 * is: 10 and 11 differ in exactly the things this component draws — square
 * corners against rounded ones, a title bar that takes the accent colour
 * against one that does not. Every other system's versions differ in ways a
 * title bar does not show.
 *
 * `windows11` rather than `win11`, and `macos` rather than `mac`: these are the
 * names the systems have.
 */
export type NebaWindowOs = 'macos' | 'windows11' | 'windows10' | 'linux';

/** The three buttons a title bar can carry. */
export type NebaWindowControl = 'minimize' | 'maximize' | 'close';

/** How far the window has been dragged from where the layout put it. */
export interface NebaWindowOffset {
  x: number;
  y: number;
}

/* ---------------------------------------------------------------------------
 * Metrics
 * ------------------------------------------------------------------------- */

/** Everything the component needs to lay a title bar out, in CSS pixels. */
export interface WindowMetrics {
  /** The title bar's height. */
  bar: number;
  /** The window's own corner. */
  radius: number;
  /** The air either side of what is in the bar. */
  padX: number;
  /** Between one control and the next. */
  gap: number;
  /** The title's type size. */
  title: number;
  /** One control's box. */
  control: { width: number; height: number };
  /** How much room the whole set of them takes, given how many are drawn. */
  controlsWidth: (count: number) => number;
}

interface WindowChrome extends Omit<WindowMetrics, 'controlsWidth'> {
  /** Where the title sits along the bar. */
  titleAlign: 'start' | 'center';
  /** Which end the controls are on. */
  controlsSide: 'start' | 'end';
  /** How one control is drawn. */
  shape: 'dot' | 'square' | 'circle';
  /** Whether the bar is separated from the body by a hairline. */
  rule: boolean;
}

/**
 * The four systems, at `md`.
 *
 * macOS puts three coloured dots on the left and centres the title over the
 * whole window; Windows puts three rectangles on the right and sets the title
 * beside the icon; a GNOME header bar is taller than either, centres its title
 * and draws its buttons as circles. Those four sentences are the whole of what
 * this component knows about operating systems.
 */
const chromes: Record<NebaWindowOs, WindowChrome> = {
  macos: {
    bar: 38,
    radius: 10,
    padX: 12,
    gap: 8,
    title: 13,
    control: { width: 12, height: 12 },
    titleAlign: 'center',
    controlsSide: 'start',
    shape: 'dot',
    rule: false
  },
  windows11: {
    bar: 36,
    radius: 8,
    padX: 12,
    gap: 0,
    title: 12,
    control: { width: 44, height: 36 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: false
  },
  windows10: {
    // Square corners, a shorter bar and a rule under it: the three things that
    // say "not 11" at a glance.
    bar: 32,
    radius: 0,
    padX: 10,
    gap: 0,
    title: 12,
    control: { width: 45, height: 32 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: true
  },
  linux: {
    bar: 46,
    radius: 12,
    padX: 12,
    gap: 8,
    title: 14,
    control: { width: 26, height: 26 },
    titleAlign: 'center',
    controlsSide: 'end',
    shape: 'circle',
    rule: false
  }
};

/**
 * `size` on a WindowPane, and the third component after Box and Mockup where it
 * does not mean a control height.
 *
 * What it scales is the chrome — the bar, the buttons, the title — and nothing
 * else: a window's *content* is the caller's and is laid out at its own scale,
 * exactly as it would be on a real desktop where the title bar does not grow
 * with the document. The steps are gentle for the same reason a 24px title bar
 * is not a smaller title bar but an unusable one.
 */
const scales: Record<NebaSize, number> = {
  xs: 0.75,
  sm: 0.875,
  md: 1,
  lg: 1.15,
  xl: 1.3
};

export function windowMetrics(os: NebaWindowOs, size: NebaSize): WindowMetrics {
  const chrome = chromes[os];
  const scale = scales[size];
  const round = (value: number) => Math.round(value * scale);

  const control = { width: round(chrome.control.width), height: round(chrome.control.height) };
  const gap = round(chrome.gap);

  return {
    bar: round(chrome.bar),
    // The corner is *not* scaled with the rest: it is the shape of the window
    // rather than a measure of its chrome, and a `xs` macOS window with a 7px
    // corner stops reading as macOS.
    radius: chrome.radius,
    padX: round(chrome.padX),
    gap,
    title: round(chrome.title),
    control,
    controlsWidth: (count: number) => (count <= 0 ? 0 : count * control.width + (count - 1) * gap)
  };
}

export function windowChrome(os: NebaWindowOs): WindowChrome {
  return chromes[os];
}

/**
 * The order the buttons go in, per system, and the reason `controls` is a set
 * rather than a list: which three a window has is the caller's decision, and
 * what order they sit in is the system's.
 */
const controlOrder: Record<NebaWindowOs, readonly NebaWindowControl[]> = {
  macos: ['close', 'minimize', 'maximize'],
  windows11: ['minimize', 'maximize', 'close'],
  windows10: ['minimize', 'maximize', 'close'],
  linux: ['minimize', 'maximize', 'close']
};

export function orderControls(
  os: NebaWindowOs,
  controls: readonly NebaWindowControl[]
): NebaWindowControl[] {
  return controlOrder[os].filter((control) => controls.includes(control));
}

/* ---------------------------------------------------------------------------
 * Colour
 *
 * Everything a window is painted with goes through four slots, so the component
 * itself never writes a colour and a caller can reach any of them. They are
 * computed rather than tabled because two props — `accent` and `transparency` —
 * are continuous, and `color-mix()` is the only thing that can state "this
 * surface, but 30% of it is whatever is behind the window".
 * ------------------------------------------------------------------------- */

/** Mixes a colour toward nothing. `0` leaves it exactly as it was. */
function veil(color: string, transparency: number): string {
  const keep = Math.round((1 - transparency) * 100);

  return keep >= 100 ? color : `color-mix(in oklab, ${color} ${keep}%, transparent)`;
}

/**
 * How much of the page's own ink is stirred into the title bar of each system,
 * as a percentage. macOS and Windows 11 keep the bar and the body all but the
 * same shade; Windows 10 draws a white bar with a rule under it; a GNOME header
 * bar is visibly darker than what is under it.
 */
const barTints: Record<NebaWindowOs, number> = {
  macos: 6,
  windows11: 3,
  windows10: 0,
  linux: 11
};

export function windowSlots(options: {
  os: NebaWindowOs;
  color: NebaColor;
  accent: boolean;
  transparency: number;
  active: boolean;
}): React.CSSProperties {
  const { os, color, accent, transparency, active } = options;
  const veiled = Math.min(Math.max(transparency, 0), 1);

  const surface = 'var(--neba-surface)';
  const tint = barTints[os];
  const plain =
    tint === 0 ? surface : `color-mix(in oklab, ${surface} ${100 - tint}%, var(--neba-fg))`;

  // An inactive window keeps its shape and loses its emphasis — the same axis
  // `readOnly` uses on a control, and never `opacity`, which would fade the
  // content along with the chrome.
  const bar = accent && active ? `var(--neba-${color}-solid)` : plain;
  const barFg =
    accent && active
      ? `var(--neba-${color}-on-solid)`
      : active
        ? 'var(--neba-fg)'
        : 'var(--neba-muted-fg)';

  return {
    '--n-window-bar': veil(bar, veiled),
    '--n-window-bar-fg': barFg,
    '--n-window-body': veil(surface, veiled),
    '--n-window-line': accent && active ? `var(--neba-${color}-line)` : 'var(--neba-border)',
    // What a control's own hover is mixed out of, which is the ink on the bar
    // rather than the page's: a button hovered on an accent-coloured title bar
    // has to lighten it, not dirty it.
    '--n-window-hover': 'color-mix(in oklab, currentColor 12%, transparent)',
    '--n-window-press': 'color-mix(in oklab, currentColor 20%, transparent)',
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-ring': `var(--neba-${color}-ring)`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * The glyphs
 *
 * Drawn on a 10×10 grid and scaled by the caller, so a Windows minimize and a
 * macOS one are the same line at two sizes rather than two drawings.
 * ------------------------------------------------------------------------- */

function Glyph({ size, children }: { size: number; children: React.ReactNode }) {
  return (
    <svg
      viewBox="0 0 10 10"
      width={size}
      height={size}
      fill="none"
      stroke="currentColor"
      strokeWidth={1}
      strokeLinecap="square"
      aria-hidden="true"
    >
      {children}
    </svg>
  );
}

function controlGlyph(control: NebaWindowControl, maximized: boolean, size: number) {
  if (control === 'minimize') {
    return (
      <Glyph size={size}>
        <path d="M1.5 5h7" />
      </Glyph>
    );
  }

  if (control === 'close') {
    return (
      <Glyph size={size}>
        <path d="m1.6 1.6 6.8 6.8M8.4 1.6 1.6 8.4" />
      </Glyph>
    );
  }

  // Restore is two boxes, one behind the other — the drawing every system uses
  // to say "this window came from somewhere smaller".
  return maximized ? (
    <Glyph size={size}>
      <path d="M1.5 3.5h5v5h-5z" />
      <path d="M3.5 3.5v-2h5v5h-2" />
    </Glyph>
  ) : (
    <Glyph size={size}>
      <path d="M1.5 1.5h7v7h-7z" />
    </Glyph>
  );
}

/** The traffic lights, which are hardware colours rather than theme tokens: a
 *  red close button is red on a page switched to dark. */
const trafficColors: Record<NebaWindowControl, string> = {
  close: '#ff5f57',
  minimize: '#febc2e',
  maximize: '#28c840'
};

/** What Windows turns the close button when the pointer is on it. */
const closeHover: Record<NebaWindowOs, string | null> = {
  macos: null,
  windows11: '#c42b1c',
  windows10: '#e81123',
  linux: null
};

export interface WindowControlsProps {
  os: NebaWindowOs;
  metrics: WindowMetrics;
  controls: readonly NebaWindowControl[];
  maximized: boolean;
  active: boolean;
  /** What each button is called, plus the word the maximize one takes once the
   *  window is maximized. */
  labels: Record<NebaWindowControl | 'restore', string>;
  onCommand: (control: NebaWindowControl) => void;
}

/**
 * The buttons on a title bar.
 *
 * Real `<button>`s with real names, in every system: the whole point of drawing
 * a window rather than a picture of one is that its controls work, and a
 * `<div>` with a click handler on it is invisible to a keyboard. They also stop
 * the press from reaching the bar underneath, or every close would begin by
 * dragging the window half a pixel.
 */
export function WindowControls({
  os,
  metrics,
  controls,
  maximized,
  active,
  labels,
  onCommand
}: WindowControlsProps) {
  const ordered = orderControls(os, controls);

  if (ordered.length === 0) {
    return null;
  }

  const dots = chromes[os].shape === 'dot';
  const circles = chromes[os].shape === 'circle';
  const glyph = Math.round(metrics.control.height * (dots ? 0.62 : circles ? 0.42 : 0.28));

  return (
    <div
      // `group/controls` is what lets the traffic lights hold their glyphs back
      // until the pointer is on the set rather than on one of them, which is how
      // the originals behave — the three are one control in three parts.
      className="group/controls flex shrink-0 items-center"
      style={{ gap: metrics.gap }}
      // The bar under it drags the window; the buttons on it do not.
      onPointerDown={(event) => event.stopPropagation()}
      onDoubleClick={(event) => event.stopPropagation()}
    >
      {ordered.map((control) => {
        const name = control === 'maximize' && maximized ? labels.restore : labels[control];
        const danger = control === 'close' ? closeHover[os] : null;

        return (
          <button
            key={control}
            type="button"
            aria-label={name}
            title={name}
            className={cx(
              'relative flex shrink-0 items-center justify-center',
              '[transition:background-color_var(--neba-duration)_var(--neba-ease)]',
              'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
              'cursor-pointer',
              dots
                ? 'rounded-full'
                : circles
                  ? 'rounded-full bg-(--n-window-hover) hover:bg-(--n-window-press)'
                  : 'hover:bg-(--n-window-hover) active:bg-(--n-window-press)',
              // The one place a Windows control leaves the theme: its close
              // button turns the system's own red, with a white cross on it.
              danger ? 'hover:bg-(--n-window-danger) hover:text-white' : ''
            )}
            style={
              {
                width: dots ? metrics.control.height : metrics.control.width,
                height: metrics.control.height,
                // A traffic light that is not on the front window is grey, which
                // is the only thing about it that says so.
                background: dots
                  ? active
                    ? trafficColors[control]
                    : 'color-mix(in oklab, var(--neba-fg) 22%, transparent)'
                  : undefined,
                color: dots ? 'rgb(0 0 0 / 0.55)' : undefined,
                ...(danger ? { '--n-window-danger': danger } : {})
              } as React.CSSProperties
            }
            onClick={() => onCommand(control)}
          >
            {/*
              On macOS the glyph is an affordance rather than a state: it stays
              out of the way of a window that is only being looked at, and comes
              back the moment the pointer is over the set. That is the same
              exception `chipRemoveClasses` makes to the rule against carrying
              state in `opacity` — nothing here is changing what it is.
            */}
            <span
              className={cx(
                'flex items-center justify-center',
                dots
                  ? 'opacity-0 [transition:opacity_var(--neba-duration)_var(--neba-ease)] group-hover/controls:opacity-100'
                  : ''
              )}
            >
              {controlGlyph(control, maximized, glyph)}
            </span>
          </button>
        );
      })}
    </div>
  );
}

/**
 * The chrome a WindowPane draws, and the tables that say how big it is.
 *
 * It lives here for the reason `internal/mockup.tsx` does. One component reads
 * it, but what it holds is reference data rather than a piece of that component
 * — four systems' worth of title bars, three buttons each, drawn four different
 * ways — and a component file with all of that in it would be a table with a
 * `forwardRef` at the bottom.
 *
 * Three conventions run through it:
 *
 * **Every length is a CSS pixel at `md`, scaled once by `size`.** A title bar is
 * 32px on Windows 11 and 38px on macOS because those are the heights they are,
 * not because a ladder in `internal/styles.ts` says so — this is the one place
 * in the library where the numbers come from somewhere else. `size` multiplies
 * them, which is why they are written as numbers rather than as utilities.
 *
 * **The buttons are drawings of what they do and carry no other party's marks.**
 * A traffic light is three circles; a Windows control is a line, a box and a
 * cross. Their names come from `internal/i18n.ts` and are read out; nothing here
 * writes a word.
 *
 * **Nothing is mixed out of `currentColor`.** Every fill a control can take is a
 * slot computed once in `windowSlots`, because a hover that changes the ink and
 * a fill derived from the ink are the same declaration arguing with itself —
 * which is exactly how a close button ends up white on white.
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
 * is: 10 and 11 differ in exactly the things a title bar shows — square corners
 * against rounded ones, a ruled white bar against one that is the same sheet as
 * the window, sharp glyphs against rounded ones, and a border that takes the
 * accent colour on one and not the other. Every other system's versions differ
 * in ways this component does not draw.
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
  /** The air at the leading edge of the bar. */
  padX: number;
  /** And at the trailing edge, which is nothing where the buttons run to it. */
  padEnd: number;
  /** Between one control and the next. */
  gap: number;
  /** The title's type size. */
  title: number;
  /** One control's box. */
  control: { width: number; height: number };
  /** The mark inside it. */
  glyph: number;
  /** How much room the whole set of them takes, given how many are drawn. */
  controlsWidth: (count: number) => number;
}

interface WindowChrome {
  bar: number;
  radius: number;
  padX: number;
  gap: number;
  title: number;
  glyph: number;
  control: { width: number; height: number };
  /** Where the title sits along the bar. */
  titleAlign: 'start' | 'center';
  /** Which end the controls are on. */
  controlsSide: 'start' | 'end';
  /** How one control is drawn. */
  shape: 'dot' | 'square' | 'circle';
  /** Whether the bar is ruled off from the body. */
  rule: boolean;
  /** How thick the glyphs are drawn. */
  stroke: number;
  /** The corner on the maximize box: Windows 11 rounds it, Windows 10 does not. */
  boxRadius: number;
  /** How much of the page's ink is stirred into the bar, in front and behind. */
  tint: [number, number];
  /** Whether an accented window carries the colour into its border as well. */
  accentBorder: boolean;
}

/**
 * The four systems, at `md`.
 *
 * macOS puts three coloured dots on the left and centres the title over the
 * whole window. Windows puts three full-height rectangles hard against the
 * top-right corner — they are wide because they are a corner target, and that
 * is what makes a Windows title bar recognisable at a glance. A GNOME header
 * bar is taller than either, centres its title and draws its buttons as small
 * circles held clear of the edge.
 */
const chromes: Record<NebaWindowOs, WindowChrome> = {
  macos: {
    bar: 38,
    radius: 10,
    padX: 12,
    gap: 8,
    title: 13,
    glyph: 7,
    control: { width: 12, height: 12 },
    titleAlign: 'center',
    controlsSide: 'start',
    shape: 'dot',
    rule: false,
    stroke: 1.4,
    boxRadius: 0,
    tint: [6, 3],
    accentBorder: false
  },
  windows11: {
    // 32px bar, 46×32 buttons: the real proportion, and the reason the buttons
    // reach the top edge of the window rather than sitting inside a padding.
    bar: 32,
    radius: 8,
    padX: 12,
    gap: 0,
    title: 12,
    glyph: 10,
    control: { width: 46, height: 32 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: false,
    // Mica: the bar is the same sheet as the window, and what separates them is
    // the title and the buttons rather than a change of shade.
    tint: [3, 1],
    stroke: 1,
    boxRadius: 1.6,
    accentBorder: false
  },
  windows10: {
    // Square corners, a shorter bar, a rule under it, thinner glyphs and a
    // border that takes the accent colour: the five things that say "not 11".
    bar: 30,
    radius: 0,
    padX: 10,
    gap: 0,
    title: 12,
    glyph: 10,
    control: { width: 45, height: 30 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: true,
    tint: [0, 0],
    stroke: 0.9,
    boxRadius: 0,
    accentBorder: true
  },
  linux: {
    bar: 44,
    radius: 12,
    padX: 10,
    gap: 6,
    title: 14,
    glyph: 10,
    control: { width: 24, height: 24 },
    titleAlign: 'center',
    controlsSide: 'end',
    shape: 'circle',
    rule: false,
    stroke: 1.2,
    boxRadius: 0,
    tint: [11, 5],
    accentBorder: false
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
  xs: 0.8,
  sm: 0.9,
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
    // rather than a measure of its chrome, and an `xs` macOS window with a 7px
    // corner stops reading as macOS.
    radius: chrome.radius,
    padX: round(chrome.padX),
    // A Windows caption button is a corner target — it runs to the edge of the
    // window, which is what makes it hittable by throwing the pointer at the
    // corner. Everything else keeps its air.
    padEnd: chrome.shape === 'square' ? 0 : round(chrome.padX),
    gap,
    title: round(chrome.title),
    glyph: round(chrome.glyph),
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
 * Everything a window is painted with goes through slots, so the component
 * itself never writes a colour and a caller can reach any of them. They are
 * computed rather than tabled because three of the props they answer to —
 * `accent`, `transparency` and whether the window is in front — are continuous
 * or combinatorial, and `color-mix()` is the only thing that can state "this
 * surface, but 30% of it is whatever is behind the window".
 * ------------------------------------------------------------------------- */

/** Mixes a colour toward nothing. `0` leaves it exactly as it was. */
function veil(color: string, transparency: number): string {
  const keep = Math.round((1 - transparency) * 100);

  return keep >= 100 ? color : `color-mix(in oklab, ${color} ${keep}%, transparent)`;
}

export function windowSlots(options: {
  os: NebaWindowOs;
  color: NebaColor;
  accent: boolean;
  transparency: number;
  active: boolean;
  elevation: number;
}): React.CSSProperties {
  const { os, color, accent, transparency, active, elevation } = options;
  const chrome = chromes[os];
  const veiled = Math.min(Math.max(transparency, 0), 1);

  const surface = 'var(--neba-surface)';
  const tint = chrome.tint[active ? 0 : 1];
  const plain =
    tint === 0 ? surface : `color-mix(in oklab, ${surface} ${100 - tint}%, var(--neba-fg))`;

  // A window behind the one in front keeps its shape and loses its emphasis —
  // its colour drains, its shadow drops a step and its title greys. Never
  // `opacity`, which would take the content down with the chrome.
  const dyed = accent && active;
  const bar = dyed ? `var(--neba-${color}-solid)` : plain;
  const barFg = dyed
    ? `var(--neba-${color}-on-solid)`
    : active
      ? 'var(--neba-fg)'
      : 'var(--neba-muted-fg)';

  const line =
    dyed && chrome.accentBorder
      ? `var(--neba-${color}-solid)`
      : active
        ? 'var(--neba-border)'
        : 'color-mix(in oklab, var(--neba-border) 55%, transparent)';

  return {
    '--n-window-bar': veil(bar, veiled),
    '--n-window-bar-fg': barFg,
    '--n-window-body': veil(surface, veiled),
    '--n-window-line': line,
    // What a control's hover is mixed out of. Fixed rather than derived from
    // `currentColor`: the close button turns its own ink white on hover, and a
    // fill mixed out of that ink would turn white with it — which is a close
    // button that disappears at the moment it is aimed at.
    '--n-window-hover': dyed
      ? 'rgb(255 255 255 / 0.18)'
      : 'color-mix(in oklab, var(--neba-fg) 9%, transparent)',
    '--n-window-press': dyed
      ? 'rgb(255 255 255 / 0.28)'
      : 'color-mix(in oklab, var(--neba-fg) 16%, transparent)',
    // The window in front sits a step further off the page than the ones behind
    // it. This is the whole of what "highlighted" means here — a ring around a
    // window is not something any of these four systems draws.
    '--n-window-shadow': `var(--neba-shadow-${active ? elevation : Math.max(elevation - 1, 0)})`,
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-ring': `var(--neba-${color}-ring)`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * The glyphs
 *
 * Drawn on a 10×10 grid and scaled by the caller, so a Windows minimize and a
 * GNOME one are the same line at two weights rather than two drawings. The
 * weight and the corner are the system's: Windows 11 rounds the maximize box
 * and draws it at a full pixel, Windows 10 leaves it sharp and hairline-thin.
 * ------------------------------------------------------------------------- */

function Glyph({
  size,
  stroke,
  round,
  children
}: {
  size: number;
  stroke: number;
  round: boolean;
  children: React.ReactNode;
}) {
  return (
    <svg
      viewBox="0 0 10 10"
      width={size}
      height={size}
      fill="none"
      stroke="currentColor"
      strokeWidth={stroke}
      strokeLinecap={round ? 'round' : 'square'}
      strokeLinejoin={round ? 'round' : 'miter'}
      aria-hidden="true"
    >
      {children}
    </svg>
  );
}

function controlGlyph(
  control: NebaWindowControl,
  maximized: boolean,
  chrome: WindowChrome,
  size: number
) {
  const stroke = chrome.stroke;
  const round = chrome.boxRadius > 0 || chrome.shape !== 'square';
  const r = chrome.boxRadius;

  if (control === 'minimize') {
    return (
      <Glyph size={size} stroke={stroke} round={round}>
        <path d="M1.5 5h7" />
      </Glyph>
    );
  }

  if (control === 'close') {
    return (
      <Glyph size={size} stroke={stroke} round={round}>
        <path d="m1.6 1.6 6.8 6.8M8.4 1.6 1.6 8.4" />
      </Glyph>
    );
  }

  // Restore is two boxes, one behind the other — the drawing every system uses
  // to say "this window came from somewhere smaller".
  return maximized ? (
    <Glyph size={size} stroke={stroke} round={round}>
      <rect x="1.4" y="3.4" width="5.2" height="5.2" rx={r} />
      <path d="M3.6 3.4v-2h5v5h-2" />
    </Glyph>
  ) : (
    <Glyph size={size} stroke={stroke} round={round}>
      <rect x="1.5" y="1.5" width="7" height="7" rx={r} />
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
  const chrome = chromes[os];
  const ordered = orderControls(os, controls);

  if (ordered.length === 0) {
    return null;
  }

  const dots = chrome.shape === 'dot';
  const circles = chrome.shape === 'circle';

  return (
    <div
      // `group/controls` is what lets the traffic lights hold their glyphs back
      // until the pointer is on the set rather than on one of them, which is how
      // the originals behave — the three are one control in three parts.
      className="group/controls flex shrink-0 items-center self-stretch"
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
              'relative flex shrink-0 cursor-pointer items-center justify-center',
              '[transition:background-color_var(--neba-duration)_var(--neba-ease),color_var(--neba-duration)_var(--neba-ease)]',
              'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
              dots ? 'rounded-full' : circles ? 'rounded-full bg-(--n-window-hover)' : '',
              // An if/else rather than two hover classes of equal specificity:
              // which of them won would be decided by their order in the
              // generated stylesheet, which is not something a component may
              // depend on. It is also the bug that made the × vanish — the
              // neutral fill was mixed out of `currentColor`, which the same
              // hover was turning white.
              danger
                ? 'hover:bg-(--n-window-danger) hover:text-white active:bg-(--n-window-danger)'
                : dots
                  ? ''
                  : circles
                    ? 'hover:bg-(--n-window-press) active:bg-(--n-window-press)'
                    : 'hover:bg-(--n-window-hover) active:bg-(--n-window-press)'
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
              {controlGlyph(control, maximized, chrome, metrics.glyph)}
            </span>
          </button>
        );
      })}
    </div>
  );
}

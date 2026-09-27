'use client';

/**
 * The strip under a plot, and the window on it.
 *
 * Its own module rather than a piece of `chart-frame.tsx`, and that is the
 * whole reason it is here: the frame is imported by every cartesian chart, so
 * anything inside it is a cost a page pays whether it draws the thing or not.
 * `React.lazy` puts this behind a chunk of its own — the same arrangement
 * `Image` makes for the dialog its `preview` opens — so a chart with no window
 * downloads none of it, and one with a window fetches it while the plot is
 * already narrowed and drawn.
 *
 * It is handed its `width` rather than measuring itself, and that is worth two
 * things: one `ResizeObserver` registration instead of two, and no import back
 * into the frame — which would be a cycle with the `import()` that reaches
 * this file.
 */

import * as React from 'react';
import { formatCategory, linePath } from './chart.js';
import { beginPointerDrag } from './drag.js';
import { cx, hitAreaClasses } from './styles.js';
import type { NebaChartCategory } from '../types.js';

export interface BrushProps {
  /** The whole of the first drawn series, for the shape under the window. */
  outline: readonly (number | null)[];
  /** How many categories there are altogether. */
  count: number;
  range: readonly [number, number];
  onRange: (range: [number, number]) => void;
  color: string;
  height: number;
  words: { start: string; end: string };
  /** The chart's own name, which the strip is a group under. */
  label: string;
  /** What the two handles say they are on, read out with their positions. */
  categories: readonly NebaChartCategory[];
  locale?: string;
  /** The chart's own measured width — the strip spans the same box. */
  width: number;
}

/** Which end of the window a gesture has hold of, or the whole of it. */
type Grip = 'start' | 'end' | 'window';

/**
 * The strip under the plot, and the window on it.
 *
 * A chart of two thousand points has no points on it — every column is a
 * fraction of a pixel and the shape is a smear — so the plot draws a window of
 * them and this draws all of them, small, with the window marked on it. That
 * pairing is the whole idea: a window with no overview beside it is a reader
 * who cannot tell where in the year they are.
 *
 * It is HTML rather than part of the SVG, and that is what makes the two
 * handles real `role="slider"` buttons: focusable, arrow-keyed, and announcing
 * the category they sit on. A pair of `<rect>`s inside the picture would be
 * reachable by pointer alone, which on the one control that decides what the
 * chart shows is not a control at all.
 */
export function ChartBrush({
  outline,
  count,
  range,
  onRange,
  color,
  height,
  words,
  label,
  categories,
  locale,
  width
}: BrushProps) {
  const stripRef = React.useRef<HTMLDivElement>(null);
  const release = React.useRef<(() => void) | null>(null);

  React.useEffect(() => () => release.current?.(), []);

  const last = Math.max(0, count - 1);
  const [from, to] = range;
  /* The window as last reported, and not as last rendered: a drag's moves are
     read by the closure it started in, and two of them can land before the
     window they asked for is drawn. */
  const reported = React.useRef<readonly [number, number]>([from, to]);

  React.useEffect(() => {
    reported.current = [from, to];
  });
  /* As fractions of the strip, which is what both the window's box and the
     drag arithmetic are in. A one-category series has no width to divide by. */
  const at = (index: number) => (last === 0 ? 0 : index / last);

  /** The shape of the whole series, drawn to fit the strip. */
  const path = React.useMemo(() => {
    const numbers = outline.filter((value): value is number => value !== null);

    if (width <= 0 || numbers.length === 0) {
      return '';
    }

    const low = Math.min(...numbers);
    const high = Math.max(...numbers);
    const span = high - low || 1;
    const inset = 2;
    const usable = Math.max(1, height - inset * 2);

    return linePath(
      outline.map((value, index) =>
        value === null
          ? null
          : {
              x: at(index) * width,
              y: inset + (1 - (value - low) / span) * usable
            }
      ),
      'linear'
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [outline, width, height, last]);

  /** The category a place along the strip falls on. */
  const indexAt = (clientX: number) => {
    const strip = stripRef.current;

    if (!strip) {
      return 0;
    }

    const box = strip.getBoundingClientRect();
    const along = box.width === 0 ? 0 : (clientX - box.left) / box.width;

    return Math.min(last, Math.max(0, Math.round(along * last)));
  };

  /**
   * Moves whichever part of the window the gesture has hold of.
   *
   * The two ends are kept at least one category apart and never cross: a
   * window of nothing is a plot of nothing, and a reader who dragged one
   * handle past the other would have to work out which end they now hold.
   */
  const move = (grip: Grip, index: number, offset: number) => {
    let next: readonly [number, number];

    if (grip === 'start') {
      next = [Math.min(index, to - 1), to];
    } else if (grip === 'end') {
      next = [from, Math.max(index, from + 1)];
    } else {
      const span = to - from;
      const start = Math.min(Math.max(0, index - offset), last - span);

      next = [start, start + span];
    }

    /* Held inside the series, which a window one category wide at either end
       would otherwise leave by one. And a gesture that moved nothing — a key
       at the end of its travel, a drag inside one category — is not a change
       to report. */
    const start = Math.min(last, Math.max(0, next[0]));
    const end = Math.min(last, Math.max(start, next[1]));
    const [was, wasEnd] = reported.current;

    if (start === was && end === wasEnd) {
      return;
    }

    reported.current = [start, end];
    onRange([start, end]);
  };

  function grab(grip: Grip, event: React.PointerEvent<HTMLElement>) {
    const index = indexAt(event.clientX);
    // Where inside the window the hand took hold, so panning does not jump the
    // window's start to the pointer on the first frame.
    const offset = grip === 'window' ? index - from : 0;

    event.preventDefault();
    release.current?.();
    release.current = beginPointerDrag({
      target: event.currentTarget,
      pointerId: event.pointerId,
      onMove: (moved) => move(grip, indexAt(moved.clientX), offset),
      onEnd: () => {
        release.current = null;
      }
    });
  }

  function step(grip: Grip, event: React.KeyboardEvent) {
    // A page is a tenth of the series: an arrow key at a time, a window on a
    // year of days is a few hundred presses from one end to the other.
    const page = Math.max(1, Math.round(count / 10));
    const by =
      event.key === 'ArrowLeft' || event.key === 'ArrowDown'
        ? -1
        : event.key === 'ArrowRight' || event.key === 'ArrowUp'
          ? 1
          : event.key === 'PageDown'
            ? -page
            : event.key === 'PageUp'
              ? page
              : 0;

    if (by !== 0) {
      move(grip, Math.min(last, Math.max(0, (grip === 'end' ? to : from) + by)), 0);
    } else if (event.key === 'Home') {
      move(grip, 0, 0);
    } else if (event.key === 'End') {
      move(grip, last, 0);
    } else {
      return;
    }

    event.preventDefault();
  }

  const handle = (grip: 'start' | 'end') => {
    const index = grip === 'start' ? from : to;

    return (
      <button
        type="button"
        role="slider"
        aria-label={grip === 'start' ? words.start : words.end}
        aria-valuemin={0}
        aria-valuemax={last}
        aria-valuenow={index}
        aria-valuetext={formatCategory(categories[index] ?? index, locale)}
        onPointerDown={(event) => grab(grip, event)}
        onKeyDown={(event) => step(grip, event)}
        className={cx(
          'absolute inset-y-0 w-2 -translate-x-1/2 cursor-ew-resize rounded-full',
          // Drawn 8 pixels wide, pressed across a finger's width.
          hitAreaClasses,
          'bg-(--n-accent) [touch-action:none]',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1'
        )}
        style={{ left: `${at(index) * 100}%` }}
      />
    );
  };

  return (
    <div
      ref={stripRef}
      // Named after the chart, so two brushed charts on a page are not four
      // sliders called Start and End.
      role="group"
      aria-label={label}
      className="absolute inset-x-0 bottom-0 select-none"
      style={{ height }}
    >
      <svg
        width="100%"
        height={height}
        viewBox={`0 0 ${Math.max(1, width)} ${height}`}
        preserveAspectRatio="none"
        aria-hidden="true"
        className="absolute inset-0 block"
      >
        <rect
          x={0}
          y={0}
          width={Math.max(1, width)}
          height={height}
          rx={3}
          fill="var(--neba-chart-grid)"
        />
        {path ? <path d={path} fill="none" stroke={color} strokeWidth={1} opacity={0.6} /> : null}
      </svg>

      {/* The window itself. Everything outside it is left as the flat track,
          which is what says the rest of the series is still there. */}
      <div
        onPointerDown={(event) => grab('window', event)}
        className={cx(
          'absolute inset-y-0 cursor-grab rounded-[3px] [touch-action:none]',
          'bg-(--n-soft) [box-shadow:inset_0_0_0_1px_var(--n-accent)]',
          'data-[dragging]:cursor-grabbing'
        )}
        style={{ left: `${at(from) * 100}%`, width: `${(at(to) - at(from)) * 100}%` }}
      />

      {handle('start')}
      {handle('end')}
    </div>
  );
}

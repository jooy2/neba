'use client';

/**
 * What a `NebaRunStatus` looks like, and the clock behind an elapsed time.
 *
 * Three components answer the same two questions — ToolCall and AgentSteps ask
 * which mark and which colour family a status is drawn in, ToolCall and
 * Reasoning ask how long something has been going on — and neither answer is
 * one a component should hold on its own. A transcript draws a tool call above
 * a plan above a thinking panel, all three at once, and a library where the
 * tick on one is a different green from the tick on the next is a library whose
 * reader cannot tell whether the difference means anything.
 *
 * The clock is here for a second reason. A component that counts while
 * something runs re-renders on every tick, so how often it ticks is a decision
 * about a whole transcript rather than about one row: a page holding twenty
 * running tool calls at ten frames a second is two hundred renders a second for
 * a number nobody is reading that closely. It ticks once a second, and says
 * nothing at all until the first one has passed.
 */

import * as React from 'react';
import { CircleIcon, DangerIcon, SpinnerIcon, SuccessIcon } from './icons.js';
import { numberFormatter } from './format.js';
import type { NebaColor, NebaRunStatus } from '../types.js';

/**
 * The mark for a status.
 *
 * A function rather than a `Record` of elements, for the reason `severityIcon`
 * is one: a bundler drops an unused function and cannot drop a key out of an
 * object literal, and nothing should build four React elements at import time
 * for a page that may draw none of them.
 */
export function runIcon(status: NebaRunStatus): React.ReactElement {
  switch (status) {
    case 'running':
      return <SpinnerIcon />;
    case 'success':
      return <SuccessIcon />;
    case 'error':
      return <DangerIcon />;
    default:
      return <CircleIcon />;
  }
}

/**
 * The colour family a status is drawn in, given the component's own.
 *
 * Two of the four are not the caller's to choose: something that failed is
 * `danger` and something that finished is `success`, and a `color` prop that
 * repainted either would be a transcript where a red row and a green row mean
 * whatever the page's accent happens to be. The other two are — `running` takes
 * the component's family, and `pending` is deliberately `secondary`, which is
 * the one family that says "nothing has happened here yet" without saying
 * anything about how it went.
 */
export function runColor(status: NebaRunStatus, color: NebaColor): NebaColor {
  switch (status) {
    case 'success':
      return 'success';
    case 'error':
      return 'danger';
    case 'pending':
      return 'secondary';
    default:
      return color;
  }
}

/**
 * A length of time, in the reader's own language.
 *
 * `Intl` knows the words, so none of this is in `i18n.ts`: what it decides is
 * only the unit and how many digits are worth printing. Under a second the
 * number is milliseconds, because "0.3s" is a measurement written in the wrong
 * unit; over it, seconds, to one decimal place for the first ten and then to
 * none — a step that ran for four minutes is not more informative at 247.3.
 */
export function formatDuration(ms: number, locale?: string): string {
  if (!Number.isFinite(ms) || ms < 0) {
    return '';
  }

  if (ms < 1000) {
    return numberFormatter(locale, {
      style: 'unit',
      unit: 'millisecond',
      unitDisplay: 'narrow',
      maximumFractionDigits: 0
    }).format(Math.round(ms));
  }

  const seconds = ms / 1000;

  return numberFormatter(locale, {
    style: 'unit',
    unit: 'second',
    unitDisplay: 'narrow',
    maximumFractionDigits: seconds < 10 ? 1 : 0
  }).format(seconds);
}

/**
 * How long a run has been going, in milliseconds, or `null`.
 *
 * A `duration` the caller knows wins outright; without one the clock counts,
 * and what it counts is *whole seconds*, because a component that re-renders
 * ten times a second is a decision about a whole transcript rather than about
 * one row.
 *
 * `null` is "there is nothing to say", and the first second of every run
 * returns it: a counter that starts at "0s" claims a precision the tick rate
 * does not have, and a tool that answers in 300ms would have spent its whole
 * life saying zero.
 *
 * The last figure is **kept** once the run ends, which is what turns a live
 * count into a total — a thinking panel that says "Thought for 4s" is reading
 * the same number it was ticking a moment ago. It is cleared when a new run
 * starts, so a retried call counts its own attempt rather than carrying the
 * first one's number forward.
 */
export function useElapsed(running: boolean, duration: number | undefined): number | null {
  const measure = running && duration === undefined;
  const [elapsed, setElapsed] = React.useState<number | null>(null);
  const [measuring, setMeasuring] = React.useState(measure);

  /*
   * React's own "adjusting state when a prop changes", done in the render
   * rather than in an effect. An effect would clear the count one commit late,
   * which is a frame of the *previous* run's number on a row that has only
   * just started.
   */
  if (measuring !== measure) {
    setMeasuring(measure);

    if (measure) {
      setElapsed(null);
    }
  }

  React.useEffect(() => {
    if (!measure) {
      return undefined;
    }

    const started = Date.now();
    const id = setInterval(() => setElapsed(Date.now() - started), 1000);

    return () => clearInterval(id);
  }, [measure]);

  return duration ?? elapsed;
}

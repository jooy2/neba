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
 * a number nobody is reading that closely. It ticks once a second, on one timer
 * for the whole page, says nothing at all until the first second has passed,
 * and redraws only the number.
 */

import * as React from 'react';
import { useLayoutEffectOnClient } from './layout-effect.js';
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
 * A length of time, in the language of the sentence around it.
 *
 * `Intl` knows the words, so none of this is in `i18n.ts`: what it decides is
 * only the unit and how many digits are worth printing. Under a second the
 * number is milliseconds, because "0.3s" is a measurement written in the wrong
 * unit; over it, seconds, to one decimal place for the first ten and then to
 * none — a step that ran for four minutes is not more informative at 247.3.
 *
 * With no `locale` it is English, because that is what the library's own words
 * fall back to and a duration is printed inside them: left to the runtime, a
 * Korean browser wrote "Thought for 2.4초". It also means the server and the
 * browser can never disagree about it.
 */
export function formatDuration(ms: number, locale?: string): string {
  if (!Number.isFinite(ms) || ms < 0) {
    return '';
  }

  const tag = locale ?? 'en';

  if (ms < 1000) {
    return numberFormatter(tag, {
      style: 'unit',
      unit: 'millisecond',
      unitDisplay: 'narrow',
      maximumFractionDigits: 0
    }).format(Math.round(ms));
  }

  const seconds = ms / 1000;

  return numberFormatter(tag, {
    style: 'unit',
    unit: 'second',
    unitDisplay: 'narrow',
    maximumFractionDigits: seconds < 10 ? 1 : 0
  }).format(seconds);
}

/**
 * One clock for every count on the page.
 *
 * Each running count had an interval of its own, so twenty running calls were
 * twenty timers, each firing at a moment of its own and each a render and a
 * commit of its own. A single timer calls them all from one callback, which
 * React batches into one render, so the whole transcript ticks in one commit.
 * A page with nothing running keeps no timer at all.
 */
const tickers = new Set<() => void>();
let tickTimer: ReturnType<typeof setInterval> | undefined;

function onSecond(tick: () => void): () => void {
  tickers.add(tick);
  tickTimer ??= setInterval(() => {
    for (const listener of [...tickers]) {
      listener();
    }
  }, 1000);

  return () => {
    tickers.delete(tick);

    if (tickers.size === 0) {
      clearInterval(tickTimer);
      tickTimer = undefined;
    }
  };
}

/** A run's clock, as the component around the run keeps it. */
export interface RunClock {
  /** When the run that is going now started, by `Date.now()`, or `null`. */
  since: number | null;
  /** How long it took: a `duration` the caller knows, or the run measured as it ended. */
  total: number | null;
}

/**
 * When a run started and how long it took, without counting in between.
 *
 * A `duration` the caller knows wins outright. Without one, the start is taken
 * when the run starts and the run is **measured once more** when it ends,
 * which is what turns a live count into a total: left at the last tick, a run
 * of 4.9 seconds would say 4, and one under a second would say nothing at all,
 * where a `duration` of the same length says "4.9s" or "900ms". It is cleared
 * when a new run starts, so a retried call counts its own attempt rather than
 * carrying the first one's number forward.
 *
 * This hook does not tick, so the component that holds it renders when a run
 * starts and when it ends and at no point in between. The count belongs to
 * `RunTime`, a component of its own, so a second going by redraws a number
 * rather than the row, the panel and everything in them; and a Reasoning, which
 * says "Thinking" until it is done, has nothing to redraw at all.
 */
export function useRunClock(running: boolean, duration: number | undefined): RunClock {
  const measure = running && duration === undefined;
  const [since, setSince] = React.useState<number | null>(null);
  const [total, setTotal] = React.useState<number | null>(null);
  const [measuring, setMeasuring] = React.useState(measure);

  /*
   * React's own "adjusting state when a prop changes", done in the render
   * rather than in an effect. An effect would clear the total one commit late,
   * which is a frame of the *previous* run's number on a row that has only
   * just started.
   */
  if (measuring !== measure) {
    setMeasuring(measure);

    if (measure) {
      setSince(null);
      setTotal(null);
    }
  }

  /*
   * The total, taken when the clock stops and handed over by the effect below.
   * A ref rather than a state write in the cleanup, because the cleanup also
   * runs on an unmount — and on the one Strict Mode stages right after the
   * first mount, which would put a total of nothing on a run that has only
   * just started.
   */
  const ended = React.useRef<number | null>(null);

  // Layout effects, so the total is drawn in the frame the run ends in rather
  // than one frame after it. The start is taken here rather than in the render,
  // which may run more than once for one commit, and only in a browser: a
  // server has no clock the reader's would agree with.
  useLayoutEffectOnClient(() => {
    if (!measure) {
      return undefined;
    }

    const started = Date.now();

    setSince(started);

    return () => {
      ended.current = Date.now() - started;
    };
  }, [measure]);

  // Runs after the cleanup above, on the commit where the run ended.
  useLayoutEffectOnClient(() => {
    if (measure || ended.current === null) {
      return;
    }

    setTotal(ended.current);
    ended.current = null;
  }, [measure]);

  return { since: measure ? since : null, total: duration ?? total };
}

/**
 * How long a run has been going, counted in whole seconds, or `null`.
 *
 * `null` is "there is nothing to say", and the first second of every run
 * returns it: a counter that starts at "0s" claims a precision the tick rate
 * does not have, and a tool that answers in 300ms would have spent its whole
 * life saying zero. Whole seconds, because the shared clock ticks at a moment
 * of its own rather than of this run's, and a count that read "2.3s" and then
 * "3.3s" would claim that precision too.
 */
function useCount(since: number | null): number | null {
  const [counted, setCounted] = React.useState<number | null>(null);
  const [from, setFrom] = React.useState(since);

  if (from !== since) {
    setFrom(since);
    setCounted(null);
  }

  React.useEffect(() => {
    if (since === null) {
      return undefined;
    }

    return onSecond(() => {
      const spent = Date.now() - since;

      if (spent >= 1000) {
        setCounted(Math.floor(spent / 1000) * 1000);
      }
    });
  }, [since]);

  return since === null ? null : counted;
}

/**
 * The time a run has taken, as text: the total once there is one, and the
 * running count until then. Nothing at all while there is neither.
 *
 * A component rather than a hook, so that the one thing that changes every
 * second is the only thing that renders every second.
 */
export function RunTime({
  since,
  total,
  locale,
  className
}: RunClock & { locale?: string; className?: string }): React.ReactElement | null {
  const counted = useCount(total === null ? since : null);
  const millis = total ?? counted;

  return millis === null ? null : (
    <span className={className}>{formatDuration(millis, locale)}</span>
  );
}

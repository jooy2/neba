'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { childKey } from '../../internal/children.js';
import { formatDuration, runColor, runIcon, useElapsed } from '../../internal/run.js';
import { runMessages, useMessages, type RunMessages } from '../../internal/i18n.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  srOnlyClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaDensity,
  NebaRunStatus,
  NebaSize,
  NebaStyleProps
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

interface StepsContextValue {
  size: NebaSize;
  density: NebaDensity;
  color: NebaColor;
  locale: string | undefined;
  labels: RunMessages;
}

interface StepContextValue {
  /** Whether the line after this step would run into nothing. */
  last: boolean;
}

const StepsContext = React.createContext<StepsContextValue | null>(null);
const StepContext = React.createContext<StepContextValue>({ last: false });

export interface AgentStepsProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'ol'>, 'color'> {
  /**
   * That there is more to come, drawn as one more marker under the last step.
   *
   * `true` draws the marker with no label at all — the status is read out
   * either way, and a visible "Running" beside it would say nothing a turning
   * ring has not already said. A node labels it: "Deciding what to do next" is
   * worth the line when the plan is being written as it goes.
   *
   * It is a prop rather than one more `AgentStep` because the whole point is
   * that the step has no name yet: a chain that grows while it runs spends most
   * of its life not knowing what comes next.
   * @default false
   */
  running?: React.ReactNode | boolean;
  /** Which language a step's status is read out in, as a BCP 47 tag. */
  locale?: string;
  /** Those four words, written out. Overrides the `locale`'s. */
  labels?: Partial<RunMessages>;
  /** Renders something other than an `<ol>` — Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The steps. */
  children?: React.ReactNode;
}

export interface AgentStepProps extends Omit<
  React.ComponentPropsWithoutRef<'li'>,
  'color' | 'title'
> {
  /** What the step is. */
  title?: React.ReactNode;
  /**
   * How far it has got.
   * @default 'success'
   */
  status?: NebaRunStatus;
  /**
   * How long it took, in milliseconds. Left out, a `running` step counts its
   * own from the second it starts, exactly as a
   * [ToolCall](./tool-call) does.
   */
  duration?: number;
  /** Anything else on the title line — a file name, a count, a model. */
  meta?: React.ReactNode;
  /** Replaces the status mark. The status is still read out. */
  icon?: React.ReactNode | false;
  /** Overrides the chain's family for this one step. */
  color?: NebaColor;
  /**
   * What the step did, under the title: a search query, a file that was read, a
   * [ToolCall](./tool-call) of its own.
   */
  children?: React.ReactNode;
}

/** The marker column. On the tick ladder, because a marker is not a control. */
const markSizeValues: Record<NebaSize, string> = {
  xs: '0.875rem',
  sm: '1rem',
  md: '1.125rem',
  lg: '1.25rem',
  xl: '1.5rem'
};

/** Between the marker column and the step beside it. */
const markGapClasses: Record<NebaSize, string> = {
  xs: 'gap-2',
  sm: 'gap-2.5',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * How far apart two steps sit, and the one thing `density` touches here.
 *
 * Tighter than a [Timeline](../display/timeline)'s, deliberately: a timeline is
 * a record a reader is browsing, and a chain of agent steps is a list they are
 * watching grow. Air between the rows of something that is still moving reads
 * as the thing having stopped.
 */
const stepGapClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'pb-3', sm: 'pb-3.5', md: 'pb-4', lg: 'pb-5', xl: 'pb-6' },
  compact: { xs: 'pb-1.5', sm: 'pb-2', md: 'pb-2.5', lg: 'pb-3', xl: 'pb-3.5' }
};

/**
 * The title's ink per status.
 *
 * Each is a different axis rather than three opacities: what has finished is
 * ordinary reading text, what is happening now carries the family, and what has
 * not started is the muted ink every other "not yet" in the library uses.
 */
const titleStatusClasses: Record<NebaRunStatus, string> = {
  pending: 'text-(--neba-muted-fg)',
  running: 'text-(--n-accent)',
  success: 'text-(--neba-fg)',
  error: 'text-(--n-accent)'
};

/**
 * One step of a chain.
 *
 * Its place in the list is not a prop and cannot be: the only thing a step has
 * to know about its neighbours is whether the line under it would run into
 * nothing, and a caller appending steps as they happen should not have to keep
 * that right.
 */
export const AgentStep = React.forwardRef<HTMLLIElement, AgentStepProps>(function AgentStep(
  { title, status = 'success', duration, meta, icon, color, className, style, children, ...props },
  ref
) {
  const steps = React.useContext(StepsContext);
  const { last } = React.useContext(StepContext);

  // A bare step outside a chain still renders: it is one step with nothing
  // before or after it. The defaults are the chain's own.
  const size = steps?.size ?? 'md';
  const density = steps?.density ?? 'default';
  const fallback = useMessages(runMessages);
  const labels = steps?.labels ?? fallback;
  const family = runColor(status, color ?? steps?.color ?? 'primary');

  const millis = useElapsed(status === 'running', duration);
  const mark = icon === undefined ? runIcon(status) : icon;

  return (
    <li
      ref={ref}
      aria-current={status === 'running' ? 'step' : undefined}
      data-status={status}
      className={cx(
        'relative flex',
        markGapClasses[size],
        last ? '' : stepGapClasses[density][size],
        className
      )}
      style={
        {
          '--n-mark': markSizeValues[size],
          ...surfaceSlots(family, 0),
          ...style
        } as React.CSSProperties
      }
      {...props}
    >
      {/*
          The rail, drawn as one border edge on an absolutely positioned box
          rather than as a filled `<div>`, so it lands on the device pixel grid
          the way every other edge in the library does. It starts below the
          marker and runs to the edge of the step, which is where the next
          marker begins.
        */}
      {last ? null : (
        <span
          aria-hidden="true"
          className={cx(
            'pointer-events-none absolute start-[calc(var(--n-mark)/2_-_1px)] top-(--n-mark)',
            'bottom-0 border-s-2 [border-color:var(--neba-border)]'
          )}
        />
      )}

      <span
        aria-hidden="true"
        className={cx(
          // Opaque, so the rail passes behind the marker rather than through
          // it — the one thing a 2px line through a 1.5px glyph ruins.
          'relative z-10 flex size-(--n-mark) shrink-0 items-center justify-center',
          'rounded-full bg-(--neba-surface) text-(--n-accent)',
          '[&_svg]:size-full',
          transitionClasses
        )}
      >
        {mark}
      </span>

      <div className="flex min-w-0 flex-1 flex-col gap-0.5">
        <div className="flex min-w-0 items-baseline gap-2">
          <span className={srOnlyClasses}>{labels[status]}</span>
          {hasContent(title) ? (
            <span
              className={cx(
                'min-w-0 font-medium',
                sheetTitleClasses[size],
                titleStatusClasses[status],
                transitionClasses
              )}
            >
              {title}
            </span>
          ) : null}

          {hasContent(meta) ? (
            <span className={cx('min-w-0 truncate text-(--neba-muted-fg)', metaTextClasses[size])}>
              {meta}
            </span>
          ) : null}

          {millis === null ? null : (
            <span
              className={cx(
                'ms-auto shrink-0 tabular-nums text-(--neba-muted-fg)',
                metaTextClasses[size]
              )}
            >
              {formatDuration(millis, steps?.locale)}
            </span>
          )}
        </div>

        {hasContent(children) ? (
          <div className={cx('min-w-0 text-(--neba-muted-fg)', sheetBodyClasses[size])}>
            {children}
          </div>
        ) : null}
      </div>
    </li>
  );
});

/**
 * A chain of steps that grows as it runs.
 *
 * A [Timeline](../display/timeline) and a
 * [HowToSteps](../surfaces/how-to-steps) draw a list that is known in advance:
 * five stages of a checkout, four things to do in order. This one does not know
 * how many items it has. Steps are appended as they happen, the one at the
 * bottom is usually still running, and each can hold whatever it did —
 * including a [ToolCall](./tool-call) of its own.
 *
 * It is an `<ol>` for the reason it exists at all: the order *is* the content.
 * There is no Base UI primitive under it and there should not be — a chain of
 * steps has no selection, no roving focus and no keyboard contract, and
 * reaching for a composite primitive would hand a record of what happened the
 * semantics of a widget.
 */
export const AgentSteps = React.forwardRef<HTMLOListElement, AgentStepsProps>(
  function AgentSteps(rawProps, ref) {
    const {
      size = 'md',
      color = 'primary',
      density = 'default',
      running = false,
      locale,
      labels: labelOverrides,
      render,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'locale']);

    const messages = useMessages(runMessages, locale);
    const labels = React.useMemo(
      () => ({ ...messages, ...labelOverrides }),
      // The four words, rather than the object a caller wrote inline.
      // eslint-disable-next-line react-hooks/exhaustive-deps
      [
        messages,
        labelOverrides?.pending,
        labelOverrides?.running,
        labelOverrides?.success,
        labelOverrides?.error
      ]
    );

    // `toArray` is what drops the `null`s and `false`s a conditional step leaves
    // behind, so the rail stops at the last step that is actually on the page.
    const items = React.Children.toArray(children);
    const tail = running !== false && running !== null && running !== undefined;
    const count = items.length + (tail ? 1 : 0);

    const context = React.useMemo<StepsContextValue>(
      () => ({ size, density, color, locale, labels }),
      [size, density, color, locale, labels]
    );

    const element = useRender({
      render: render ?? <ol />,
      ref,
      props: {
        // Tailwind's reset takes the markers off every `<ol>`, and Safari takes
        // the list semantics off with them. Saying `role="list"` out loud is
        // the one-line fix, and it costs nothing when the reset is not there.
        role: 'list',
        className: cx('flex flex-col', className),
        style: { ...surfaceSlots(color, 0), ...style },
        children: (
          <>
            {items.map((item, index) => (
              <StepContext.Provider
                key={childKey(item, index)}
                value={{ last: index === count - 1 }}
              >
                {item}
              </StepContext.Provider>
            ))}
            {tail ? (
              <StepContext.Provider value={{ last: true }}>
                {/* `true` gets no title on purpose: the status is already read out, and
                    a visible "Running" beside it would be the same word twice for
                    a screen reader and a label saying nothing for everyone else. */}
                <AgentStep status="running" title={running === true ? undefined : running} />
              </StepContext.Provider>
            ) : null}
          </>
        ),
        ...props
      }
    });

    return <StepsContext.Provider value={context}>{element}</StepsContext.Provider>;
  }
);

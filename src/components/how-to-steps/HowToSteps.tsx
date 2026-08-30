'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { boxPaddingClasses } from '../box/Box.js';
import { CheckIcon, ChevronIcon, RestartIcon, SuccessIcon } from '../../internal/icons.js';
import { fill, stepsMessages, useMessages } from '../../internal/i18n.js';
import { transitionProps } from '../../internal/animate.js';
import {
  cx,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  srOnlyClasses,
  surfaceClasses,
  surfaceSlots,
  toLength,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaDensity,
  NebaElevation,
  NebaOrientation,
  NebaSize,
  NebaTransition,
  NebaVariant
} from '../../types.js';

/** One step of the guide. */
export interface HowToStep {
  /** The heading, shown both in the list and over the step's own body. */
  title: React.ReactNode;
  /**
   * A glyph before the title, over the step's own body.
   *
   * Only there, and not in the list: a row there already carries a numbered
   * disc, and a glyph beside it is a second mark making the same claim about
   * the same row. What an icon is good for is telling a reader *what kind* of
   * step this is — a terminal, a file, a warning — which is a thing to say
   * once, where the step is stated at full size.
   */
  icon?: React.ReactNode;
  /** What the reader has to do. Anything — prose, a [CodeBlock], a screenshot. */
  content?: React.ReactNode;
  /** A picture above the content, for a step that is easier shown than said. */
  image?: string;
  /** What that picture says for a reader who cannot see it. Defaults to `title`. */
  imageAlt?: string;
}

export interface HowToStepsProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'title' | 'content'
> {
  /**
   * The steps, in the order they are to be done.
   *
   * An array rather than children, and this is the one place the component
   * genuinely could not be built the other way: the list beside the body and
   * the body itself are two renderings of the same data, and the panel is sized
   * against *every* step rather than the one showing. A component that had to
   * find its steps among its children could do neither.
   */
  steps: HowToStep[];
  /** The guide's own heading, over both columns. */
  title?: React.ReactNode;
  /**
   * Which heading level `title` is written at, and the step's title one below
   * it.
   *
   * A heading level is a claim about the *page*, not about the component: a
   * guide under an `<h1>` is an `<h2>` and the same guide inside a section is an
   * `<h4>`, and a component that decides for itself breaks the outline of every
   * page it does not happen to suit.
   * @default 3
   */
  headingLevel?: 2 | 3 | 4 | 5;
  /** Which step is showing. Pass it to drive the guide yourself. */
  step?: number;
  /** Where an uncontrolled guide starts. @default 0 */
  defaultStep?: number;
  /** Fires with the index whenever the step changes, however it changed. */
  onStepChange?: (step: number) => void;
  /** Whether the guide is finished. Pass it to drive that yourself too. */
  completed?: boolean;
  /** Whether an uncontrolled guide starts finished. @default false */
  defaultCompleted?: boolean;
  /** Fires when the guide is finished, and again when it is started over. */
  onCompletedChange?: (completed: boolean) => void;
  /**
   * Which way the list of steps runs.
   *
   * `vertical` is the default: the numbers run down one side with the body
   * beside them, which takes any number of steps and any amount to say about
   * each. Below `sm` it stacks, because a rail and a paragraph side by side on
   * a phone is two columns too narrow for either. `horizontal` runs the numbers
   * across the top, and is only honest while every title is short.
   * @default 'vertical'
   */
  orientation?: NebaOrientation;
  /**
   * How tall the guide may get before it scrolls. A number is pixels.
   *
   * Both the list and the body scroll inside it rather than the sheet growing.
   * A guide with twenty steps is what this is for, and twenty rows that pushed
   * the buttons off the bottom of the card would be a guide with no way
   * forward.
   */
  maxHeight?: number | string;
  /**
   * How wide the list is while it is a column. A number is pixels.
   * @default '15rem'
   */
  railWidth?: number | string;
  /**
   * The row of buttons under the body. Off, the list is the only way to move,
   * which is what a guide inside a page that has navigation of its own wants.
   * @default true
   */
  navigation?: boolean;
  /**
   * Draws a hairline between the list and the body — down the inner edge while
   * they are two columns, along the bottom of the list once they have stacked.
   *
   * On by default. The two are different kinds of thing — one is a map, the
   * other is the place the map points at — and space alone leaves that to be
   * inferred from a gap that a narrow screen is about to take away.
   * @default true
   */
  divider?: boolean;
  /**
   * How a step arrives when the reader moves to it, from the same vocabulary
   * `transition` uses everywhere: an effect name, or the object form for the
   * duration, the easing and the rest. `'none'` turns it off.
   *
   * It runs on the panel rather than on anything that is pressed, which is what
   * keeps it inside the library's rule against moving a control: the buttons
   * and the list rows hold still, and what animates is the content they
   * changed.
   *
   * A reduced-motion preference switches it off entirely, as it does every
   * other effect in the library.
   * @default 'fade'
   */
  transition?: NebaTransition | 'none';
  /**
   * Whether there is a finished state at all.
   *
   * On, the last step's button says "Done" and pressing it replaces the body
   * with a panel that says so and offers to start again. Off, the last step is
   * simply the last step.
   * @default true
   */
  completion?: boolean;
  /** What the finished panel says, in place of the `locale`'s own sentence. */
  completedContent?: React.ReactNode;
  /**
   * Weight of the sheet, said the way a *container* says it: the guide is never
   * dyed, because what is in it arrives with colours of its own.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** @default 'md' */
  size?: NebaSize;
  /** The family the numbers, the connector and the buttons wear. @default 'primary' */
  color?: NebaColor;
  /** @default 'default' */
  density?: NebaDensity;
  /** Drop shadow depth. `0` (the default) is flat. @default 0 */
  elevation?: NebaElevation;
  /**
   * Which language the guide's own words are in — the four buttons and the
   * sentence at the end. A BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`;
   * unsupported tags fall back to English.
   */
  locale?: string;
  /** The four button labels, written out over the `locale`. */
  previousLabel?: string;
  nextLabel?: string;
  doneLabel?: string;
  restartLabel?: string;
}

/**
 * The numbered disc: its diameter as a raw length, and the type on it.
 *
 * The diameter is a length rather than a `size-*` class because the connector
 * between two numbers is measured from it — the line starts where one disc ends
 * and stops where the next begins — and a disc that grew by a step while the
 * line did not would leave a gap under every number. One value, read by both.
 */
const markSizes: Record<NebaSize, { box: string; text: string }> = {
  xs: { box: '1.25rem', text: 'text-[0.625rem]' },
  sm: { box: '1.5rem', text: 'text-[0.6875rem]' },
  md: { box: '1.75rem', text: 'text-[0.75rem]' },
  lg: { box: '2rem', text: 'text-[0.8125rem]' },
  xl: { box: '2.25rem', text: 'text-[0.875rem]' }
};

/** The gap between one row of the list and the next. */
const railGapClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'gap-0.5', sm: 'gap-1', md: 'gap-1', lg: 'gap-1.5', xl: 'gap-2' },
  compact: { xs: 'gap-0', sm: 'gap-0', md: 'gap-0.5', lg: 'gap-0.5', xl: 'gap-1' }
};

/**
 * The three weights, said the way a *container* says them: the sheet is never
 * dyed, exactly as on Box and Card. What carries the family is the numbers.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/** The label a screen reader gets, for a row whose text is a number and a title. */
function plainTitle(title: React.ReactNode): string {
  return typeof title === 'string' ? title : '';
}

/**
 * A guide the reader walks through: numbered steps down one side, one step's
 * instructions at a time beside them, and a way forward under those.
 *
 * It is [Timeline]'s interactive sibling, and the two are deliberately not one
 * component. A Timeline *reports* — this happened, then this did, and here is
 * where things have got to — and nothing in it is pressed. A HowToSteps *asks*:
 * the reader is meant to do the thing on the screen and then say they have,
 * which needs a current step, a way to change it, and an end.
 *
 * Two things about how it is built are load-bearing rather than incidental.
 *
 * **Every step's body is rendered into the same grid cell**, with the ones not
 * showing left in the document, `invisible` and `inert`. The panel is therefore
 * as tall as the tallest step at every moment, so moving between a one-line
 * step and a five-line one does not resize the card the guide sits in — which,
 * on a page the reader has already scrolled, moves everything under it. The
 * finished panel is in that cell too, for the same reason.
 *
 * **The list is a list of buttons and not a tablist.** A stepper looks like
 * tabs and is not one: the panels are ordered, the reader is expected to arrive
 * at them in that order, and `aria-current="step"` is the attribute that says
 * so. A tablist's roving focus would tell a screen reader that these are
 * interchangeable views of one thing.
 */
/**
 * A heading at the level the page says, rather than at the level the component
 * happens to prefer.
 *
 * `createElement` with a computed tag rather than a lookup table: the six of
 * them differ in nothing but their name, and a table would be six entries
 * saying so. Clamped, because `headingLevel + 1` on the deepest step would
 * otherwise ask for an `<h7>`.
 */
function StepHeading({
  level,
  ...props
}: React.ComponentPropsWithoutRef<'h3'> & { level: number }) {
  return React.createElement(`h${Math.min(6, Math.max(1, level))}`, props);
}

export const HowToSteps = React.forwardRef<HTMLDivElement, HowToStepsProps>(function HowToSteps(
  {
    steps,
    title,
    headingLevel = 3,
    step: stepProp,
    defaultStep = 0,
    onStepChange,
    completed: completedProp,
    defaultCompleted = false,
    onCompletedChange,
    orientation = 'vertical',
    maxHeight,
    railWidth = '15rem',
    navigation = true,
    divider = true,
    transition = 'fade',
    completion = true,
    completedContent,
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    locale,
    previousLabel,
    nextLabel,
    doneLabel,
    restartLabel,
    className,
    style,
    ...props
  },
  ref
) {
  const messages = useMessages(stepsMessages, locale);
  const headingId = React.useId();

  const [ownStep, setOwnStep] = React.useState(defaultStep);
  const [ownCompleted, setOwnCompleted] = React.useState(defaultCompleted);

  const controlledStep = stepProp !== undefined;
  const controlledCompleted = completedProp !== undefined;

  const total = steps.length;

  /**
   * Clamped on render rather than on change: `steps` can shrink under a
   * controlled index, and a guide pointing past the end of its own list would
   * draw an empty panel with no way back.
   */
  const active = Math.min(Math.max(controlledStep ? stepProp : ownStep, 0), Math.max(total - 1, 0));
  const completed = completion && (controlledCompleted ? completedProp : ownCompleted);
  const bounded = maxHeight !== undefined;
  const vertical = orientation === 'vertical';

  /**
   * Keeps the step being worked on inside the part of the list that is showing.
   *
   * `maxHeight` is what a guide with twenty steps needs, and a list that scrolls
   * is a list whose current row can be off screen: press Next four times and the
   * numbers stop agreeing with the panel beside them. The arithmetic is done
   * against the list's own scroll box rather than through `scrollIntoView`,
   * because that walks every scrollable ancestor and would move the page under
   * a reader who only pressed a button inside a card.
   */
  const railRef = React.useRef<HTMLOListElement | null>(null);
  const activeRef = React.useRef<HTMLLIElement | null>(null);

  React.useEffect(() => {
    const box = railRef.current;
    const row = activeRef.current;

    if (!box || !row) return;

    const outer = box.getBoundingClientRect();
    const inner = row.getBoundingClientRect();

    if (vertical) {
      if (inner.top < outer.top) box.scrollTop -= outer.top - inner.top;
      else if (inner.bottom > outer.bottom) box.scrollTop += inner.bottom - outer.bottom;
    } else if (inner.left < outer.left) {
      box.scrollLeft -= outer.left - inner.left;
    } else if (inner.right > outer.right) {
      box.scrollLeft += inner.right - outer.right;
    }
  }, [active, vertical]);

  if (total === 0) {
    return null;
  }

  const go = (next: number, done = false) => {
    if (!controlledCompleted) setOwnCompleted(done);
    if (completed !== done) onCompletedChange?.(done);

    if (done) return;

    if (!controlledStep) setOwnStep(next);
    if (next !== active) onStepChange?.(next);
  };

  const first = active === 0;
  const last = active === total - 1;

  /**
   * The entrance, and how it is re-run without remounting anything.
   *
   * The class is put on the panel that is *currently* active and on no other,
   * so a panel gains it at the moment it becomes the one showing — and adding
   * an animation class to an element that did not have one is what starts an
   * animation. No key, no reflow hack, and above all no remount: a step can
   * hold a form, and a guide that wiped what the reader typed every time they
   * looked back at step one would be worse than one that did not animate.
   */
  const motion = transition === 'none' ? null : transitionProps(transition);

  const mark = (index: number) => {
    const done = completed || index < active;
    const current = !completed && index === active;

    return (
      <span
        aria-hidden="true"
        className={cx(
          'z-1 flex shrink-0 items-center justify-center rounded-full border font-medium',
          'size-(--n-step-mark) [&_svg]:size-[1.15em]',
          markSizes[size].text,
          transitionClasses,
          done
            ? 'bg-(--n-fill) text-(--n-on-solid) [border-color:transparent]'
            : current
              ? 'bg-(--neba-surface) text-(--n-accent) [border-color:var(--n-accent)]'
              : 'bg-(--neba-surface) text-(--neba-muted-fg) [border-color:var(--n-line)]'
        )}
      >
        {done ? <CheckIcon /> : index + 1}
      </span>
    );
  };

  const rail = (
    <ol
      ref={railRef}
      aria-label={messages.steps}
      className={cx(
        'm-0 flex list-none p-0',
        vertical ? 'flex-col' : 'flex-row',
        railGapClasses[density][size],
        bounded && vertical ? 'min-h-0 overflow-y-auto overscroll-contain' : '',
        vertical ? '' : 'overflow-x-auto overscroll-contain'
      )}
    >
      {steps.map((item, index) => {
        const done = completed || index < active;
        const current = !completed && index === active;

        return (
          <li
            key={index}
            ref={current ? activeRef : undefined}
            className={cx('relative', vertical ? '' : 'min-w-0 flex-1')}
          >
            {index < total - 1 ? (
              /*
                The line between two numbers, drawn from the edge of one disc to
                the edge of the next rather than behind them: a connector that
                ran under a translucent disc would show through it. Both offsets
                are arithmetic on `--n-step-mark`, which is why the disc's
                diameter is a length rather than a class.
              */
              <span
                aria-hidden="true"
                className={cx(
                  'absolute',
                  transitionClasses,
                  done ? 'bg-(--n-fill)' : 'bg-(--n-line)',
                  vertical
                    ? [
                        'w-px',
                        '[inset-inline-start:calc(0.25rem+var(--n-step-mark)/2)]',
                        '[top:calc(0.25rem+var(--n-step-mark))]',
                        '[height:calc(100%-var(--n-step-mark))]'
                      ].join(' ')
                    : [
                        'h-px',
                        '[inset-inline-start:calc(50%+var(--n-step-mark)/2)]',
                        '[top:calc(0.25rem+var(--n-step-mark)/2)]',
                        '[width:calc(100%-var(--n-step-mark))]'
                      ].join(' ')
                )}
              />
            ) : null}

            <button
              type="button"
              onClick={() => go(index)}
              aria-current={current ? 'step' : undefined}
              className={cx(
                'flex w-full cursor-pointer items-center p-1 text-start',
                vertical ? 'gap-3' : 'flex-col gap-1.5 text-center',
                radiusClasses.sm,
                'hover:bg-(--n-soft)',
                transitionClasses,
                'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1'
              )}
            >
              {mark(index)}
              <span
                className={cx(
                  'min-w-0',
                  vertical ? 'truncate' : '',
                  metaTextClasses[size],
                  current ? 'font-medium text-(--neba-fg)' : 'text-(--neba-muted-fg)'
                )}
              >
                {item.title}
              </span>
              {/* The row draws a disc and a title, and the disc is decoration.
                  This is what a screen reader hears in place of "Install the
                  CLI" on its own. */}
              <span className={srOnlyClasses}>
                {fill(messages.step, {
                  index: String(index + 1),
                  title: plainTitle(item.title)
                })}
              </span>
            </button>
          </li>
        );
      })}
    </ol>
  );

  const panels = (
    /*
      One grid cell, every panel in it. What is not showing stays in the
      document so the cell keeps the height of the tallest thing that could be
      in it, and is `inert` so it is out of the tab order, off the accessibility
      tree and out of a find-in-page.
    */
    <div className={cx('grid flex-1 grid-cols-1', bounded ? 'min-h-0' : '')}>
      {steps.map((item, index) => {
        const hidden = completed || index !== active;

        return (
          <div
            key={index}
            aria-hidden={hidden}
            inert={hidden || undefined}
            className={cx(
              'col-start-1 row-start-1 min-w-0',
              bounded ? 'overflow-y-auto overscroll-contain' : '',
              hidden ? 'invisible' : (motion?.className ?? '')
            )}
            style={hidden ? undefined : motion?.style}
          >
            <div className="mb-3 flex items-baseline gap-3">
              {hasContent(item.icon) ? (
                // `h-[1lh]` rather than a fixed height: the glyph sits on the
                // heading's own line box, so it stays centred against the title
                // at every step of the size ladder.
                <span
                  aria-hidden="true"
                  className={cx(
                    'flex h-[1lh] shrink-0 items-center text-(--n-accent)',
                    sheetTitleClasses[size],
                    iconClasses
                  )}
                >
                  {item.icon}
                </span>
              ) : null}
              <StepHeading
                level={headingLevel + 1}
                className={cx('m-0 min-w-0 flex-1 font-medium', sheetTitleClasses[size])}
              >
                {item.title}
              </StepHeading>
              <span
                className={cx(
                  'shrink-0 text-(--neba-muted-fg) tabular-nums',
                  metaTextClasses[size]
                )}
              >
                {fill(messages.position, { index: String(index + 1), total: String(total) })}
              </span>
            </div>

            {item.image ? (
              <img
                src={item.image}
                alt={item.imageAlt ?? plainTitle(item.title)}
                className={cx('mb-3 max-h-72 w-full object-contain', radiusClasses[size])}
              />
            ) : null}

            {hasContent(item.content) ? (
              <div className={cx('min-w-0', sheetBodyClasses[size])}>{item.content}</div>
            ) : null}
          </div>
        );
      })}

      {completion ? (
        <div
          aria-hidden={!completed}
          inert={!completed || undefined}
          className={cx(
            'col-start-1 row-start-1 flex min-w-0 flex-col items-center justify-center gap-2 py-4 text-center',
            completed ? (motion?.className ?? '') : 'invisible'
          )}
          style={completed ? motion?.style : undefined}
        >
          <span aria-hidden="true" className="text-(--n-accent) [&_svg]:size-9">
            <SuccessIcon />
          </span>
          <p className={cx('m-0 font-medium', sheetBodyClasses[size])}>
            {completedContent ?? messages.completed}
          </p>
        </div>
      ) : null}
    </div>
  );

  return (
    <div
      ref={ref}
      aria-labelledby={hasContent(title) ? headingId : undefined}
      className={cx(
        'flex min-w-0 flex-col',
        radiusClasses[size],
        boxPaddingClasses[density][size],
        sheetSectionGapClasses[size],
        variantClasses[variant],
        transitionClasses,
        className
      )}
      style={
        {
          ...surfaceSlots(color, elevation),
          // A container's slots leave the fill out, and the numbers need it: a
          // completed step is a filled disc, and the connector behind it is the
          // same fill.
          '--n-fill': `var(--neba-${color}-fill)`,
          '--n-on-solid': `var(--neba-${color}-on-solid)`,
          '--n-step-mark': markSizes[size].box,
          '--n-step-rail': toLength(railWidth),
          ...(bounded ? { maxHeight: toLength(maxHeight) } : null),
          ...style
        } as React.CSSProperties
      }
      {...props}
    >
      {hasContent(title) ? (
        <StepHeading
          level={headingLevel}
          id={headingId}
          className={cx('m-0 shrink-0 font-medium', sheetTitleClasses[size])}
        >
          {title}
        </StepHeading>
      ) : null}

      <div
        className={cx(
          'flex min-w-0 flex-1 flex-col',
          bounded ? 'min-h-0' : '',
          vertical ? 'gap-4 sm:flex-row sm:gap-5' : 'gap-4'
        )}
      >
        <div
          className={cx(
            'flex min-w-0 flex-col',
            bounded ? 'min-h-0' : '',
            vertical ? 'sm:w-(--n-step-rail) sm:shrink-0' : '',
            /*
              The line goes on the list's inner edge, with a matching pad, so
              the space on either side of it is the same: the row's text, the
              gutter, the line, the gutter, the body. Put on the gap alone it
              would sit hard against the list and 20px from the body.

              Both directions are written out because a vertical guide is only
              two columns above `sm` — below it the two have stacked, and a
              line down the side of a stacked layout would be a line down the
              side of nothing.
            */
            divider
              ? vertical
                ? 'border-b pb-4 sm:border-b-0 sm:border-e sm:pb-0 sm:pe-5'
                : 'border-b pb-4'
              : '',
            divider ? '[border-color:var(--n-line)]' : ''
          )}
        >
          {rail}
        </div>

        <div
          className={cx(
            'flex min-w-0 flex-1 flex-col',
            bounded ? 'min-h-0' : '',
            sheetSectionGapClasses[size]
          )}
        >
          {panels}

          {navigation ? (
            <div className="flex shrink-0 flex-wrap items-center justify-end gap-2">
              {completed ? (
                <Button
                  size={size}
                  variant="outline"
                  color={color}
                  startIcon={<RestartIcon />}
                  onClick={() => go(0)}
                >
                  {restartLabel ?? messages.restart}
                </Button>
              ) : (
                <>
                  <Button
                    size={size}
                    variant="outline"
                    color={color}
                    disabled={first}
                    startIcon={
                      <span className="rotate-90 rtl:-rotate-90">
                        <ChevronIcon />
                      </span>
                    }
                    onClick={() => go(active - 1)}
                  >
                    {previousLabel ?? messages.previous}
                  </Button>

                  {last && completion ? (
                    <Button
                      size={size}
                      variant="solid"
                      color={color}
                      startIcon={<CheckIcon />}
                      onClick={() => go(active, true)}
                    >
                      {doneLabel ?? messages.done}
                    </Button>
                  ) : (
                    <Button
                      size={size}
                      variant="solid"
                      color={color}
                      disabled={last}
                      endIcon={
                        <span className="-rotate-90 rtl:rotate-90">
                          <ChevronIcon />
                        </span>
                      }
                      onClick={() => go(active + 1)}
                    >
                      {nextLabel ?? messages.next}
                    </Button>
                  )}
                </>
              )}
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
});

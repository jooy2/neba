'use client';

import * as React from 'react';
import { Popover as BaseUIPopover } from '@base-ui/react/popover';
import { Button } from '../button/Button.js';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { actionMessages, fill, stepsMessages, useMessages } from '../../internal/i18n.js';
import { CloseIcon } from '../../internal/icons.js';
import { observeResize } from '../../internal/observe.js';
import {
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { NebaAlign, NebaSide, NebaSize, NebaStyleProps } from '../../types.js';

/** One stop on the tour. */
export interface TourStep {
  /**
   * A CSS selector for what this step is about. Left out, the step is centred
   * over the page with nothing cut out of the scrim — which is what a welcome
   * step and a closing step are.
   */
  target?: string;
  /** The step's heading. */
  title?: React.ReactNode;
  /** What it says. */
  content?: React.ReactNode;
  /** Which edge of the target the card sits on. @default 'bottom' */
  side?: NebaSide;
  /** Where along that edge. @default 'center' */
  align?: NebaAlign;
  /**
   * How far the cut-out is inflated past the target, in pixels. A control with
   * a focus ring wants a couple; a whole panel wants none.
   * @default 6
   */
  padding?: number;
}

export interface TourProps extends Pick<NebaStyleProps, 'size' | 'color' | 'density'> {
  /** The stops, in order. */
  steps: readonly TourStep[];
  /** Whether the tour is running. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts running, for an uncontrolled one. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which stop, from `0`. Use with `onStepChange` for a controlled one. */
  step?: number;
  /** Which one it starts on. @default 0 */
  defaultStep?: number;
  onStepChange?: (step: number) => void;
  /** Called when the last step's button is pressed, before the tour closes. */
  onFinish?: () => void;
  /**
   * Dims the page and cuts the target out of the dimming. Off, the card is the
   * only thing the tour draws.
   * @default true
   */
  mask?: boolean;
  /** Draws the Skip button beside the counter. @default true */
  skippable?: boolean;
  /** Whether Escape ends the tour. @default true */
  dismissible?: boolean;
  /** Scrolls each target into view as the tour reaches it. @default true */
  scrollIntoView?: boolean;
  /**
   * Which language the buttons and the counter are written in — a BCP 47 tag
   * such as `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   */
  locale?: string;
  /** The Previous button. Defaults to the `locale`'s word. */
  previousLabel?: React.ReactNode;
  /** The Next button. */
  nextLabel?: React.ReactNode;
  /** What Next becomes on the last step. */
  doneLabel?: React.ReactNode;
  /** The Skip button. */
  skipLabel?: React.ReactNode;
}

/** The card. The same frosted sheet a Popover draws, at the same elevation. */
const popupClasses = [
  surfaceClasses,
  'relative flex flex-col',
  'border text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const maxWidthClasses: Record<NebaSize, string> = {
  xs: 'max-w-56',
  sm: 'max-w-64',
  md: 'max-w-80',
  lg: 'max-w-96',
  xl: 'max-w-lg'
};

/** The size the buttons on the card take, one rung under the card's own. */
const buttonSizes: Record<NebaSize, NebaSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'sm',
  xl: 'md'
};

/** Where the target is, in viewport coordinates. */
interface Spot {
  top: number;
  left: number;
  width: number;
  height: number;
}

/**
 * The dimming, with a hole in it.
 *
 * One element the size of the target carrying a shadow far larger than any
 * screen, rather than four rectangles around it: the corners of a four-piece
 * scrim never quite meet, and the seams show as hairlines across the page the
 * moment the dimming is anything but opaque.
 *
 * `pointer-events: none` throughout. A tour that blocked the page would be a
 * modal dialog wearing a cut-out, and the whole point of the cut-out is that
 * the thing it is pointing at can still be used.
 */
function Mask({ spot, radius }: { spot: Spot | null; radius: number }) {
  if (spot === null) {
    return (
      <div
        aria-hidden="true"
        className="pointer-events-none fixed inset-0 z-40 bg-(--neba-scrim)"
      />
    );
  }

  return (
    <div
      aria-hidden="true"
      className="pointer-events-none fixed z-40 [box-shadow:0_0_0_9999px_var(--neba-scrim)]"
      style={{
        top: spot.top,
        left: spot.left,
        width: spot.width,
        height: spot.height,
        borderRadius: radius
      }}
    />
  );
}

/**
 * A guided walk over a page that already exists — the three things a new reader
 * has to be shown once, pointed at where they actually are.
 *
 * It is [HowToSteps](../surfaces/how-to-steps) turned inside out. That component
 * puts the instructions *in* the page and the reader follows them; this one
 * leaves the page as it is and stands over it. The steps are therefore given by
 * selector rather than as content: what a tour is about is already on screen,
 * and describing it a second time inside the card would be two copies to keep
 * in step.
 *
 * The dimming never takes the pointer. A reader can use the control being
 * pointed at while the card is up, which is the difference between a tour and a
 * sequence of dialogs.
 */
export function Tour({
  steps,
  open,
  defaultOpen = false,
  onOpenChange,
  step,
  defaultStep = 0,
  onStepChange,
  onFinish,
  mask = true,
  skippable = true,
  dismissible = true,
  scrollIntoView = true,
  locale,
  previousLabel,
  nextLabel,
  doneLabel,
  skipLabel,
  size = 'md',
  color = 'primary',
  density = 'default'
}: TourProps) {
  const messages = useMessages(stepsMessages, locale);
  const actions = useMessages(actionMessages, locale);

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen);
  const [uncontrolledStep, setUncontrolledStep] = React.useState(defaultStep);

  const running = open ?? uncontrolledOpen;
  const index = Math.min(step ?? uncontrolledStep, Math.max(0, steps.length - 1));
  const current = steps[index];

  /**
   * The measurement, tagged with the selector it belongs to.
   *
   * Tagged rather than bare, because the step changes a frame before the effect
   * re-measures: an untagged rect would draw the *last* step's hole around the
   * next step's card for one paint, which is exactly the flicker the tour is
   * supposed to be too calm for.
   */
  const [measured, setMeasured] = React.useState<{ selector: string; spot: Spot } | null>(null);

  const setOpen = (next: boolean) => {
    if (open === undefined) setUncontrolledOpen(next);
    onOpenChange?.(next);
  };

  const goTo = (next: number) => {
    if (step === undefined) setUncontrolledStep(next);
    onStepChange?.(next);
  };

  /**
   * Where the current target is, re-read on anything that could move it.
   *
   * A tour runs over a live page: something below can load, an image can arrive,
   * the window can be resized, and the hole would be left over a piece of empty
   * background. The scroll listener is what makes the cut-out follow rather than
   * pinning the page — because the page is not pinned.
   */
  React.useEffect(() => {
    const selector = current?.target;

    if (!running || !selector) return undefined;

    const target = document.querySelector(selector);

    if (!(target instanceof HTMLElement)) return undefined;

    if (scrollIntoView) {
      target.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'smooth' });
    }

    const pad = current?.padding ?? 6;
    let frame = 0;

    const read = () => {
      frame = 0;
      const rect = target.getBoundingClientRect();

      setMeasured({
        selector,
        spot: {
          top: rect.top - pad,
          left: rect.left - pad,
          width: rect.width + pad * 2,
          height: rect.height + pad * 2
        }
      });
    };

    const schedule = () => {
      if (frame === 0) frame = requestAnimationFrame(read);
    };

    read();

    const stopObserving = observeResize(target, schedule);

    window.addEventListener('scroll', schedule, { passive: true, capture: true });
    window.addEventListener('resize', schedule, { passive: true });

    return () => {
      if (frame !== 0) cancelAnimationFrame(frame);
      stopObserving();
      window.removeEventListener('scroll', schedule, true);
      window.removeEventListener('resize', schedule);
    };
  }, [running, current?.target, current?.padding, scrollIntoView]);

  if (steps.length === 0) return null;

  const spot =
    running && current?.target && measured?.selector === current.target ? measured.spot : null;

  const first = index === 0;
  const last = index === steps.length - 1;

  const finish = () => {
    onFinish?.();
    setOpen(false);
  };

  const insetX = boxPaddingXClasses[density][size];
  const insetY = boxPaddingYClasses[density][size];
  const buttonSize = buttonSizes[size];
  const hasHeader = hasContent(current?.title) || hasContent(current?.content);

  return (
    <BaseUIPopover.Root
      open={running}
      onOpenChange={(next, details) => {
        if (!next && !dismissible && details.reason === 'escape-key') {
          details.cancel();
          return;
        }
        // Using the page is exactly what a tour is meant to allow, so neither a
        // press outside the card nor the focus leaving it ends one. Only Escape
        // and the card's own buttons do.
        if (!next && (details.reason === 'outside-press' || details.reason === 'focus-out')) {
          details.cancel();
          return;
        }
        setOpen(next);
      }}
    >
      {running && mask ? <Mask spot={spot} radius={spot ? 8 : 0} /> : null}

      <BaseUIPopover.Portal>
        <BaseUIPopover.Positioner
          className="neba-portal z-50 [outline:none]"
          side={current?.side ?? 'bottom'}
          align={current?.align ?? 'center'}
          sideOffset={10}
          collisionPadding={12}
          // A getter rather than an element: the target is found by selector on
          // whatever the page looks like right now, and it changes every step.
          anchor={() => {
            if (!current?.target) return null;

            const found = document.querySelector(current.target);

            return found instanceof Element ? found : null;
          }}
        >
          <BaseUIPopover.Popup
            className={[
              popupClasses,
              radiusClasses[size],
              sheetBodyClasses[size],
              sheetSectionGapClasses[size],
              maxWidthClasses[size],
              insetX,
              insetY
            ].join(' ')}
            style={surfaceSlots(color, 3)}
          >
            {hasHeader ? (
              <div className="flex items-start gap-3">
                <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
                  {hasContent(current?.title) ? (
                    <BaseUIPopover.Title className={`m-0 font-semibold ${sheetTitleClasses[size]}`}>
                      {current?.title}
                    </BaseUIPopover.Title>
                  ) : null}
                  {hasContent(current?.content) ? (
                    <BaseUIPopover.Description className="m-0 min-w-0">
                      {current?.content}
                    </BaseUIPopover.Description>
                  ) : null}
                </div>

                {dismissible ? (
                  <button
                    type="button"
                    aria-label={actions.close}
                    onClick={() => setOpen(false)}
                    className={[
                      'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
                      'rounded-full text-(--neba-muted-fg)',
                      '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
                      '[transition:background-color_var(--neba-duration)_var(--neba-ease),color_var(--neba-duration)_var(--neba-ease)]',
                      'hover:bg-(--n-soft) hover:text-(--neba-fg)',
                      'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
                    ].join(' ')}
                  >
                    <CloseIcon />
                  </button>
                ) : null}
              </div>
            ) : null}

            <div className="flex items-center gap-2">
              <span
                className={`shrink-0 tabular-nums text-(--neba-muted-fg) ${metaTextClasses[size]}`}
              >
                {fill(messages.position, {
                  index: String(index + 1),
                  total: String(steps.length)
                })}
              </span>

              <div className="ms-auto flex items-center gap-2">
                {skippable && !last ? (
                  <Button
                    size={buttonSize}
                    variant="text"
                    color="secondary"
                    onClick={() => setOpen(false)}
                  >
                    {skipLabel ?? messages.skip}
                  </Button>
                ) : null}
                {!first ? (
                  <Button
                    size={buttonSize}
                    variant="outline"
                    color={color}
                    onClick={() => goTo(index - 1)}
                  >
                    {previousLabel ?? messages.previous}
                  </Button>
                ) : null}
                <Button
                  size={buttonSize}
                  color={color}
                  onClick={() => (last ? finish() : goTo(index + 1))}
                >
                  {last ? (doneLabel ?? messages.done) : (nextLabel ?? messages.next)}
                </Button>
              </div>
            </div>
          </BaseUIPopover.Popup>
        </BaseUIPopover.Positioner>
      </BaseUIPopover.Portal>
    </BaseUIPopover.Root>
  );
}

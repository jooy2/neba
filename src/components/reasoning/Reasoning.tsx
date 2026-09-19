'use client';

import * as React from 'react';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { ChevronIcon, SpinnerIcon } from '../../internal/icons.js';
import { formatDuration, useElapsed } from '../../internal/run.js';
import {
  fillMessage,
  reasoningMessages,
  useMessages,
  type ReasoningMessages
} from '../../internal/i18n.js';
import {
  collapsiblePanelClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaSlots, NebaStyleProps, NebaVariant } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** The two parts a Reasoning draws behind its root: the header, and the panel. */
export type ReasoningSlot = 'header' | 'body';

export interface ReasoningProps
  extends
    Pick<NebaStyleProps, 'size' | 'variant' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'onChange'> {
  /**
   * Whether the thinking is still arriving. It is what the header says, what
   * the mark does, and — unless `autoOpen` is off — whether the panel is open.
   * @default false
   */
  streaming?: boolean;
  /**
   * How long the thinking took, in milliseconds.
   *
   * Left out, the panel counts its own from the moment `streaming` went true
   * and keeps the last figure once it stops — which is where "Thought for 4s"
   * comes from. A stretch shorter than a second never gets a number, and the
   * header says so in words instead.
   */
  duration?: number;
  /** Whether the panel is showing. Pass it to drive the disclosure yourself. */
  open?: boolean;
  /**
   * Where an uncontrolled Reasoning starts, before any stream has run.
   * @default false
   */
  defaultOpen?: boolean;
  /** Called when the header, or the stream, opens or closes the panel. */
  onOpenChange?: (open: boolean) => void;
  /**
   * Opens the panel while the stream runs and closes it when the stream ends.
   *
   * On, because that is the whole difference between this and a
   * [Collapsible](../surfaces/collapsible): the reader can watch the thinking
   * as it arrives without asking for it, and is left with a one-line summary
   * rather than a wall of it. Turn it off for a panel that should stay where
   * the reader put it.
   * @default true
   */
  autoOpen?: boolean;
  /** Replaces what the header says. Otherwise it is the `locale`'s sentence. */
  label?: React.ReactNode;
  /**
   * The mark at the start. Defaults to the turning ring while the stream runs
   * and nothing after it; pass `false` to drop it, or a node to replace it.
   */
  icon?: React.ReactNode | false;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Which language the header's own sentence is written in, as a BCP 47 tag. */
  locale?: string;
  /** Those sentences, written out. Overrides the `locale`'s. */
  labels?: Partial<ReasoningMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ReasoningSlot>;
  /** The thinking. */
  children?: React.ReactNode;
}

/**
 * The three weights. `text` is the default here and nowhere else in the
 * library, and the reason is what this component is for: thinking is an aside,
 * and a bordered box around every aside in a conversation is a conversation
 * made of boxes. A sheet is what you reach for when the panel is the only thing
 * on the screen.
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

/**
 * A thinking panel that the stream opens and closes.
 *
 * On a [Spoiler](../surfaces/spoiler) and a
 * [Collapsible](../surfaces/collapsible) the reader owns the open state: they
 * covered it, they uncover it. Here the stream owns it — the panel opens as the
 * thinking starts arriving, stays open while the reader can follow it, and
 * folds itself away into one line when it stops. What is left behind is a
 * record that it happened and how long it took, which is what a reader wants
 * from reasoning they did not need to read.
 *
 * The panel is deliberately **not** a live region. Thinking is long, it is
 * revised as it arrives, and a screen reader reading every revision aloud would
 * bury the answer it is on the way to.
 */
export const Reasoning = React.forwardRef<HTMLDivElement, ReasoningProps>(
  function Reasoning(rawProps, ref) {
    const {
      variant = 'text',
      size = 'md',
      color = 'secondary',
      density = 'default',
      elevation = 0,
      streaming = false,
      duration,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      autoOpen = true,
      label,
      icon,
      locale,
      labels,
      classNames,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const messages = useMessages(reasoningMessages, locale);
    const words = { ...messages, ...labels };

    // A Reasoning that *mounts* mid-stream is already thinking, so it starts
    // open: there is no edge coming to open it, and a panel that stayed shut
    // would hide the one thing arriving on the screen.
    const [openState, setOpenState] = React.useState(defaultOpen || (autoOpen && streaming));
    const [wasStreaming, setWasStreaming] = React.useState(streaming);
    const controlled = openProp !== undefined;
    const open = controlled ? openProp : openState;

    /*
     * React's own "adjusting state when a prop changes". The panel follows the
     * *edges* of `streaming` rather than its value, so a reader who folds the
     * panel away mid-stream is not overruled on the next token.
     */
    if (wasStreaming !== streaming) {
      setWasStreaming(streaming);

      if (autoOpen && !controlled) {
        setOpenState(streaming);
      }
    }

    const millis = useElapsed(streaming, duration);
    const spent = millis === null ? null : formatDuration(millis, locale);
    const heading = hasContent(label)
      ? label
      : streaming
        ? words.thinking
        : spent === null
          ? words.done
          : fillMessage(words.thought, { duration: spent });

    const mark = icon === undefined ? streaming ? <SpinnerIcon /> : null : icon;

    return (
      <BaseUICollapsible.Root
        ref={ref}
        open={open}
        onOpenChange={(next) => {
          if (!controlled) {
            setOpenState(next);
          }
          onOpenChange?.(next);
        }}
        aria-busy={streaming || undefined}
        data-streaming={streaming || undefined}
        className={cx(
          'flex flex-col overflow-hidden',
          radiusClasses[size],
          variantClasses[variant],
          transitionClasses,
          iconClasses,
          className ?? ''
        )}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        {...props}
      >
        <BaseUICollapsible.Trigger
          className={cx(
            'flex w-full cursor-pointer items-center text-start text-(--neba-muted-fg)',
            boxPaddingXClasses[density][size],
            boxPaddingYClasses[density][size],
            gapClasses[size],
            sheetTitleClasses[size],
            transitionClasses,
            'hover:bg-(--n-soft) hover:text-(--n-on-tint)',
            'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
            classNames?.header ?? ''
          )}
        >
          {hasContent(mark) ? (
            <span className="flex h-[1lh] shrink-0 items-center">{mark}</span>
          ) : null}

          <span className="min-w-0 flex-1 truncate font-medium">{heading}</span>

          <span
            className={[
              'flex h-[1lh] shrink-0 items-center',
              '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
              'data-[panel-open]:rotate-180'
            ].join(' ')}
          >
            <ChevronIcon />
          </span>
        </BaseUICollapsible.Trigger>

        <BaseUICollapsible.Panel className={collapsiblePanelClasses}>
          {/*
            The rule down the inside edge rather than a second sheet: what is in
            here is prose, and a box around prose inside a box around a message
            is two frames a reader has to look past to read one paragraph.
          */}
          <div
            className={cx(
              'min-w-0 border-s-2 text-(--neba-muted-fg) [border-color:var(--n-line)]',
              boxPaddingXClasses[density][size],
              density === 'compact' ? 'pb-2' : 'pb-4',
              sheetBodyClasses[size],
              classNames?.body ?? ''
            )}
          >
            {children}
          </div>
        </BaseUICollapsible.Panel>
      </BaseUICollapsible.Root>
    );
  }
);

'use client';

import * as React from 'react';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { ChevronIcon } from '../../internal/icons.js';
import { formatDuration, runColor, runIcon, useElapsed } from '../../internal/run.js';
import {
  runMessages,
  toolMessages,
  useMessages,
  type RunMessages,
  type ToolMessages
} from '../../internal/i18n.js';
import {
  collapsiblePanelClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  preformattedClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  srOnlyClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaElevation,
  NebaRunStatus,
  NebaSize,
  NebaSlots,
  NebaStyleProps
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * The parts a ToolCall draws behind its root.
 *
 * `header` is the row that is always there — the mark, the name, the elapsed
 * time and the chevron — and `body` is the panel behind it. `args` and
 * `result` name the two blocks inside that panel, because they are what a
 * caller reaches for: a tool whose arguments are long enough to want their own
 * scroll is the ordinary case.
 */
export type ToolCallSlot = 'header' | 'body' | 'args' | 'result';

export interface ToolCallProps
  extends
    Pick<NebaStyleProps, 'size' | 'variant' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'onChange'> {
  /**
   * What was called. Drawn in the monospaced face, because a tool name is an
   * identifier rather than a phrase.
   */
  name: React.ReactNode;
  /**
   * How far the call has got. It decides the mark, the colour family and what
   * the panel shows — an `error` draws `error` where a `success` draws
   * `result`.
   * @default 'pending'
   */
  status?: NebaRunStatus;
  /**
   * What the tool was called with. A string is drawn as preformatted text; a
   * node is rendered as it is, so a [CodeBlock](../display/code-block) or a
   * table of parameters goes straight in.
   */
  args?: React.ReactNode;
  /** What it answered, under the same rule. */
  result?: React.ReactNode;
  /**
   * What went wrong, shown in place of `result` while `status` is `error`.
   * Without it a failed call shows its `result`, which is often the error the
   * tool itself returned.
   */
  error?: React.ReactNode;
  /**
   * How long the call took, in milliseconds.
   *
   * Left out, a `running` call counts its own time from the moment it started
   * running and says nothing for the first second — a number ticking up is the
   * only thing on the row that says the call has not hung. The count stops the
   * moment a real figure arrives, because at that point it was only ever
   * standing in for one.
   */
  duration?: number;
  /**
   * Anything else that belongs on the header line — a server name, a token
   * count, a retry badge. Sits after the name and before the elapsed time.
   */
  meta?: React.ReactNode;
  /**
   * The mark at the start. Defaults to the one that goes with `status`; pass
   * `false` to drop it, or a node to replace it.
   */
  icon?: React.ReactNode | false;
  /** Whether the panel is showing. Pass it to drive the disclosure yourself. */
  open?: boolean;
  /**
   * Where an uncontrolled ToolCall starts. A call that *fails* opens itself
   * whatever this said, unless `open` is holding it: a reader should not have
   * to go looking for the reason something did not work.
   * @default false
   */
  defaultOpen?: boolean;
  /** Called when the header opens or closes the panel. */
  onOpenChange?: (open: boolean) => void;
  /**
   * Drop shadow depth. `0` (the default) is flat — a tool call belongs to the
   * transcript it sits in rather than floating over it.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Which language the status and the two headings are said in — a BCP 47 tag
   * such as `ko` or `pt-BR`. Unsupported tags fall back to English.
   */
  locale?: string;
  /** Those words, written out. Overrides the `locale`'s. */
  labels?: Partial<RunMessages & ToolMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ToolCallSlot>;
  /** Anything to put under the result — a follow-up action, a note. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them: the sheet is never
 * dyed, exactly as on Box and Collapsible. What a tool call holds is somebody
 * else's JSON, and tinting the sheet under it would put every syntax colour on
 * a background it was not chosen against.
 *
 * `text` is the one to reach for in a transcript, where a dozen bordered
 * rectangles down one column is a dozen rectangles too many.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
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

/** The name, one step above the two headings inside the panel. */
const nameClasses: Record<NebaSize, string> = sheetTitleClasses;

/** Which block a status shows, and which of the two headings goes over it. */
function bodyOf(
  status: NebaRunStatus,
  result: React.ReactNode,
  error: React.ReactNode
): React.ReactNode {
  return status === 'error' && hasContent(error) ? error : result;
}

/**
 * One tool invocation: what was called, what with, what came back, and how long
 * it took.
 *
 * The smallest unit of an agent transcript, and the one thing nothing else in
 * the library composes into. A [Collapsible](../surfaces/collapsible) folds
 * content a reader owns the state of; this one is opened and closed by a call
 * that is still happening, and its result is not there on the first render.
 *
 * Base UI owns the disclosure — the button and panel pairing, the
 * `aria-expanded` and `aria-controls` between them, and the measured height the
 * panel opens over — so what is left here is the header row, the two blocks
 * inside the panel and the arithmetic on the clock.
 */
export const ToolCall = React.forwardRef<HTMLDivElement, ToolCallProps>(
  function ToolCall(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      name,
      status = 'pending',
      args,
      result,
      error,
      duration,
      meta,
      icon,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      locale,
      labels,
      classNames,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const run = useMessages(runMessages, locale);
    const tool = useMessages(toolMessages, locale);
    const words = { ...run, ...tool, ...labels };

    const [openState, setOpenState] = React.useState(defaultOpen);
    const controlled = openProp !== undefined;
    const open = controlled ? openProp : openState;

    /*
     * A call that has just failed opens itself. The `previous` ref is what makes
     * that a *transition* rather than a standing rule: a reader who closed a
     * failed call again should not have it reopened by the next render, and an
     * error that was already on screen when the component mounted was already
     * where the caller put it.
     */
    const previous = React.useRef(status);

    React.useEffect(() => {
      if (previous.current !== status && status === 'error' && !controlled) {
        setOpenState(true);
      }

      previous.current = status;
    }, [status, controlled]);

    const millis = useElapsed(status === 'running', duration);
    const family = runColor(status, color);
    const mark = icon === undefined ? runIcon(status) : icon;
    const body = bodyOf(status, result, error);
    const hasBody = hasContent(args) || hasContent(body) || hasContent(children);

    const padX = boxPaddingXClasses[density][size];
    const padY = boxPaddingYClasses[density][size];

    const headerRow = (
      <>
        {hasContent(mark) ? (
          <span className="flex h-[1lh] shrink-0 items-center text-(--n-accent)">{mark}</span>
        ) : null}

        <span className={cx('min-w-0 truncate font-mono font-semibold', nameClasses[size])}>
          {name}
        </span>

        {/* The status is a shape and a colour on the screen, and neither is read
            out. This is the same sentence for everyone else. */}
        <span className={srOnlyClasses}>{words[status]}</span>

        {hasContent(meta) ? (
          <span className={cx('min-w-0 truncate text-(--neba-muted-fg)', metaTextClasses[size])}>
            {meta}
          </span>
        ) : null}

        <span className="flex-1" />

        {millis === null ? null : (
          <span
            className={cx('shrink-0 tabular-nums text-(--neba-muted-fg)', metaTextClasses[size])}
          >
            {formatDuration(millis, locale)}
          </span>
        )}
      </>
    );

    const rootClasses = cx(
      // The panel is a window opening onto the body, so the sheet clips it —
      // which is also what keeps the body inside the sheet's own corners while
      // the height moves.
      'flex flex-col overflow-hidden',
      radiusClasses[size],
      variantClasses[variant],
      transitionClasses,
      iconClasses,
      className ?? ''
    );

    const rootStyle = { ...surfaceSlots(family, elevation), ...style };

    if (!hasBody) {
      return (
        <div ref={ref} data-status={status} className={rootClasses} style={rootStyle} {...props}>
          <div
            className={cx(
              'flex items-center',
              padX,
              padY,
              gapClasses[size],
              classNames?.header ?? ''
            )}
          >
            {headerRow}
          </div>
        </div>
      );
    }

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
        data-status={status}
        className={rootClasses}
        style={rootStyle}
        {...props}
      >
        <BaseUICollapsible.Trigger
          className={cx(
            'flex w-full cursor-pointer items-center text-start',
            padX,
            padY,
            gapClasses[size],
            transitionClasses,
            'hover:bg-(--n-soft)',
            // Inset rather than offset: the sheet clips its children so the
            // panel can be a window, and `overflow: hidden` shaves an offset
            // ring off a trigger that fills the top of the sheet.
            'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
            classNames?.header ?? ''
          )}
        >
          {headerRow}

          <span
            className={[
              'flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)',
              '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
              'data-[panel-open]:rotate-180'
            ].join(' ')}
          >
            <ChevronIcon />
          </span>
        </BaseUICollapsible.Trigger>

        <BaseUICollapsible.Panel className={collapsiblePanelClasses}>
          <div
            className={cx(
              'flex min-w-0 flex-col gap-2 pb-4',
              padX,
              sheetBodyClasses[size],
              density === 'compact' ? 'pb-2' : '',
              classNames?.body ?? ''
            )}
          >
            {hasContent(args) ? (
              <Block
                size={size}
                label={words.arguments}
                className={classNames?.args}
                value={args}
              />
            ) : null}

            {hasContent(body) ? (
              <Block
                size={size}
                label={words.result}
                className={classNames?.result}
                value={body}
                accent={status === 'error'}
              />
            ) : null}

            {children}
          </div>
        </BaseUICollapsible.Panel>
      </BaseUICollapsible.Root>
    );
  }
);

/**
 * One labelled block inside the panel.
 *
 * The string test is the whole of what it decides: a string is what a tool
 * actually hands back, and it arrives already formatted — indented JSON, a
 * stack trace, a diff — so it goes into a `<pre>` where its own line breaks are
 * the ones that survive. Anything else is a node the caller built and is
 * rendered untouched.
 */
function Block({
  size,
  label,
  value,
  className,
  accent = false
}: {
  size: NebaSize;
  label: string;
  value: React.ReactNode;
  className?: string;
  accent?: boolean;
}) {
  return (
    <div className={cx('flex min-w-0 flex-col gap-1', className ?? '')}>
      <span
        className={cx(
          'font-medium tracking-wide text-(--neba-muted-fg) uppercase',
          metaTextClasses[size]
        )}
      >
        {label}
      </span>
      {typeof value === 'string' ? (
        <pre className={cx(preformattedClasses, 'max-h-64', accent ? 'text-(--n-accent)' : '')}>
          {value}
        </pre>
      ) : (
        <div className={accent ? 'text-(--n-accent)' : undefined}>{value}</div>
      )}
    </div>
  );
}

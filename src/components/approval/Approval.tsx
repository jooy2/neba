'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { boxPaddingClasses } from '../box/Box.js';
import { CheckIcon, severityIcon } from '../../internal/icons.js';
import { approvalMessages, useMessages, type ApprovalMessages } from '../../internal/i18n.js';
import {
  cx,
  hasContent,
  iconClasses,
  metaTextClasses,
  preformattedClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaElevation,
  NebaSlots,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * How much is at stake if the answer is wrong.
 *
 * Three rather than a number, because what a reader does with this is decide
 * how carefully to read the rest of the card, and a 0-to-10 scale is a decision
 * every product would calibrate differently. It is drawn as a word on a chip
 * and never as a colour alone.
 */
export type ApprovalRisk = 'low' | 'medium' | 'high';

/** One answer the agent is offering. */
export interface ApprovalOption {
  /** What is reported to `onDecide`, and what identifies the answer afterwards. */
  value: string;
  /** The word on the button. */
  label: React.ReactNode;
  /** A line under the row of buttons, saying what this answer commits to. */
  description?: React.ReactNode;
  /** Overrides the card's family for this one button. */
  color?: NebaColor;
  /**
   * Overrides the weight of this one button. Every option is `outline` by
   * default, and that is the decision rather than the absence of one — see the
   * note on the component.
   */
  variant?: NebaVariant;
  /** A glyph before the label. */
  icon?: React.ReactNode;
  /** Offered but not available — a permission the reader cannot grant. */
  disabled?: boolean;
}

/**
 * The parts an Approval draws behind its root.
 *
 * `details` is the block holding what the agent is actually asking to do, and
 * `actions` the row of answers. Both are parts a caller can see and has no
 * other way to name: a details block with its own scroll and an action row that
 * runs full width on a phone are the two things every product changes.
 */
export type ApprovalSlot = 'title' | 'description' | 'details' | 'actions';

export interface ApprovalProps
  extends
    Pick<NebaStyleProps, 'size' | 'variant' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title'> {
  /** The answers. At least one; three is the usual shape. */
  options: readonly ApprovalOption[];
  /**
   * What is being asked. Defaults to the `locale`'s "Permission needed", for
   * the reason an [Empty](../feedback/empty) has a default title: a request
   * with nothing written on it still has to say what kind of thing it is.
   */
  title?: React.ReactNode;
  /** The sentence under the heading, saying why. */
  description?: React.ReactNode;
  /**
   * What the agent is asking to do — a command, a payload, a file path. A
   * string is drawn as preformatted text with its own line breaks kept; a node
   * is rendered as it is, which is where an editable form of the arguments
   * goes.
   */
  details?: React.ReactNode;
  /**
   * How much is at stake. Drawn as a word on a chip beside the heading, and it
   * takes over the card's colour family: `low` is `info`, `medium` is
   * `warning`, `high` is `danger`.
   */
  risk?: ApprovalRisk;
  /**
   * Which option was taken. `null` — the default — is a request still waiting
   * for an answer.
   *
   * Pass it to drive the Approval yourself. Left out, the card remembers the
   * button that was pressed, which is enough for a transcript that is not
   * re-rendered from a server.
   */
  decision?: string | null;
  /** Called with an option's `value` when its button is pressed. */
  onDecide?: (value: string) => void;
  /**
   * The glyph at the start. Defaults to the severity mark that goes with the
   * family; pass `false` to drop it, or a node to replace it.
   */
  icon?: React.ReactNode | false;
  /** Every option stops answering. The card stays exactly as it is otherwise. */
  disabled?: boolean;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Which language the default heading and the risk chip are written in. */
  locale?: string;
  /** Those words, written out. Overrides the `locale`'s. */
  labels?: Partial<ApprovalMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ApprovalSlot>;
  /** Anything else the body needs, under the details and above the answers. */
  children?: React.ReactNode;
}

/**
 * What a risk level is worth in colour.
 *
 * Three of the six families, and the three that already mean this everywhere
 * else in the library — which is the whole reason `risk` is not a `color` of
 * its own. A product that wanted amber to mean "high" would be teaching its
 * readers a second colour language on one card.
 */
const riskColors: Record<ApprovalRisk, NebaColor> = {
  low: 'info',
  medium: 'warning',
  high: 'danger'
};

/**
 * The same three weights the rest of the library says, said the way a container
 * says them: the sheet is never dyed. What is inside an Approval is a command or
 * a payload, and the family shows up in the edge, the glyph and the chip.
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
  text: 'text-(--neba-fg) bg-(--n-soft)'
};

/**
 * The agent asking permission, and the record of what was decided.
 *
 * A [Confirm](../feedback/confirm) and a [Popconfirm](./../feedback/popconfirm)
 * are opened by the reader, offer two answers, and are gone the moment one is
 * taken. This is opened by the agent, offers as many answers as the agent has
 * — allow once, always allow, deny — and **stays**: a transcript in which the
 * question disappears once it is answered is a transcript that cannot be read
 * back to find out what was agreed to.
 *
 * **No option is emphasised by default.** Every button is `outline` in the
 * card's own family, and an option's own `variant` is how one is singled out.
 * A permission request whose most prominent button is "Allow" is a request
 * answered by the shape of the buttons rather than by the reader, and the whole
 * point of asking is that the answer should be the reader's.
 */
export const Approval = React.forwardRef<HTMLDivElement, ApprovalProps>(
  function Approval(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      // An approval is a question about whether to go ahead, which is what the
      // warning family means everywhere else in the library. `risk` overrides
      // it, and is the usual way this is set.
      color = 'warning',
      density = 'default',
      elevation = 0,
      options,
      title,
      description,
      details,
      risk,
      decision: decisionProp,
      onDecide,
      icon,
      disabled = false,
      locale,
      labels,
      classNames,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const messages = useMessages(approvalMessages, locale);
    const words = { ...messages, ...labels };

    const [taken, setTaken] = React.useState<string | null>(null);
    const controlled = decisionProp !== undefined;
    const decision = controlled ? decisionProp : taken;

    const family = risk ? riskColors[risk] : color;
    const glyph = icon === undefined ? severityIcon(family) : icon;
    const heading = hasContent(title) ? title : words.request;
    const titleId = React.useId();
    const answer = decision === null ? undefined : options.find((o) => o.value === decision);

    return (
      <div
        ref={ref}
        // A group rather than a region: the card is a question with its answers
        // beside it, and naming it after the question is what lets a screen
        // reader's element list say which permission is being asked about.
        role="group"
        aria-labelledby={titleId}
        data-decided={decision ?? undefined}
        className={cx(
          'flex w-full flex-col',
          boxPaddingClasses[density][size],
          radiusClasses[size],
          sheetSectionGapClasses[size],
          sheetBodyClasses[size],
          variantClasses[variant],
          transitionClasses,
          iconClasses,
          className ?? ''
        )}
        style={{ ...surfaceSlots(family, elevation), ...style }}
        {...props}
      >
        <div className="flex items-start gap-3">
          {hasContent(glyph) ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--n-accent)">{glyph}</span>
          ) : null}

          <div className={cx('flex min-w-0 flex-1 flex-col', sheetHeaderGapClasses[size])}>
            <div
              id={titleId}
              className={cx(
                'font-semibold text-(--n-accent)',
                sheetTitleClasses[size],
                classNames?.title ?? ''
              )}
            >
              {heading}
            </div>
            {hasContent(description) ? (
              <div className={cx('text-(--neba-muted-fg)', classNames?.description ?? '')}>
                {description}
              </div>
            ) : null}
          </div>

          {risk ? (
            <span
              className={cx(
                'shrink-0 rounded-full bg-(--n-soft) px-2 py-0.5 font-medium text-(--n-on-tint)',
                metaTextClasses[size]
              )}
            >
              {words[risk]}
            </span>
          ) : null}
        </div>

        {hasContent(details) ? (
          <div className={cx('min-w-0', classNames?.details ?? '')}>
            {typeof details === 'string' ? (
              <pre className={cx(preformattedClasses, 'max-h-56')}>{details}</pre>
            ) : (
              details
            )}
          </div>
        ) : null}

        {children}

        <div className={cx('flex min-w-0 flex-col gap-1.5', classNames?.actions ?? '')}>
          {answer ? (
            <div className="flex items-center gap-2 text-(--neba-muted-fg)">
              <span className="flex h-[1lh] shrink-0 items-center text-(--n-accent)">
                <CheckIcon />
              </span>
              <span className={metaTextClasses[size]}>{words.answered}</span>
              <span className="min-w-0 font-medium text-(--neba-fg)">{answer.label}</span>
            </div>
          ) : (
            <>
              <div className="flex flex-wrap gap-2">
                {options.map((option) => (
                  <Button
                    key={option.value}
                    size={size}
                    // Not emphasised unless the caller says so. See the note on
                    // the component: a request whose loudest button is "Allow"
                    // is answered by its layout.
                    variant={option.variant ?? 'outline'}
                    color={option.color ?? family}
                    startIcon={option.icon}
                    disabled={disabled || option.disabled}
                    onClick={() => {
                      if (!controlled) {
                        setTaken(option.value);
                      }
                      onDecide?.(option.value);
                    }}
                  >
                    {option.label}
                  </Button>
                ))}
              </div>

              {options.some((option) => hasContent(option.description)) ? (
                <ul
                  className={cx(
                    'm-0 flex list-none flex-col gap-0.5 p-0 text-(--neba-muted-fg)',
                    metaTextClasses[size]
                  )}
                >
                  {options
                    .filter((option) => hasContent(option.description))
                    .map((option) => (
                      <li key={option.value}>
                        <span className="font-medium text-(--neba-fg)">{option.label}</span>
                        {' — '}
                        {option.description}
                      </li>
                    ))}
                </ul>
              ) : null}
            </>
          )}
        </div>
      </div>
    );
  }
);

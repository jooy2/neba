import * as React from 'react';
import { boxPaddingClasses } from '../box/Box.js';
import { actionMessages, useMessages } from '../../internal/i18n.js';
import { CloseIcon, severityIcons } from '../../internal/icons.js';
import { transitionProps } from '../../internal/animate.js';
import {
  controlSlots,
  hasContent,
  iconClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaElevation, NebaStyleProps, NebaTransition } from '../../types.js';

export interface AlertProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title'> {
  /**
   * Drop shadow depth. `0` (the default) is flat. An alert belongs to the flow
   * of the page it interrupts; the one that floats above it is a Toast.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * An entrance animation, run once on mount: `transition="slide"` for a banner
   * arriving, `transition="fade"` for one appearing in place. For a trigger or
   * a replay, wrap it in an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /**
   * The heading line. With it the alert is two-part — a headline and the detail
   * under it; without it the whole thing is one line.
   */
  title?: React.ReactNode;
  /**
   * The glyph at the start. Defaults to the one that goes with `color`; pass
   * `false` to drop it, or a node to replace it. A node is sized in `em`, so it
   * tracks whichever line it sits on.
   */
  icon?: React.ReactNode | false;
  /**
   * Content pinned to the end of the row — a "Retry" button, a link. Kept out
   * of `children` so it stays on the first line while the message wraps.
   */
  action?: React.ReactNode;
  /** Passing it is what makes the dismiss button appear. */
  onClose?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /**
   * Which language the dismiss button is named in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * `closeLabel` writes the word out instead; this is for the far more common
   * case where the page already knows its own language.
   */
  locale?: string;
  /** Accessible name of the dismiss button. Defaults to the `locale`'s word. */
  closeLabel?: string;
  /** The message. */
  children?: React.ReactNode;
}

/**
 * An alert *is* the thing being coloured — it is a notice about a severity, not
 * a container holding someone else's content — so unlike a Box its panel takes
 * the tint. The same three weights they mean everywhere: filled, hairline, none.
 */
const restClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  // No sheet and no edge, only the tint. For an alert set among form fields,
  // where a second bordered rectangle is one rectangle too many.
  text: 'text-(--neba-fg) bg-(--n-soft)'
};

/**
 * On `solid` the surface already carries the family, so the glyph and the title
 * ride on it as one ink. On the other two the surface is only faintly tinted:
 * the message has to stay ordinary reading text, and the accent is spent on the
 * two things that say which kind of alert this is.
 */
const accentClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: '',
  outline: 'text-(--n-accent)',
  text: 'text-(--n-accent)'
};

/**
 * The detail line under a title.
 *
 * On a tinted surface it drops to the muted ink, the same step a field's
 * description takes. On a filled one there is no muted ink to drop to — the
 * page's grey is invisible on an accent fill — so the ink stays and the title
 * does the separating with its weight.
 */
const detailClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: '',
  outline: 'text-(--neba-muted-fg)',
  text: 'text-(--neba-muted-fg)'
};

/**
 * Which live region an alert belongs in.
 *
 * `alert` interrupts whatever a screen reader is in the middle of saying;
 * `status` waits for a pause. "This failed" is worth interrupting for and
 * "saved" is not, so the severity decides — and a caller who knows better still
 * wins, because their props spread after this.
 */
const rolesFor: Record<NebaColor, 'alert' | 'status'> = {
  primary: 'status',
  secondary: 'status',
  info: 'status',
  success: 'status',
  warning: 'alert',
  danger: 'alert'
};

/**
 * A message about something that happened, set into the page it is about.
 *
 * The three shapes people mean by "an alert" are one component with different
 * slots filled rather than three components: a bare line
 * (`<Alert icon={false}>`), a line with a glyph (the default), and a glyph with
 * a headline and the detail under it (`title` plus `children`). Nothing about
 * the surface changes between them — only how much of it is used.
 *
 * There is no Base UI primitive under this, and there should not be: an alert
 * has no interaction to delegate. It is a live region with a layout, and the
 * only interactive parts it can grow — the action and the dismiss button — are
 * real buttons that the caller either passes in or gets by passing `onClose`.
 */
export const Alert = React.forwardRef<HTMLDivElement, AlertProps>(function Alert(
  {
    variant = 'outline',
    size = 'md',
    // An alert with no severity named is an informational one. This is the one
    // place `primary` would be a lie: it is not the primary anything, it is a
    // note, and the palette already has the word for that.
    color = 'info',
    density = 'default',
    elevation = 0,
    title,
    icon,
    action,
    onClose,
    locale,
    closeLabel,
    transition,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const messages = useMessages(actionMessages, locale);
  const glyph = icon === undefined ? severityIcons[color] : icon;
  const accent = accentClasses[variant];
  const titled = hasContent(title);
  const animation = transitionProps(transition);

  return (
    <div
      ref={ref}
      role={rolesFor[color]}
      className={[
        'flex w-full items-start',
        boxPaddingClasses[density][size],
        radiusClasses[size],
        sheetSectionGapClasses[size],
        sheetBodyClasses[size],
        transitionClasses,
        restClasses[variant],
        iconClasses,
        animation.className,
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...controlSlots(color, elevation, variant), ...animation.style, ...style }}
      {...props}
    >
      {hasContent(glyph) ? (
        // `h-[1lh]` rather than a margin: the glyph centres on the first line of
        // text whatever the type scale turns out to be, so a one-line alert
        // looks centred and a three-line one still has its glyph at the top.
        <span className={`flex h-[1lh] shrink-0 items-center ${accent}`}>{glyph}</span>
      ) : null}

      <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
        {titled ? (
          <div className={`neba-title font-semibold ${sheetTitleClasses[size]} ${accent}`}>
            {title}
          </div>
        ) : null}
        {hasContent(children) ? (
          // Under a title the message is supporting detail and steps back to the
          // muted ink. On its own it *is* the alert, and stays reading text.
          <div className={titled ? detailClasses[variant] : undefined}>{children}</div>
        ) : null}
      </div>

      {hasContent(action) ? (
        <div className="flex h-[1lh] shrink-0 items-center">{action}</div>
      ) : null}

      {onClose ? (
        <span className="flex h-[1lh] shrink-0 items-center">
          <button
            type="button"
            aria-label={closeLabel ?? messages.dismiss}
            onClick={onClose}
            className={[
              'inline-flex size-[1.15em] cursor-pointer items-center justify-center rounded-full',
              'opacity-70 [transition:opacity_var(--neba-duration)_var(--neba-ease)]',
              'hover:opacity-100 focus-visible:opacity-100',
              'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
            ].join(' ')}
          >
            <CloseIcon />
          </button>
        </span>
      ) : null}
    </div>
  );
});

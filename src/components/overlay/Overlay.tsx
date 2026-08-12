import * as React from 'react';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { useMessages } from '../../internal/i18n';
import { surfaceSlots } from '../../internal/styles';
import type { NebaAlign, NebaColor, NebaSize } from '../../types';

/**
 * How much of the page the overlay takes away.
 *
 * The four steps are one axis — how legible is what is behind — and they are
 * tuned with the blur radius as much as with the alpha, because past about
 * 16px a backdrop smears into flat colour and the scrim reads opaque no matter
 * how low its alpha goes.
 *
 * - `scrim` — the neutral dim a Dialog puts behind itself. The page is still
 *   there and still readable; it has only stopped being reachable.
 * - `blur` — frosted. A lighter dim over a real blur, so the page is present as
 *   shape and colour but not as words. For "this is being replaced".
 * - `solid` — the page surface, opaque. For a screen that is genuinely gone.
 * - `clear` — nothing drawn at all. Still blocks the pointer, which is the
 *   whole reason to reach for it: an invisible sheet that catches a click.
 */
export type OverlayTone = 'scrim' | 'blur' | 'solid' | 'clear';

/**
 * An overlay takes `size`, `color` and `align` and stops there.
 *
 * There is no `variant` — the three weights answer "how much does this surface
 * assert itself against the page", and an overlay has taken the page. There is
 * no `elevation` either: the overlay *is* the plane everything else floats
 * above, and a scrim with a drop shadow is a scrim with an edge.
 */
export interface OverlayProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'children'
> {
  /** The overlay is shown. Use with `onOpenChange` for a controlled overlay. */
  open?: boolean;
  /** Whether the overlay starts shown, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** How much of the page is taken away. @default 'scrim' */
  tone?: OverlayTone;
  /**
   * Whether clicking the overlay or pressing Escape closes it.
   *
   * Off by default, which is the other way round from [Dialog](./dialog). A
   * dialog asks a question and Escape is the universal "no"; an overlay is not
   * asking anything — it is saying *wait* — and a save that can be dismissed
   * by a stray click is a save the user will think finished. Turn it on for the
   * overlay whose job is to catch a click outside something.
   * @default false
   */
  dismissible?: boolean;
  /**
   * Whether the page behind is taken away for the keyboard too. `'trap-focus'`
   * leaves the page scrollable and clickable while still holding focus inside,
   * which is what a `clear` overlay usually wants.
   * @default true
   */
  modal?: boolean | 'trap-focus';
  /** Where the content sits down the viewport. @default 'center' */
  align?: NebaAlign;
  /** Scale of the padding around the content. @default 'md' */
  size?: NebaSize;
  /** Semantic colour role. Reaches the focus ring and whatever the content reads. */
  color?: NebaColor;
  /**
   * Which language the overlay is named in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * `label` writes the word out instead; this is for the far more common
   * case where the page already knows its own language.
   */
  locale?: string;
  /**
   * The accessible name of the overlay. An overlay that holds nothing readable
   * — a bare spinner, a `clear` sheet — still has to say what it is, so this
   * falls back to the `locale`'s word for it rather than to nothing.
   */
  label?: string;
  /** What sits on top of the scrim — a spinner, a line of text, a small card. */
  children?: React.ReactNode;
}

/**
 * The four tones.
 *
 * `scrim` matches Dialog's backdrop exactly — the two have to, or a dialog
 * opened over an overlay would show a seam. `clear` draws nothing and still
 * covers the viewport, so it goes on catching pointer events.
 */
const toneClasses: Record<OverlayTone, string> = {
  scrim: 'bg-(--neba-scrim) [backdrop-filter:blur(2px)]',
  blur: '[background-color:color-mix(in_oklab,var(--neba-scrim)_55%,transparent)] [backdrop-filter:blur(14px)_saturate(1.4)]',
  solid: 'bg-(--neba-surface)',
  clear: ''
};

const alignClasses: Record<NebaAlign, string> = {
  start: 'items-start',
  center: 'items-center',
  end: 'items-end'
};

/** The padding between the content and the edge of the viewport. */
const insetClasses: Record<NebaSize, string> = {
  xs: 'p-3',
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8',
  xl: 'p-10'
};

/**
 * Opacity only, on both the scrim and the content. An overlay that scales or
 * slides drags whatever is written on it across the screen, which is the one
 * thing the house style is against — and unlike a control, this one is usually
 * carrying a sentence.
 */
const fadeClasses = [
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/**
 * A sheet over the whole page that stops it being used.
 *
 * The difference from [Dialog](../surfaces/dialog) is what is *not* here: no
 * surface, no border, no title, no actions. An overlay is the scrim on its own,
 * with whatever the caller puts on top of it — most often a spinner and a line
 * saying what is being waited for.
 *
 * It is not dismissible by default, and that is the one prop worth reading
 * twice. Everything else Base UI owns: the portal, the scroll lock, the focus
 * held inside, the page behind going inert, and focus returning to wherever it
 * came from when the overlay closes.
 */
export function Overlay({
  open,
  defaultOpen,
  onOpenChange,
  tone = 'scrim',
  dismissible = false,
  modal = true,
  align = 'center',
  size = 'md',
  color = 'primary',
  locale,
  label,
  className,
  style,
  children,
  ...props
}: OverlayProps) {
  const messages = useMessages(locale);

  return (
    <BaseUIDialog.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      disablePointerDismissal={!dismissible}
      onOpenChange={(next, details) => {
        // `disablePointerDismissal` covers the click; Escape has no prop of its
        // own, so it is cancelled here by the reason the change arrives with.
        if (!dismissible && !next && details.reason === 'escape-key') {
          details.cancel();
          return;
        }
        onOpenChange?.(next);
      }}
    >
      <BaseUIDialog.Portal>
        {/* `neba-portal` is a hook, not a style: a portalled surface leaves the
            subtree a host may have scoped its CSS reset to. */}
        <BaseUIDialog.Backdrop
          className={`neba-portal fixed inset-0 z-50 ${fadeClasses} ${toneClasses[tone]}`}
        />

        {/* The viewport is what the content is centred in, and it is also what
            makes `dismissible` mean anything: it covers the scrim, so a click
            that misses the content is an outside press rather than a click on
            the overlay itself. */}
        <BaseUIDialog.Viewport
          className={[
            'neba-portal fixed inset-0 z-50 flex justify-center',
            alignClasses[align],
            insetClasses[size]
          ].join(' ')}
        >
          <BaseUIDialog.Popup
            aria-label={label ?? messages.overlay.label}
            className={[
              'flex max-h-full max-w-full flex-col items-center justify-center',
              '[outline:none]',
              fadeClasses,
              className ?? ''
            ]
              .filter(Boolean)
              .join(' ')}
            style={{ ...surfaceSlots(color, 0), ...style }}
            {...props}
          >
            {children}
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}

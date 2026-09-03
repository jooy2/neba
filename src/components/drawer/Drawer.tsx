'use client';

import * as React from 'react';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { actionMessages, useMessages } from '../../internal/i18n.js';
import { CloseIcon } from '../../internal/icons.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  popupFadeClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { NebaSide, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * How the panel relates to the page.
 *
 * - `overlay` — it is opened, it floats over the page on a scrim, it holds the
 *   focus, and it is dismissed. The navigation drawer behind a hamburger, the
 *   filter panel beside a table.
 * - `inline` — it is part of the layout and the page is laid out around it. No
 *   scrim, no portal, no focus trap, nothing to dismiss. The sidebar that is
 *   simply there.
 *
 * A separate axis from `variant`, which already means the weight of a surface
 * across the whole library and would be a second spelling of nothing.
 */
export type NebaDrawerMode = 'overlay' | 'inline';

/**
 * A drawer takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`, for Dialog's reason: the three weights answer "how
 * much does this surface assert itself against the page", and a panel that has
 * taken an edge of the window has answered it. There is no `elevation` either —
 * an `overlay` drawer floats and carries a shadow at level 3, an `inline` one is
 * part of the layout and carries none, and neither is a decision worth offering.
 */
export interface DrawerProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /**
   * Which edge the panel is attached to. Physical rather than logical, the way
   * `NebaSide` is everywhere: a drawer along the top of the window is along the
   * top in every writing direction.
   * @default 'left'
   */
  side?: NebaSide;
  /** @default 'overlay' */
  mode?: NebaDrawerMode;
  /** The drawer is shown. Use with `onOpenChange` for a controlled drawer. */
  open?: boolean;
  /**
   * Whether the drawer starts open, for an uncontrolled one.
   *
   * Defaults to `false` in `overlay` mode and `true` in `inline` mode, because
   * a fixed sidebar that had to be opened before it appeared would not be a
   * fixed sidebar.
   */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * The element that opens the drawer, wired up by Base UI.
   *
   * `overlay` only. An `inline` drawer is not opened — it is in the layout —
   * so a trigger there would have nothing to do and is not rendered.
   */
  trigger?: React.ReactElement;
  /** The heading. Rendered as the element that names the drawer. */
  title?: React.ReactNode;
  /** A line under the title, and the drawer's accessible description. */
  description?: React.ReactNode;
  /**
   * The bottom row, held against the foot of the panel while the body scrolls.
   * Laid out end-aligned, so a pair of buttons needs no wrapper of its own —
   * and `DrawerClose` is what makes one of them dismiss.
   */
  actions?: React.ReactNode;
  /**
   * Draws a hairline between the header, the body and the actions instead of
   * separating them with space. Worth turning on the moment the body scrolls:
   * the lines are what say the header stayed put.
   * @default false
   */
  dividers?: boolean;
  /**
   * Shows the × in the corner. On in `overlay` mode, where the panel has taken
   * the page and the way out should not have to be remembered; off in `inline`
   * mode, where a × that closes a fixed sidebar with nothing to reopen it is a
   * one-way door.
   */
  showClose?: boolean;
  /**
   * Which language the × is named in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * `closeLabel` writes the word out instead; this is for the far more common
   * case where the page already knows its own language.
   */
  locale?: string;
  /** Accessible name of the × button. Defaults to the `locale`'s word for it. */
  closeLabel?: string;
  /**
   * How far the panel reaches in from its edge: a **width** for `left` and
   * `right`, a **height** for `top` and `bottom`. Numbers are pixels.
   *
   * Left alone, a side panel takes the width its `size` implies and a top or
   * bottom panel is as tall as what is in it, up to 85% of the window.
   */
  extent?: number | string;
  /**
   * Rounds the two corners on the edge that faces the page — the top and bottom
   * of a side panel, the inner pair of a top or bottom one. The corners against
   * the window edge are always square, because a corner cut off something that
   * has no visible end is a corner cut off nothing.
   * @default true
   */
  rounded?: boolean;
  /**
   * Whether the page behind is taken away. `'trap-focus'` keeps the page
   * scrollable and clickable while still holding focus inside. `overlay` only.
   * @default true
   */
  modal?: boolean | 'trap-focus';
  /**
   * Whether pressing Escape or clicking the scrim closes the drawer. Turn it off
   * for the drawer that has to be answered — and then give it actions that
   * answer it, because there will be no other way out. `overlay` only.
   * @default true
   */
  dismissible?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

export type DrawerCloseProps = React.ComponentPropsWithoutRef<typeof BaseUIDialog.Close>;

/**
 * How wide a `left` or `right` panel is when nothing says otherwise.
 *
 * Its own ladder rather than Dialog's `maxWidth`, and deliberately narrower at
 * every step: a dialog is measured by how long a line of text is comfortable
 * inside it, and a drawer is measured by how much of the window it is willing
 * to take away from what it is a drawer *for*.
 *
 * A `top` or `bottom` panel has no entry here on purpose — its extent is its
 * content, capped at 85% of the window, because a bottom sheet holding three
 * rows should be three rows tall.
 */
const extentClasses: Record<NebaSize, string> = {
  xs: 'w-56',
  sm: 'w-64',
  md: 'w-80',
  lg: 'w-96',
  xl: 'w-[28rem]'
};

/**
 * The corners on the free edge, written out per side and per step because
 * Tailwind only ever sees class names that appear literally in the source.
 */
const roundedClasses: Record<NebaSide, Record<NebaSize, string>> = {
  left: {
    xs: 'rounded-r-(--neba-radius-xs)',
    sm: 'rounded-r-(--neba-radius-sm)',
    md: 'rounded-r-(--neba-radius-md)',
    lg: 'rounded-r-(--neba-radius-lg)',
    xl: 'rounded-r-(--neba-radius-xl)'
  },
  right: {
    xs: 'rounded-l-(--neba-radius-xs)',
    sm: 'rounded-l-(--neba-radius-sm)',
    md: 'rounded-l-(--neba-radius-md)',
    lg: 'rounded-l-(--neba-radius-lg)',
    xl: 'rounded-l-(--neba-radius-xl)'
  },
  top: {
    xs: 'rounded-b-(--neba-radius-xs)',
    sm: 'rounded-b-(--neba-radius-sm)',
    md: 'rounded-b-(--neba-radius-md)',
    lg: 'rounded-b-(--neba-radius-lg)',
    xl: 'rounded-b-(--neba-radius-xl)'
  },
  bottom: {
    xs: 'rounded-t-(--neba-radius-xs)',
    sm: 'rounded-t-(--neba-radius-sm)',
    md: 'rounded-t-(--neba-radius-md)',
    lg: 'rounded-t-(--neba-radius-lg)',
    xl: 'rounded-t-(--neba-radius-xl)'
  }
};

/**
 * The hairline on the free edge only. A border all round would draw a line
 * along the window's own edge, where there is nothing on the other side of it
 * to be separated from.
 */
const edgeClasses: Record<NebaSide, string> = {
  left: 'border-r',
  right: 'border-l',
  top: 'border-b',
  bottom: 'border-t'
};

/**
 * How an overlay drawer arrives: from the edge it is attached to.
 *
 * This is the one surface in the library that does not simply fade, and the
 * exception is the whole of what a drawer is. Every other floating surface
 * appears where it will stay — a menu at its trigger, a dialog in the middle of
 * a page somebody is already reading — so moving it drags text the reader's eye
 * is already on. A drawer has a *home*: `side` is a prop, the panel is pinned to
 * that edge, and until it opens it is not on the screen at all. Sliding it moves
 * nothing that was being read; fading it in throws away the only thing that
 * distinguishes it from a Dialog.
 *
 * The scrim behind it still fades, which is the pairing every platform uses: the
 * page dims while the sheet arrives.
 *
 * `translate` rather than the `transform` shorthand, for the reason the
 * `Animate*` effects use it — a caller's own `transform` on the same element
 * survives. The percentage is of the panel's own box, so it does not have to
 * know how wide it was made or how wide `extent` made it. `--neba-duration`
 * rather than the window ladder's 240ms, because that one is not zeroed under
 * `prefers-reduced-motion` and this is exactly the motion somebody turning that
 * on is asking not to see.
 */
const slideClasses = '[transition:translate_var(--neba-duration)_var(--neba-ease)]';

const slideFromClasses: Record<NebaSide, string> = {
  left: 'data-[starting-style]:[translate:-100%_0] data-[ending-style]:[translate:-100%_0]',
  right: 'data-[starting-style]:[translate:100%_0] data-[ending-style]:[translate:100%_0]',
  top: 'data-[starting-style]:[translate:0_-100%] data-[ending-style]:[translate:0_-100%]',
  bottom: 'data-[starting-style]:[translate:0_100%] data-[ending-style]:[translate:0_100%]'
};

/** Which end of the viewport the panel is pushed to, and along which axis. */
const viewportClasses: Record<NebaSide, string> = {
  left: 'flex-row justify-start',
  right: 'flex-row justify-end',
  top: 'flex-col justify-start',
  bottom: 'flex-col justify-end'
};

/**
 * The sheet.
 *
 * Opacity only, exactly as on Dialog. A drawer that slid in would be dragging
 * its own text across the screen for the length of the transition, and a panel
 * is nothing but text and controls — this is the case the no-transform rule was
 * written for, not the exception to it. What says the panel came from an edge is
 * that it is *attached* to one: square against the window, cut on the free side.
 */
const panelClasses = [
  surfaceClasses,
  'relative flex flex-col overflow-hidden',
  'text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[outline:none]'
].join(' ');

const overlayShadowClasses = '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]';
const inlineShadowClasses = '[box-shadow:var(--neba-plate-glass)]';

const backdropClasses = [
  'fixed inset-0 z-50 bg-(--neba-scrim)',
  '[backdrop-filter:blur(2px)]',
  popupFadeClasses
].join(' ');

/** The internal hairline: the same `--n-line` as the sheet's own edge. */
const dividerClasses = 'border-t [border-color:var(--n-line)]';

/** The × in the corner, shared by both modes. */
const closeButtonClasses = [
  'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-full text-(--neba-muted-fg)',
  '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
  '[transition:background-color_var(--neba-duration)_var(--neba-ease),color_var(--neba-duration)_var(--neba-ease)]',
  'hover:bg-(--n-soft) hover:text-(--neba-fg)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * Closes the drawer it is inside.
 *
 * Exported for `DialogClose`'s reason: an uncontrolled drawer has no `setOpen`
 * for its Cancel button to call. It is an `overlay` drawer's button — an
 * `inline` drawer is not a Base UI dialog and has nothing for this to talk to.
 *
 * `render` is Base UI's own escape hatch, so a real Neba button dismisses:
 * `<DrawerClose render={<Button variant="text">Cancel</Button>} />`.
 */
export const DrawerClose = BaseUIDialog.Close;

/**
 * A panel attached to one edge of the window.
 *
 * Two things in one component, because they are the same panel: `overlay` is the
 * drawer you open — a scrim, a focus trap, Escape — and `inline` is the drawer
 * that is simply part of the page. Everything else about them is identical,
 * which is exactly why they should not be two components a caller has to switch
 * between when a sidebar becomes a hamburger at a breakpoint.
 *
 * The sections are props rather than compound sub-components, as on Card and
 * Dialog: the arrangement is fixed — heading, description, body, actions — and
 * what a caller wants to decide is what goes in each slot. The body is the only
 * part that scrolls, so the heading and the actions stay put.
 *
 * In `overlay` mode Base UI owns everything hard about it: the focus trap, the
 * scroll lock, the `aria-labelledby` / `aria-describedby` wiring, restoring
 * focus to the trigger, and the inert page behind.
 */
export function Drawer(rawProps: DrawerProps) {
  const {
    side = 'left',
    mode = 'overlay',
    size = 'md',
    color = 'primary',
    density = 'default',
    open,
    defaultOpen,
    onOpenChange,
    trigger,
    title,
    description,
    actions,
    dividers = false,
    showClose,
    locale,
    closeLabel,
    extent,
    rounded = true,
    modal = true,
    dismissible = true,
    className,
    style,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density', 'locale']);

  const messages = useMessages(actionMessages, locale);
  const overlay = mode === 'overlay';
  const along = side === 'left' || side === 'right';
  const showCloseButton = showClose ?? overlay;

  const insetX = boxPaddingXClasses[density][size];
  const insetY = boxPaddingYClasses[density][size];
  // With dividers the lines have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead — the same trade Card makes.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(description);
  const hasActions = hasContent(actions);

  const sizeStyle =
    extent === undefined
      ? null
      : { [along ? 'width' : 'height']: typeof extent === 'number' ? `${extent}px` : extent };

  const panel = cx(
    panelClasses,
    sheetBodyClasses[size],
    edgeClasses[side],
    rounded ? roundedClasses[side][size] : '',
    overlay ? overlayShadowClasses : inlineShadowClasses,
    overlay ? `${slideClasses} ${slideFromClasses[side]}` : '',
    along
      ? `h-full max-w-full ${extent === undefined ? extentClasses[size] : ''}`
      : `w-full ${extent === undefined ? 'max-h-[85%]' : ''}`,
    dividers ? '' : `${insetY} ${sheetSectionGapClasses[size]}`,
    className ?? ''
  );

  // Base UI's parts carry the `aria-labelledby` / `aria-describedby` wiring an
  // overlay drawer needs. An inline one is not a dialog and needs none, so it
  // gets the plain tags rather than a dialog's parts outside a dialog.
  const TitleTag = overlay ? BaseUIDialog.Title : 'h2';
  const DescriptionTag = overlay ? BaseUIDialog.Description : 'p';

  const contents = (
    <>
      {hasHeader || showCloseButton ? (
        <div className={`flex shrink-0 items-start gap-3 ${sectionClasses}`}>
          <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
            {hasContent(title) ? (
              <TitleTag className={`m-0 font-semibold ${sheetTitleClasses[size]}`}>
                {title}
              </TitleTag>
            ) : null}
            {hasContent(description) ? (
              <DescriptionTag className={`m-0 text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
                {description}
              </DescriptionTag>
            ) : null}
          </div>

          {showCloseButton ? (
            overlay ? (
              <BaseUIDialog.Close
                aria-label={closeLabel ?? messages.close}
                className={closeButtonClasses}
              >
                <CloseIcon />
              </BaseUIDialog.Close>
            ) : (
              <button
                type="button"
                aria-label={closeLabel ?? messages.close}
                className={closeButtonClasses}
                onClick={() => onOpenChange?.(false)}
              >
                <CloseIcon />
              </button>
            )
          ) : null}
        </div>
      ) : null}

      {hasContent(children) ? (
        // The only part that scrolls. `min-h-0` is what lets it: a flex item's
        // default `min-height: auto` refuses to shrink below its content, and
        // the panel would grow past the window instead.
        <div
          className={cx(
            'min-h-0 flex-1 overflow-y-auto overscroll-contain',
            sectionClasses,
            dividers && (hasHeader || showCloseButton) ? dividerClasses : '',
            // A scroll container clips at its padding box and a focus ring is
            // drawn outside the control that owns it, so a field at the top or
            // bottom of an unruled body would have its ring sliced off. The
            // padding is room for the ring and the negative margin hands the
            // space straight back, so nothing on the sheet moves.
            dividers ? '' : 'py-1 -my-1'
          )}
        >
          {children}
        </div>
      ) : null}

      {hasActions ? (
        <div
          className={cx(
            'flex shrink-0 flex-wrap items-center justify-end gap-2',
            sectionClasses,
            dividers ? dividerClasses : ''
          )}
        >
          {actions}
        </div>
      ) : null}
    </>
  );

  if (!overlay) {
    // An inline drawer is in the flow, so "closed" is "not in the layout".
    // There is nothing to animate on the way out: the page around it is what
    // moves, and moving the page is not this component's to do.
    if (!(open ?? defaultOpen ?? true)) {
      return null;
    }

    return (
      <div
        className={panel}
        style={{ ...surfaceSlots(color, 0), ...sizeStyle, ...style }}
        // The same spread the overlay panel gets, in the same place. It was
        // missing here, so `id`, `data-*`, `aria-*` and every other attribute a
        // caller wrote reached the panel in one mode and were dropped on the
        // floor in the other — and the mode is exactly what a Sidebar swaps at a
        // breakpoint, so the same drawer lost them by being on a narrow screen.
        {...props}
      >
        {contents}
      </div>
    );
  }

  return (
    <BaseUIDialog.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      disablePointerDismissal={!dismissible}
      onOpenChange={(next, details) => {
        // `disablePointerDismissal` covers the click on the scrim; Escape has no
        // prop of its own, so it is cancelled here by the reason it arrives with.
        if (!dismissible && !next && details.reason === 'escape-key') {
          details.cancel();
          return;
        }
        onOpenChange?.(next);
      }}
    >
      {trigger ? <BaseUIDialog.Trigger render={trigger} /> : null}

      <BaseUIDialog.Portal>
        {/* `neba-portal` is a hook, not a style: a portalled surface leaves the
            subtree a host may have scoped its CSS reset to. */}
        <BaseUIDialog.Backdrop className={`neba-portal ${backdropClasses}`} />

        <BaseUIDialog.Viewport
          className={`neba-portal fixed inset-0 z-50 flex ${viewportClasses[side]}`}
        >
          <BaseUIDialog.Popup
            className={panel}
            style={{ ...surfaceSlots(color, 3), ...sizeStyle, ...style }}
            {...props}
          >
            {contents}
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}

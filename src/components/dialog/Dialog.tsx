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
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { NebaSize, NebaSlots, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * The parts a Dialog draws around its popup.
 *
 * `className` is the popup — the sheet itself — which is the one element a
 * caller means by "the dialog". Everything named here sits either outside it
 * (`backdrop`, `viewport`) or inside it (the rest).
 *
 * The first two are the ones that could not be reached any other way: both
 * render at the end of `<body>`, outside the popup, so no selector written
 * against the sheet finds them.
 */
export type DialogSlot =
  'backdrop' | 'viewport' | 'title' | 'description' | 'close' | 'body' | 'actions';

/**
 * A dialog takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`: the three weights answer "how much does this surface
 * assert itself against the page around it", and a modal has already taken the
 * page. There is no `elevation` either — see `popupClasses`.
 */
export interface DialogProps
  extends
    Pick<NebaStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /** The dialog is shown. Use with `onOpenChange` for a controlled dialog. */
  open?: boolean;
  /** Whether the dialog starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * The element that opens the dialog, wired up by Base UI. Optional — a
   * controlled dialog opened from somewhere else in the app needs no trigger at
   * all, and passing one here is only a convenience for the common case.
   */
  trigger?: React.ReactElement;
  /** The heading. Rendered as the `<h2>` that names the dialog. */
  title?: React.ReactNode;
  /** A line under the title, and the dialog's accessible description. */
  description?: React.ReactNode;
  /**
   * The bottom row. Laid out end-aligned, so a pair of buttons needs no wrapper
   * of its own — and `DialogClose` is what makes one of them dismiss.
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
   * Shows the × in the corner.
   *
   * On by default, unlike most booleans in the library. A modal dialog takes the
   * page away until it is answered, and the visible way out should not have to
   * be remembered.
   * @default true
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
   * A hard cap on the sheet's width, overriding the one `size` implies. Numbers
   * are pixels. For the dialog whose content decides its width — a wide table,
   * a narrow confirmation — rather than for tuning the scale, which is `size`.
   */
  width?: number | string;
  /**
   * The sheet takes the full width its `size` allows.
   *
   * On by default, which is the other way round from every other component.
   * Elsewhere `fullWidth` means "fill the container"; a dialog's container is
   * the viewport, and a dialog that shrank to fit two words would be a tooltip.
   * @default true
   */
  fullWidth?: boolean;
  /** Fills the viewport edge to edge. For a mobile-sized screen, or an editor. */
  fullScreen?: boolean;
  /**
   * Whether the page behind is taken away. `'trap-focus'` keeps the page
   * scrollable and clickable while still holding focus inside.
   * @default true
   */
  modal?: boolean | 'trap-focus';
  /**
   * Whether pressing Escape or clicking outside closes the dialog. Turn it off
   * for the dialog that has to be answered — and then give it actions that
   * answer it, because there will be no other way out.
   * @default true
   */
  dismissible?: boolean;
  /**
   * Class names for the parts around the popup. `className` is the popup — the
   * sheet — so the scrim behind it is `classNames.backdrop`.
   */
  classNames?: NebaSlots<DialogSlot>;
  /** The body. */
  children?: React.ReactNode;
}

export type DialogCloseProps = React.ComponentPropsWithoutRef<typeof BaseUIDialog.Close>;

/**
 * How wide the sheet is allowed to get, per `size`.
 *
 * `size` and the width are one axis here rather than the two MUI splits them
 * into. A second five-value scale spelled `maxWidth` would be a second spelling
 * of an idea the library already has a word for, and the case it exists for —
 * "small type, wide sheet" — is what the `width` escape hatch is.
 *
 * The steps are wider apart than the control ladder because they are answering
 * a different question: not how big is this thing, but how long a line of text
 * is comfortable inside it.
 */
const maxWidthClasses: Record<NebaSize, string> = {
  xs: 'max-w-80',
  sm: 'max-w-96',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl'
};

/**
 * The sheet, and the one surface in the library besides the Select popup that
 * is *supposed* to float — so unlike everything else it carries a shadow by
 * default, at level 3, which is as far as the scale goes without hovering.
 *
 * There is no `elevation` prop for the same reason: a dialog that could be told
 * to sit flat on the page would be a dialog that could be told to stop being a
 * dialog.
 */
const popupClasses = [
  surfaceClasses,
  'relative flex w-full flex-col overflow-hidden',
  'border text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  // Opacity only. A dialog that scales or slides in drags its own text across
  // the screen for 200ms, which is the exact thing the house style is against —
  // and unlike a control, this one is full of text.
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const backdropClasses = [
  'fixed inset-0 z-50 bg-(--neba-scrim)',
  '[backdrop-filter:blur(2px)]',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/** The internal hairline: the same `--n-line` as the sheet's own edge. */
const dividerClasses = 'border-t [border-color:var(--n-line)]';

/**
 * Closes the dialog it is inside.
 *
 * Exported because an uncontrolled dialog has no `setOpen` for its Cancel
 * button to call, and the alternative — making every dialog controlled — is a
 * piece of state per dialog that exists only to answer a button.
 *
 * `render` is Base UI's own escape hatch, so a real Neba button dismisses:
 * `<DialogClose render={<Button variant="text">Cancel</Button>} />`.
 */
export const DialogClose = BaseUIDialog.Close;

/**
 * A sheet that takes the page away until it is answered.
 *
 * The sections are props rather than compound sub-components, exactly as they
 * are on Card: the arrangement of a dialog is fixed — heading, description,
 * body, actions — and what a caller wants to decide is what goes in each slot.
 * Base UI owns everything hard about it: the focus trap, the scroll lock, the
 * `aria-labelledby` / `aria-describedby` wiring, restoring focus to the trigger,
 * and the inert page behind.
 *
 * What is left here is the surface, the width ladder and the scroll behaviour —
 * the header and the actions stay put while only the body scrolls, which is why
 * `dividers` matters more here than on a Card.
 */
export function Dialog(rawProps: DialogProps) {
  const {
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
    showClose = true,
    locale,
    closeLabel,
    width,
    fullWidth = true,
    fullScreen = false,
    modal = true,
    dismissible = true,
    className,
    classNames,
    style,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density', 'locale']);

  const messages = useMessages(actionMessages, locale);
  const insetX = boxPaddingXClasses[density][size];
  const insetY = boxPaddingYClasses[density][size];
  // With dividers the lines have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead — the same trade Card makes.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(description);
  const hasActions = hasContent(actions);

  return (
    <BaseUIDialog.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      disablePointerDismissal={!dismissible}
      onOpenChange={(next, details) => {
        // `disablePointerDismissal` covers the click outside; Escape has no prop
        // of its own, so it is cancelled here by the reason it arrives with.
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
        <BaseUIDialog.Backdrop
          className={cx('neba-portal', backdropClasses, classNames?.backdrop)}
        />

        <BaseUIDialog.Viewport
          className={cx(
            'neba-portal fixed inset-0 z-50 flex justify-center',
            // `items-center` alone would clip the top of a dialog taller than
            // the viewport, because a centred flex item cannot scroll past its
            // own container's start edge. The popup caps its height instead and
            // scrolls its body, so the header and the actions stay put.
            fullScreen ? 'items-stretch' : 'items-center p-4',
            classNames?.viewport
          )}
        >
          <BaseUIDialog.Popup
            className={cx(
              popupClasses,
              sheetBodyClasses[size],
              fullScreen
                ? 'h-full max-w-none rounded-none'
                : `max-h-full ${radiusClasses[size]} ${width === undefined ? maxWidthClasses[size] : ''}`,
              !fullScreen && !fullWidth ? 'w-auto' : '',
              dividers ? '' : `${insetY} ${sheetSectionGapClasses[size]}`,
              className ?? ''
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(width === undefined
                ? null
                : { maxWidth: typeof width === 'number' ? `${width}px` : width }),
              ...style
            }}
            {...props}
          >
            {hasHeader || showClose ? (
              <div className={`flex shrink-0 items-start gap-3 ${sectionClasses}`}>
                <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
                  {hasContent(title) ? (
                    <BaseUIDialog.Title
                      className={cx(
                        'font-semibold',
                        sheetTitleClasses[size],
                        'm-0',
                        classNames?.title
                      )}
                    >
                      {title}
                    </BaseUIDialog.Title>
                  ) : null}
                  {hasContent(description) ? (
                    <BaseUIDialog.Description
                      className={cx(
                        'm-0 text-(--neba-muted-fg)',
                        metaTextClasses[size],
                        classNames?.description
                      )}
                    >
                      {description}
                    </BaseUIDialog.Description>
                  ) : null}
                </div>

                {showClose ? (
                  <BaseUIDialog.Close
                    aria-label={closeLabel ?? messages.close}
                    className={cx(
                      'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
                      'rounded-full text-(--neba-muted-fg)',
                      '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
                      '[transition:background-color_var(--neba-duration)_var(--neba-ease),color_var(--neba-duration)_var(--neba-ease)]',
                      'hover:bg-(--n-soft) hover:text-(--neba-fg)',
                      'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
                      classNames?.close
                    )}
                  >
                    <CloseIcon />
                  </BaseUIDialog.Close>
                ) : null}
              </div>
            ) : null}

            {hasContent(children) ? (
              // The only part that scrolls. `min-h-0` is what lets it: a flex
              // item's default `min-height: auto` refuses to shrink below its
              // content, and the sheet would grow past the viewport instead.
              <div
                className={cx(
                  'min-h-0 flex-1 overflow-y-auto overscroll-contain',
                  sectionClasses,
                  dividers && (hasHeader || showClose) ? dividerClasses : '',
                  // A scroll container clips at its padding box, and a focus
                  // ring is drawn 4px outside the control that owns it — so a
                  // field at the top or bottom of an unruled body had its ring
                  // sliced off. The padding is room for the ring and the
                  // negative margin hands the space straight back, so nothing
                  // on the sheet moves. Only without `dividers`: with them the
                  // body already carries `insetY`, and pulling it up would drag
                  // the rule into the section above.
                  dividers ? '' : 'py-1 -my-1',
                  classNames?.body
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
                  dividers ? dividerClasses : '',
                  classNames?.actions
                )}
              >
                {actions}
              </div>
            ) : null}
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}

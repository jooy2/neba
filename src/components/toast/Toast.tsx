'use client';

import * as React from 'react';
import { Toast as BaseUIToast } from '@base-ui/react/toast';
import { boxPaddingClasses } from '../box/Box.js';
import { actionMessages, useMessages } from '../../internal/i18n.js';
import { CloseIcon, severityIcon } from '../../internal/icons.js';
import {
  controlSlots,
  cx,
  focusRingClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceClasses
} from '../../internal/styles.js';
import type {
  NebaAlign,
  NebaColor,
  NebaSize,
  NebaSlots,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';

/**
 * Where the stack sits.
 *
 * Written as two words rather than as a `side` plus an `align` pair, because
 * they are not independent: a toast stack is always pinned to the top or the
 * bottom, never to a side, and offering `left`/`right` as a "side" would invite
 * a stack down the middle of the screen that nothing in the layout survives.
 * The second half is `NebaAlign`, the same word every other component uses.
 */
export type ToastPosition = `top-${NebaAlign}` | `bottom-${NebaAlign}`;

/**
 * The Neba style props a single toast can override, carried in Base UI's
 * per-toast `data`. Anything not set here falls back to the provider.
 */
export interface ToastData {
  color?: NebaColor;
  variant?: NebaVariant;
  icon?: React.ReactNode | false;
}

export interface ToastOptions extends ToastData {
  /**
   * Reusing an id updates that toast in place and restarts its timer, which is
   * what "uploading… / uploaded" wants: one toast that changed its mind, not two
   * stacked on each other.
   */
  id?: string;
  /** The headline. */
  title?: React.ReactNode;
  /** The detail under it. A toast with only this is a one-line toast. */
  description?: React.ReactNode;
  /**
   * How long before it dismisses itself, in milliseconds. `0` means it stays
   * until it is closed — which is the right answer for anything the reader has
   * to act on, because a toast that leaves before it is read said nothing.
   */
  timeout?: number;
  /**
   * `high` interrupts a screen reader; `low` waits for a pause. An error is
   * worth interrupting for and a save confirmation is not.
   * @default 'low'
   */
  priority?: 'low' | 'high';
  /** The label of the action button. Passing it is what makes the button appear. */
  actionLabel?: React.ReactNode;
  onAction?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /** Called when the toast closes, however it closed. */
  onClose?: () => void;
  /** Called once it has finished animating out and left the DOM. */
  onRemove?: () => void;
}

/**
 * The parts the toast stack draws.
 *
 * There is no `className` on the provider and there is deliberately no `root`
 * slot: a ToastProvider renders no element of its own — it wraps the app and
 * puts a portalled stack on the page — so there is nothing for a root class
 * name to land on. `viewport` is the strip the toasts are stacked in and
 * `toast` is one of them.
 */
export type ToastSlot = 'viewport' | 'toast' | 'title' | 'description' | 'action' | 'close';

export interface ToastProviderProps extends Pick<NebaStyleProps, 'variant' | 'size' | 'density'> {
  /** The default colour family. A single toast overrides it in `add`. */
  color?: NebaColor;
  /** @default 'bottom-end' */
  position?: ToastPosition;
  /**
   * How long a toast lasts by default, in milliseconds. `0` keeps every toast
   * up until it is closed.
   * @default 5000
   */
  timeout?: number;
  /**
   * How many are shown at once. The rest are kept and revealed as the stack
   * drains rather than being thrown away.
   * @default 3
   */
  limit?: number;
  /** How wide a toast is allowed to get. Numbers are pixels. @default 380 */
  width?: number | string;
  /**
   * Which language every toast's × is named in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * `closeLabel` write the words out instead; this is for the far more common
   * case where the page already knows its own language.
   */
  locale?: string;
  /** Accessible name of every toast's × button. Defaults to the `locale`'s word. */
  closeLabel?: string;
  /**
   * Class names for the parts of the stack. There is no `className` here — a
   * provider renders no element of its own to put one on.
   */
  classNames?: NebaSlots<ToastSlot>;
  children?: React.ReactNode;
}

/**
 * How a stack is pinned, per position.
 *
 * The viewport is full width in every case and the alignment is done with
 * `items-*`, rather than by pinning one edge and nudging the centre back with a
 * translate. That keeps the one transform this component could have wanted out
 * of it, and it means the same three classes serve all six positions.
 */
const viewportClasses: Record<ToastPosition, string> = {
  'top-start': 'top-0 items-start',
  'top-center': 'top-0 items-center',
  'top-end': 'top-0 items-end',
  'bottom-start': 'bottom-0 items-start flex-col-reverse',
  'bottom-center': 'bottom-0 items-center flex-col-reverse',
  'bottom-end': 'bottom-0 items-end flex-col-reverse'
};

/**
 * A toast floats over the page, so unlike everything else it carries a shadow
 * by default — level 3, the same as the Select popup and the Dialog.
 */
const rootClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--neba-shadow-3),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel-press)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]'
  ].join(' '),
  text: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-press)',
    '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]'
  ].join(' ')
};

const accentClasses: Record<NebaVariant, string> = {
  solid: '',
  outline: 'text-(--n-accent)',
  text: 'text-(--n-accent)'
};

/**
 * Turns a Neba toast into the object Base UI's manager stores.
 *
 * The style props go into `data` rather than becoming top-level fields, because
 * `data` is the slot Base UI reserves for exactly this and the alternative —
 * shadowing the manager's own option names — is how a library ends up with two
 * `type` props that mean different things.
 */
function toManagerOptions(options: ToastOptions) {
  const { color, variant, icon, actionLabel, onAction, ...rest } = options;

  return {
    ...rest,
    data: { color, variant, icon } satisfies ToastData,
    actionProps:
      actionLabel === undefined
        ? undefined
        : { children: actionLabel, onClick: onAction as React.MouseEventHandler<HTMLButtonElement> }
  };
}

/**
 * Raises toasts from anywhere under a `ToastProvider`.
 *
 * A hook rather than a component, because the thing a caller has at the moment
 * a toast is warranted is a click handler, not a place in the tree — and a
 * `<Toast open={…}/>` they would have to keep mounted, with a piece of state per
 * message, is the shape this component exists to avoid.
 */
export function useToast() {
  const manager = BaseUIToast.useToastManager<ToastData>();

  return React.useMemo(
    () => ({
      /** Raises a toast and returns its id. */
      add: (options: ToastOptions) => manager.add(toManagerOptions(options)),
      /** Closes one toast, or every toast when called with nothing. */
      close: (id?: string) => manager.close(id),
      /** Changes a toast already on screen. */
      update: (id: string, options: ToastOptions) => manager.update(id, toManagerOptions(options)),
      /**
       * One toast that follows a promise: the loading message while it runs,
       * then the success or the error. `timeout: 0` is applied to the loading
       * state by Base UI, so a slow request cannot dismiss its own toast.
       */
      promise: <Value,>(
        promise: Promise<Value>,
        options: {
          loading: ToastOptions;
          success: ToastOptions | ((value: Value) => ToastOptions);
          error: ToastOptions | ((error: unknown) => ToastOptions);
        }
      ) =>
        manager.promise(promise, {
          loading: toManagerOptions(options.loading),
          success: (value: Value) =>
            toManagerOptions(
              typeof options.success === 'function' ? options.success(value) : options.success
            ),
          error: (error: unknown) =>
            toManagerOptions(
              typeof options.error === 'function' ? options.error(error) : options.error
            )
        }),
      /** Every toast currently in the stack, newest first. */
      toasts: manager.toasts
    }),
    [manager]
  );
}

interface ToastItemProps extends Pick<ToastProviderProps, 'variant' | 'size' | 'density'> {
  toast: BaseUIToast.Root.ToastObject<ToastData>;
  color: NebaColor;
  size: NebaSize;
  closeLabel: string;
  /** Which way it can be flicked away, derived from where the stack is pinned. */
  swipeDirection: ('up' | 'down' | 'left' | 'right')[];
  classNames?: NebaSlots<ToastSlot>;
}

function ToastItem({
  toast,
  variant: providerVariant,
  color: providerColor,
  size,
  density,
  closeLabel,
  swipeDirection,
  classNames
}: ToastItemProps) {
  const variant = toast.data?.variant ?? providerVariant ?? 'outline';
  const color = toast.data?.color ?? providerColor;
  const glyph = toast.data?.icon === undefined ? severityIcon(color) : toast.data.icon;
  const accent = accentClasses[variant];
  const titled = hasContent(toast.title);

  return (
    <BaseUIToast.Root
      toast={toast}
      swipeDirection={swipeDirection}
      className={cx(
        'pointer-events-auto flex w-full items-start',
        boxPaddingClasses[density ?? 'default'][size],
        radiusClasses[size],
        sheetSectionGapClasses[size],
        sheetBodyClasses[size],
        rootClasses[variant],
        iconClasses,
        // Opacity, and only opacity — the same restraint the Dialog shows, and
        // for the same reason: this is a box full of text. Base UI still moves
        // it while a finger is dragging it, which is the reader's hand rather
        // than a state change, and it stops the moment the finger lifts.
        '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
        'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0',
        // A toast pushed out by the limit is kept in the DOM so it can come
        // back; it just has nothing to say while it waits.
        'data-[limited]:hidden',
        focusRingClasses,
        '[outline:none]',
        classNames?.toast
      )}
      style={controlSlots(color, 3, variant)}
    >
      {hasContent(glyph) ? (
        <span className={`flex h-[1lh] shrink-0 items-center ${accent}`}>{glyph}</span>
      ) : null}

      <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
        <BaseUIToast.Title
          className={cx(
            'neba-title font-semibold',
            sheetTitleClasses[size],
            accent,
            classNames?.title
          )}
        />
        <BaseUIToast.Description
          className={cx(
            titled && variant !== 'solid' ? 'text-(--neba-muted-fg)' : '',
            classNames?.description
          )}
        />
      </div>

      <BaseUIToast.Action
        className={cx(
          'flex h-[1lh] shrink-0 cursor-pointer items-center rounded-full px-2',
          'font-medium underline-offset-2',
          accent || 'text-(--n-on-solid)',
          'hover:underline',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
          metaTextClasses[size],
          classNames?.action
        )}
      />

      <span className="flex h-[1lh] shrink-0 items-center">
        <BaseUIToast.Close
          aria-label={closeLabel}
          className={cx(
            'inline-flex size-[1.15em] cursor-pointer items-center justify-center rounded-full',
            'opacity-70 [transition:opacity_var(--neba-duration)_var(--neba-ease)]',
            'hover:opacity-100 focus-visible:opacity-100',
            'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
            classNames?.close
          )}
        >
          <CloseIcon />
        </BaseUIToast.Close>
      </span>
    </BaseUIToast.Root>
  );
}

/** The stack itself. Rendered by the provider, never by a caller. */
function ToastViewport(
  props: Required<Pick<ToastProviderProps, 'position' | 'size' | 'width'>> &
    Pick<ToastProviderProps, 'variant' | 'density' | 'classNames'> & {
      color: NebaColor;
      closeLabel: string;
    }
) {
  const { toasts } = BaseUIToast.useToastManager<ToastData>();
  const { position, width, classNames, ...rest } = props;

  // One array rather than a fresh one per render. Every toast on screen is
  // handed it, and a new identity each time is a new prop each time on every
  // one of them.
  const swipeDirection = React.useMemo<('up' | 'down' | 'left' | 'right')[]>(
    () => [position.startsWith('top') ? 'up' : 'down', 'left', 'right'],
    [position]
  );

  return (
    <BaseUIToast.Portal>
      {/* `neba-portal` is a hook, not a style: a portalled surface leaves the
          subtree a host may have scoped its CSS reset to. */}
      <BaseUIToast.Viewport
        className={cx(
          // Full width and `pointer-events-none`, so the strip across the top or
          // the bottom of the page is not a wall the rest of the app is behind.
          // The toasts themselves take their events back.
          'neba-portal pointer-events-none fixed inset-x-0 z-50 flex flex-col gap-2 p-4',
          viewportClasses[position],
          classNames?.viewport
        )}
      >
        {toasts.map((toast) => (
          <div
            key={toast.id}
            className="w-full"
            style={{ maxWidth: typeof width === 'number' ? `${width}px` : width }}
          >
            <ToastItem
              toast={toast}
              swipeDirection={swipeDirection}
              classNames={classNames}
              {...rest}
            />
          </div>
        ))}
      </BaseUIToast.Viewport>
    </BaseUIToast.Portal>
  );
}

/**
 * Puts the toast stack on the page and lets anything under it raise a message.
 *
 * Wrap the application once. Everything about how a toast *looks* is decided
 * here — where the stack sits, how wide it is, which surface it wears, how long
 * it lasts — so the call site stays the one thing it should be: what happened.
 *
 * Base UI owns the parts of this that are genuinely hard and invisible when
 * they work: the timers and their pausing on hover and on window blur, the
 * limit, the swipe, the F6 focus hotkey, and the live region that makes a
 * message that appeared out of nowhere reach a screen reader at all.
 */
export function ToastProvider({
  variant = 'outline',
  size = 'md',
  color = 'primary',
  density = 'default',
  position = 'bottom-end',
  timeout = 5000,
  limit = 3,
  width = 380,
  locale,
  closeLabel,
  classNames,
  children
}: ToastProviderProps) {
  const messages = useMessages(actionMessages, locale);

  return (
    <BaseUIToast.Provider timeout={timeout} limit={limit}>
      {children}
      <ToastViewport
        position={position}
        variant={variant}
        size={size}
        color={color}
        density={density}
        width={width}
        closeLabel={closeLabel ?? messages.close}
        classNames={classNames}
      />
    </BaseUIToast.Provider>
  );
}

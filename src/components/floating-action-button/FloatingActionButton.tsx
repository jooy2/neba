'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { CloseIcon, PlusIcon } from '../../internal/icons.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaCorner,
  NebaDensity,
  NebaElevation,
  NebaPosition,
  NebaSize,
  NebaSlots,
  NebaStyleProps,
  NebaVariant
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * Where a floating button sits, with one value the shared vocabulary does not
 * have.
 *
 * `absolute` is not a second spelling of anything in `NebaPosition` — it is the
 * fourth CSS value, and it is the one that makes a floating button belong to a
 * *region* rather than to the window: a FAB in a card, in a map, on the screen
 * of a Mockup. Without it, the only way to pin one inside a box is a wrapper
 * with a `position` of its own.
 */
export type FloatingActionButtonPosition = NebaPosition | 'absolute';

/**
 * Which way the actions fan out from the button.
 *
 * Physical rather than logical, for the reason `NebaSide` gives: above is above
 * in every writing direction. The horizontal axis is deliberately not offered —
 * a dial that fans sideways out of a corner fans into the edge of the screen.
 */
export type FloatingActionButtonDirection = 'top' | 'bottom';

/** What an action inherits from the button it fans out of. */
interface FloatingActionContextValue {
  variant: NebaVariant;
  size: NebaSize;
  color: NebaColor;
  density: NebaDensity;
  elevation: NebaElevation;
  showLabels: boolean;
  reversed: boolean;
  close: () => void;
  /** Whether pressing an action closes the dial, and so takes the action away. */
  closesOnAction: boolean;
  /** Puts the focus back on the button the dial came out of. */
  focusTrigger: () => void;
}

const FloatingActionContext = React.createContext<FloatingActionContextValue>({
  variant: 'solid',
  size: 'md',
  color: 'primary',
  density: 'default',
  elevation: 1,
  showLabels: true,
  reversed: true,
  close: () => {},
  closesOnAction: false,
  focusTrigger: () => {}
});

/**
 * The parts of a FloatingActionButton a `classNames` entry can reach. `className`
 * and `style` are the button's; `frame` is the box pinned to the corner, which
 * holds the button and its dial.
 */
export type FloatingActionButtonSlot = 'frame';

export interface FloatingActionButtonProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'onClick'> {
  /** The glyph on the button. @default a plus */
  icon?: React.ReactNode;
  /** Classes for the box pinned to the corner. `className` goes on the button itself. */
  classNames?: NebaSlots<FloatingActionButtonSlot>;
  /**
   * What the button does, in words.
   *
   * Required, and the one prop here that is: a button whose whole label is a
   * drawing has no accessible name at all. With `extended` it is also the word
   * written on the button, so the two never say different things.
   */
  label: string;
  /**
   * Writes `label` beside the glyph, which turns the disc into a stadium — the
   * extended floating button, for the one action a screen is about.
   * @default false
   */
  extended?: boolean;
  /**
   * The glyph while the dial is open. Defaults to a × when the button has
   * actions and to nothing at all when it does not; pass the same node as
   * `icon` to keep the glyph unchanged.
   */
  openIcon?: React.ReactNode;
  /**
   * Drop shadow depth. `2` here, against the `0` everything else defaults to,
   * for the reason Pill's is `2`: this button is defined by not being part of
   * the page. Every other control rests on the page and earns its separation
   * from the acrylic edge; this one hovers over whatever is underneath it.
   * @default 2
   */
  elevation?: NebaElevation;
  /**
   * How it sits in the page. `fixed` — the default — pins it to a corner of the
   * window; `absolute` pins it to a corner of the nearest positioned ancestor;
   * `static` puts it back in the flow, which is what a floating button inside a
   * Toolbar is.
   * @default 'fixed'
   */
  position?: FloatingActionButtonPosition;
  /** Which corner it is pinned to. @default 'bottom-end' */
  corner?: NebaCorner;
  /**
   * How far in from both edges, as a CSS length or a number of pixels.
   * @default 16
   */
  offset?: number | string;
  /**
   * Adds the screen's `env(safe-area-inset-*)` to `offset` on the edge the
   * corner is against, so a button pinned to the bottom of a phone clears its
   * home indicator. Only a `fixed` or `sticky` button is ever against that edge.
   * @default true
   */
  safeArea?: boolean;
  /**
   * Which way the actions fan out. Taken from `corner` when it is left out — up
   * from the bottom of the screen, down from the top — which is right often
   * enough that it is rarely written down.
   */
  direction?: FloatingActionButtonDirection;
  /** Whether the dial is open. Use with `onOpenChange` for a controlled dial. */
  open?: boolean;
  /** Where an uncontrolled dial starts. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Opens the dial when a mouse comes to rest on the button. Touch and pen are
   * excluded: there is no hovering with a finger, and a dial that opened on the
   * first half of a tap would swallow the second.
   * @default true
   */
  openOnHover?: boolean;
  /**
   * Closes the dial when one of the actions is pressed.
   * @default true
   */
  closeOnAction?: boolean;
  /**
   * Draws each action's name on a lozenge beside it. Turned off, the names are
   * still read out — they are what `label` is on a FloatingAction.
   * @default true
   */
  showLabels?: boolean;
  /** Unavailable. The button and every action stop answering. */
  disabled?: boolean;
  /**
   * Fires when the button itself is pressed. It still fires when the button has
   * actions, where the press also opens and closes the dial.
   */
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  /** The FloatingActions, if there are any. */
  children?: React.ReactNode;
}

export interface FloatingActionProps extends Omit<
  React.ComponentPropsWithoutRef<'button'>,
  'color'
> {
  /** The glyph. */
  icon?: React.ReactNode;
  /** What the action does, in words. Drawn beside it, and always read out. */
  label: string;
  /** Unavailable, but still part of the dial. */
  disabled?: boolean;
}

/**
 * An action is one step down the ladder from the button it came out of, so the
 * thing that was pressed stays the largest object in the corner.
 *
 * `xs` has nowhere lower to go and stays where it is: a dial of half-size `xs`
 * buttons would be a row of targets too small to hit.
 */
const actionSizes: Record<NebaSize, NebaSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'md',
  xl: 'lg'
};

/**
 * A floating button starts a step up the ladder.
 *
 * Not a change to the ladder — `lg` is the same 40px it is on a Button — but a
 * different place to start on it, the same way Pill starts at `elevation` 2.
 * This is the one control on a screen that has to be found and hit with a thumb
 * without being looked at.
 */
const defaultSize: NebaSize = 'lg';

const positionClasses: Record<FloatingActionButtonPosition, string> = {
  static: '',
  absolute: 'absolute z-30',
  sticky: 'sticky z-30',
  fixed: 'fixed z-40'
};

/** The two insets a corner is, read off a slot so `offset` is written once. */
const cornerClasses: Record<NebaCorner, string> = {
  'top-start': 'top-(--n-fab-offset) start-(--n-fab-offset)',
  'top-end': 'top-(--n-fab-offset) end-(--n-fab-offset)',
  'bottom-start': 'bottom-(--n-fab-offset) start-(--n-fab-offset)',
  'bottom-end': 'bottom-(--n-fab-offset) end-(--n-fab-offset)'
};

/** The same corners, with the screen's inset added on the edge each is against. */
const safeCornerClasses: Record<NebaCorner, string> = {
  'top-start': 'top-[calc(var(--n-fab-offset)_+_env(safe-area-inset-top))] start-(--n-fab-offset)',
  'top-end': 'top-[calc(var(--n-fab-offset)_+_env(safe-area-inset-top))] end-(--n-fab-offset)',
  'bottom-start':
    'bottom-[calc(var(--n-fab-offset)_+_env(safe-area-inset-bottom))] start-(--n-fab-offset)',
  'bottom-end':
    'bottom-[calc(var(--n-fab-offset)_+_env(safe-area-inset-bottom))] end-(--n-fab-offset)'
};

/**
 * The lozenge an action's name is written on.
 *
 * The same frosted acrylic every other surface is cut from, at one elevation so
 * it reads as sitting on the page beside the button rather than on it.
 */
const actionLabelClasses = cx(
  'pointer-events-none max-w-40 truncate select-none',
  'px-2 py-0.5 text-(--neba-fg) bg-(--n-panel)',
  surfaceClasses,
  radiusClasses.xs,
  '[box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]'
);

/**
 * The one action a screen is about, floating over it — and, when it is given
 * children, the small set of actions that fan out of it.
 *
 * The button itself is a [Button], unchanged: the variants, the elevation
 * ladder, the pointer light and the press behaviour are the ones every other
 * control has, because two components drawing the same surface from two copies
 * of the same table are two components that will eventually disagree. What is
 * added here is where it sits and what comes out of it.
 *
 * The dial is deliberately not a menu. `role="menu"` is a promise about keyboard
 * behaviour — one tab stop for the set, arrow keys within it, typeahead — and a
 * fan of buttons that claims it without implementing it is worse for a keyboard
 * reader than one that never claimed anything; what a genuine menu wants is
 * [Menu], which is one. What is claimed instead is `aria-expanded` and
 * `aria-controls`, and the actions are ordinary buttons in the tab order right
 * after the one that revealed them.
 *
 * Nothing is transformed on the way in or out. The actions are in the document
 * or they are not, and the glyph swaps rather than spinning — the house rule
 * against moving a control holds hardest on the control that is on top of
 * everything else.
 */
export const FloatingActionButton = React.forwardRef<HTMLDivElement, FloatingActionButtonProps>(
  function FloatingActionButton(rawProps, ref) {
    const {
      variant = 'solid',
      size = defaultSize,
      color = 'primary',
      density = 'default',
      elevation = 2,
      icon,
      label,
      extended = false,
      openIcon,
      position = 'fixed',
      corner = 'bottom-end',
      offset = 16,
      safeArea = true,
      direction,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      openOnHover = true,
      closeOnAction = true,
      showLabels = true,
      disabled = false,
      className,
      classNames,
      style,
      children,
      onClick,
      onKeyDown,
      onPointerEnter,
      onPointerLeave,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    const dialId = React.useId();
    const triggerRef = React.useRef<HTMLButtonElement>(null);
    const rootRef = React.useRef<HTMLDivElement>(null);

    const [uncontrolled, setUncontrolled] = React.useState(defaultOpen);
    const controlled = openProp !== undefined;
    // `toArray` rather than `count`: it drops the `null`s and `false`s a
    // `{canEdit && <FloatingAction …/>}` leaves behind, which `count` would
    // report as an action and open an empty dial over.
    const hasActions = React.Children.toArray(children).length > 0;
    const open = (controlled ? openProp : uncontrolled) && hasActions && !disabled;

    const setOpen = React.useCallback(
      (next: boolean) => {
        if (!controlled) {
          setUncontrolled(next);
        }

        onOpenChange?.(next);
      },
      [controlled, onOpenChange]
    );

    const close = React.useCallback(() => setOpen(false), [setOpen]);

    /*
     * Whether the dial is up because the pointer arrived rather than because
     * the button was pressed. With `openOnHover` a mouse opens the dial on its
     * way to the button, and the click that follows toggled it straight back
     * shut, so clicking the button with a mouse closed the dial it was reaching
     * for. That first click keeps it open instead; the next one closes it.
     */
    const openedByHover = React.useRef(false);

    // A press anywhere else puts the dial away. `pointerdown` rather than
    // `click`, so the dial is gone before whatever was pressed reacts.
    React.useEffect(() => {
      if (!open) {
        return;
      }

      const onPointerDown = (event: PointerEvent) => {
        const root = rootRef.current;
        if (root && event.target instanceof Node && !root.contains(event.target)) {
          close();
        }
      };

      document.addEventListener('pointerdown', onPointerDown);
      return () => document.removeEventListener('pointerdown', onPointerDown);
    }, [open, close]);

    const fan = direction ?? (corner.startsWith('bottom') ? 'top' : 'bottom');
    // `end` corners put the dial's labels on the inside, which is the side the
    // screen is actually on.
    const reversed = corner.endsWith('end');

    const context = React.useMemo(
      () => ({
        variant,
        size: actionSizes[size],
        color,
        density,
        elevation,
        showLabels,
        reversed,
        close: closeOnAction ? close : () => {},
        closesOnAction: closeOnAction,
        focusTrigger: () => triggerRef.current?.focus()
      }),
      [variant, size, color, density, elevation, showLabels, reversed, closeOnAction, close]
    );

    const glyph = open && openIcon !== false ? (openIcon ?? <CloseIcon />) : (icon ?? <PlusIcon />);

    return (
      <div
        ref={(node) => {
          rootRef.current = node;
          if (typeof ref === 'function') {
            ref(node);
          } else if (ref) {
            ref.current = node;
          }
        }}
        className={cx(
          'flex w-fit',
          // The trigger is first in the document whichever way the dial fans, so
          // the tab order is always "the button, then what came out of it".
          // Reversing the *drawing* is what puts the actions above it.
          fan === 'top' ? 'flex-col-reverse' : 'flex-col',
          reversed ? 'items-end' : 'items-start',
          size === 'xs' || size === 'sm' ? 'gap-1.5' : 'gap-2',
          positionClasses[position],
          position === 'static'
            ? ''
            : safeArea && (position === 'fixed' || position === 'sticky')
              ? safeCornerClasses[corner]
              : cornerClasses[corner],
          classNames?.frame
        )}
        style={
          {
            '--n-fab-offset': typeof offset === 'number' ? `${offset}px` : offset
          } as React.CSSProperties
        }
        onKeyDown={(event) => {
          if (event.key === 'Escape' && open) {
            event.stopPropagation();
            close();
            triggerRef.current?.focus();
          }

          onKeyDown?.(event);
        }}
        onPointerEnter={(event) => {
          if (openOnHover && hasActions && !disabled && event.pointerType === 'mouse') {
            openedByHover.current = !open;
            setOpen(true);
          }

          onPointerEnter?.(event);
        }}
        onPointerLeave={(event) => {
          if (openOnHover && event.pointerType === 'mouse') {
            openedByHover.current = false;
            close();
          }

          onPointerLeave?.(event);
        }}
        {...props}
      >
        <Button
          ref={triggerRef}
          variant={variant}
          size={size}
          color={color}
          density={density}
          elevation={elevation}
          disabled={disabled}
          aria-label={label}
          aria-expanded={hasActions ? open : undefined}
          aria-controls={hasActions && open ? dialId : undefined}
          startIcon={glyph}
          // An inline style rather than `rounded-full`, and for the reason
          // IconButton gives: Button already writes a `rounded-*` utility, and
          // two utilities setting the same property resolve by their order in
          // the generated stylesheet. An inline declaration is the one form that
          // wins deterministically — and a stadium and a disc are the same
          // declaration, since the radius is only ever half the height. The
          // caller's `style` is merged over it rather than replacing it, and the
          // caller's `className` is here too: the button is the thing a class
          // for a floating action button is meant for.
          className={className}
          style={{ borderRadius: '9999px', ...style }}
          onClick={(event) => {
            if (hasActions) {
              if (open && openedByHover.current) {
                openedByHover.current = false;
              } else {
                setOpen(!open);
              }
            }

            onClick?.(event);
          }}
        >
          {extended ? label : undefined}
        </Button>

        {open ? (
          <div
            id={dialId}
            className={cx(
              // The same reversal the root makes, for the same reason: the first
              // action is the one nearest the button it came out of, whichever
              // way the dial fans.
              'flex',
              fan === 'top' ? 'flex-col-reverse' : 'flex-col',
              reversed ? 'items-end' : 'items-start',
              size === 'xs' || size === 'sm' ? 'gap-1.5' : 'gap-2',
              // The dial arrived in one frame, which on a corner of the screen
              // reads as something having gone wrong rather than as something
              // having opened. Opacity and nothing else: these are buttons with
              // words beside them, and a dial that slid would move the action
              // the finger was already travelling towards.
              //
              // Written as the `animation` shorthand rather than through the
              // `neba-anim` classes, whose `--n-anim-*` slots would have to be
              // plumbed from a caller that has no say over this. `both` keeps it
              // on the first frame until it starts.
              '[animation:neba-anim-fade_var(--neba-duration)_var(--neba-ease)_both]'
            )}
          >
            <FloatingActionContext.Provider value={context}>
              {children}
            </FloatingActionContext.Provider>
          </div>
        ) : null}
      </div>
    );
  }
);

/**
 * One action in the dial.
 *
 * It has no `size`, no `color` and no `variant` of its own: all three belong to
 * the button it came out of, which is the only place they can be set once and
 * mean the same thing for every action.
 */
export const FloatingAction = React.forwardRef<HTMLButtonElement, FloatingActionProps>(
  function FloatingAction({ icon, label, disabled = false, className, onClick, ...props }, ref) {
    const dial = React.useContext(FloatingActionContext);

    return (
      <div
        className={cx(
          'flex items-center gap-2',
          // The name goes on the inside of the corner the dial hangs from, so it
          // is drawn over the page rather than off the edge of it.
          dial.reversed ? 'flex-row-reverse' : 'flex-row',
          className
        )}
      >
        <Button
          ref={ref}
          variant={dial.variant}
          size={dial.size}
          color={dial.color}
          density={dial.density}
          elevation={dial.elevation}
          disabled={disabled}
          aria-label={label}
          startIcon={icon}
          style={{ borderRadius: '9999px' }}
          onClick={(event) => {
            // Read before anything closes: the dial and this button leave the
            // document together, and a focus that goes with them lands on the
            // page — the same place Escape already refuses to leave it.
            const hadFocus = event.currentTarget === document.activeElement;

            onClick?.(event);
            dial.close();

            if (hadFocus && dial.closesOnAction) {
              dial.focusTrigger();
            }
          }}
          {...props}
        />

        {dial.showLabels && hasContent(label) ? (
          // `aria-hidden`, because the button beside it already carries exactly
          // this string as its accessible name. Left readable it would be
          // announced twice.
          <span aria-hidden="true" className={cx(actionLabelClasses, metaTextClasses[dial.size])}>
            {label}
          </span>
        ) : null}
      </div>
    );
  }
);

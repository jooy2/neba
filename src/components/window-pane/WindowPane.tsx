import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useMessages } from '../../internal/i18n';
import { cx, hasContent, iconClasses, surfaceClasses } from '../../internal/styles';
import {
  WindowControls,
  orderControls,
  windowChrome,
  windowMetrics,
  windowSlots
} from '../../internal/window';
import type { NebaWindowControl, NebaWindowOffset, NebaWindowOs } from '../../internal/window';
import type { NebaColor, NebaElevation, NebaSize } from '../../types';

export type { NebaWindowControl, NebaWindowOffset, NebaWindowOs } from '../../internal/window';

/** The three CSS positions a window can be laid out with. */
export type WindowPanePosition = 'static' | 'absolute' | 'fixed';

/** What a resize reports: the window's size in pixels. */
export interface WindowPaneSize {
  width: number;
  height: number;
}

export interface WindowPaneProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  // `title` is the tooltip attribute on every element; here it is the window's
  // name, and a `ReactNode` rather than a string. `onResize` is the window's
  // own, which reports pixels rather than a DOM event.
  'color' | 'title' | 'onResize'
> {
  /**
   * Whose window this is a picture of. Decides where the controls sit, how they
   * are drawn, how tall the title bar is and how its corners are cut.
   * @default 'macos'
   */
  os?: NebaWindowOs;
  /** The window's name, in the title bar. Also what names the window itself. */
  title?: React.ReactNode;
  /** A glyph beside the title — the app's mark. */
  icon?: React.ReactNode;
  /** Anything else the title bar carries, set beside the controls. */
  actions?: React.ReactNode;
  /**
   * Which of the three buttons the title bar has. `true` is all of them,
   * `false` is none, and an array is exactly the ones named — a window that can
   * be closed but not minimized is `['close']`.
   *
   * The order is the system's rather than the array's: macOS puts close first
   * and Windows puts it last, and that is not something a caller should have to
   * remember.
   * @default true
   */
  controls?: boolean | readonly NebaWindowControl[];
  /**
   * The scale of the chrome — the title bar's height, its buttons and its type.
   * It does not touch the content, which is the caller's and is laid out at its
   * own scale, exactly as it would be on a desktop where the title bar does not
   * grow with the document.
   * @default 'md'
   */
  size?: NebaSize;
  /** The colour family the focus rings and an `accent` title bar take. @default 'primary' */
  color?: NebaColor;
  /**
   * Dyes the title bar with the colour family, the way Windows offers to. Off,
   * the bar is the neutral shade the system draws by default.
   * @default false
   */
  accent?: boolean;
  /**
   * How much of what is behind the window shows through its chrome, from `0` to
   * `1`. It applies to the title bar, the body's own fill and the border —
   * never to the content on it, which stays exactly as legible as it was.
   *
   * Anything above `0` also turns the acrylic on, so the page underneath is
   * blurred rather than merely visible. `1` is a window that is nothing but its
   * edge and its chrome.
   * @default 0
   */
  transparency?: number;
  /**
   * Whether this is the window in front.
   *
   * Left out, the window works it out for itself: it is in front until another
   * WindowPane on the page is pressed or takes the focus, exactly as windows on
   * a desktop behave. A click on the page *around* the windows changes nothing
   * — a paragraph is not a desktop.
   *
   * Pass it to drive that yourself, which is what a caller keeping its own
   * z-order wants.
   *
   * What being in front looks like is the system's: coloured traffic lights on
   * macOS against grey ones, an accent title bar and an accent border on
   * Windows 10, a tinted header bar on GNOME — and, on all four, a window one
   * step further off the page than the ones behind it.
   */
  active?: boolean;
  /**
   * The shadow around the window. `2` here, against the `0` everything else
   * defaults to, for the reason Pill's is `2`: a window is by definition not
   * part of the page it is on.
   * @default 2
   */
  elevation?: NebaElevation;
  /**
   * How the window is laid out. `static` leaves it in the flow (as a
   * relatively positioned box, so `offset` can move it without disturbing
   * anything around it); `absolute` pins it inside the nearest positioned
   * ancestor, which is what a desktop full of windows wants; `fixed` pins it to
   * the viewport.
   * @default 'static'
   */
  position?: WindowPanePosition;
  /** Lets the title bar be dragged. @default false */
  draggable?: boolean;
  /** Lets the edges and corners be dragged. @default false */
  resizable?: boolean;
  /** The window's width — a number in pixels or any CSS length. */
  width?: number | string;
  /** And its height. Left out, the window is as tall as what is in it. */
  height?: number | string;
  /** How small it may be dragged, in pixels. @default 180 */
  minWidth?: number;
  /** The same downward. Defaults to the title bar's own height. */
  minHeight?: number;
  /** How far it has been dragged from where the layout put it. */
  offset?: NebaWindowOffset;
  /** Where an uncontrolled window starts. @default { x: 0, y: 0 } */
  defaultOffset?: NebaWindowOffset;
  onOffsetChange?: (offset: NebaWindowOffset) => void;
  /** Fires with the window's size, in pixels, while an edge is dragged. */
  onResize?: (size: WindowPaneSize) => void;
  /** Whether the window is on screen at all. Closing it renders nothing. */
  open?: boolean;
  /** @default true */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Whether the window is rolled up to its title bar. This is what minimizing
   * means for a window that is part of a page rather than of a desktop: there
   * is no dock for it to go to, so it stays where it is with nothing under the
   * bar.
   */
  minimized?: boolean;
  /** @default false */
  defaultMinimized?: boolean;
  onMinimizedChange?: (minimized: boolean) => void;
  /**
   * Whether the window fills whatever is holding it. Its corners go square
   * while it does, as they do on every system.
   */
  maximized?: boolean;
  /** @default false */
  defaultMaximized?: boolean;
  onMaximizedChange?: (maximized: boolean) => void;
  /** Whether content taller than the window scrolls. @default true */
  scroll?: boolean;
  /**
   * Which language the title bar's buttons name themselves in — a BCP 47 tag
   * such as `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   */
  locale?: string;
  /** Overrides the buttons' own names. */
  minimizeLabel?: string;
  maximizeLabel?: string;
  restoreLabel?: string;
  closeLabel?: string;
  resizeLabel?: string;
  /** Renders something other than a `<div>`: `render={<section />}`. */
  render?: useRender.RenderProp;
  /** What is in the window. */
  children?: React.ReactNode;
}

/**
 * A controlled/uncontrolled pair, written once.
 *
 * Four of this component's props are the same three-prop dance — `open`,
 * `minimized`, `maximized` and `offset` — and four copies of it in one file is
 * four places for the `if (controlled)` to be forgotten.
 */
function useLatched<T>(
  controlled: T | undefined,
  initial: T,
  onChange: ((value: T) => void) | undefined
): [T, (next: T) => void] {
  const [uncontrolled, setUncontrolled] = React.useState(initial);
  const isControlled = controlled !== undefined;
  const value = isControlled ? controlled : uncontrolled;

  const set = React.useCallback(
    (next: T) => {
      if (!isControlled) {
        setUncontrolled(next);
      }

      onChange?.(next);
    },
    [isControlled, onChange]
  );

  return [value, set];
}

/** How far one arrow key press moves an edge. The same step Panes uses. */
const KEYBOARD_STEP = 16;

/**
 * Where each resize handle sits, and what the pointer turns into over it.
 *
 * Physical rather than logical, and deliberately: `nwse-resize` is the cursor
 * the platform draws, the geometry underneath is `left`/`top`, and a window is
 * an object on a surface rather than a run of text. Everything the *chrome*
 * does — which end the controls are on, which side the title starts from —
 * stays logical and mirrors under RTL.
 */
const resizeHandles = [
  { edge: 'n', className: 'inset-x-3 top-0 h-1.5 cursor-ns-resize' },
  { edge: 's', className: 'inset-x-3 bottom-0 h-1.5 cursor-ns-resize' },
  { edge: 'w', className: 'inset-y-3 left-0 w-1.5 cursor-ew-resize' },
  { edge: 'e', className: 'inset-y-3 right-0 w-1.5 cursor-ew-resize' },
  { edge: 'nw', className: 'top-0 left-0 size-3 cursor-nwse-resize' },
  { edge: 'ne', className: 'top-0 right-0 size-3 cursor-nesw-resize' },
  { edge: 'sw', className: 'bottom-0 left-0 size-3 cursor-nesw-resize' },
  { edge: 'se', className: 'right-0 bottom-0 size-3 cursor-nwse-resize' }
] as const;

/**
 * A window, drawn the way one of four systems draws it, with anything at all
 * inside it.
 *
 * It is not a real window and does not pretend to be one: there is no desktop,
 * no z-order and no dock. What it is is a *frame that behaves* — the title bar
 * drags, the corners resize, the three buttons are real buttons with real names
 * — so a screenshot of an app, a demo of a feature or a piece of a landing page
 * can be shown as the thing it will be rather than as a picture of it.
 *
 * Nothing here is transformed. A dragged window moves on `left` and `top` and a
 * resized one changes `width` and `height`, which is what keeps the text inside
 * it at whole pixels through both gestures — a `translate()` would resample
 * every glyph in the window for the length of the drag, which is exactly what
 * the house rule against transforming a surface exists to prevent.
 *
 * `minimize` rolls the window up to its title bar rather than sending it
 * anywhere, because a page has nowhere to send it to. `maximize` fills whatever
 * is holding the window, which is the container for `position="absolute"` and
 * the viewport for `fixed`.
 */
export const WindowPane = React.forwardRef<HTMLDivElement, WindowPaneProps>(function WindowPane(
  {
    os = 'macos',
    title,
    icon,
    actions,
    controls = true,
    size = 'md',
    color = 'primary',
    accent = false,
    transparency = 0,
    active: activeProp,
    elevation = 2,
    position = 'static',
    draggable = false,
    resizable = false,
    width,
    height,
    minWidth = 180,
    minHeight,
    offset: offsetProp,
    defaultOffset,
    onOffsetChange,
    onResize,
    open: openProp,
    defaultOpen = true,
    onOpenChange,
    minimized: minimizedProp,
    defaultMinimized = false,
    onMinimizedChange,
    maximized: maximizedProp,
    defaultMaximized = false,
    onMaximizedChange,
    scroll = true,
    locale,
    minimizeLabel,
    maximizeLabel,
    restoreLabel,
    closeLabel,
    resizeLabel,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const messages = useMessages(locale);
  const chrome = windowChrome(os);
  const metrics = windowMetrics(os, size);
  const titleId = React.useId();

  const [open, setOpen] = useLatched(openProp, defaultOpen, onOpenChange);
  const [minimized, setMinimized] = useLatched(minimizedProp, defaultMinimized, onMinimizedChange);
  const [maximized, setMaximized] = useLatched(maximizedProp, defaultMaximized, onMaximizedChange);
  const [offset, setOffset] = useLatched(
    offsetProp,
    defaultOffset ?? { x: 0, y: 0 },
    onOffsetChange
  );

  /** The size a drag has given the window, which outranks `width`/`height`. */
  const [sized, setSized] = React.useState<WindowPaneSize | null>(null);

  /**
   * Whether this window has the page's attention, when the caller has not said.
   *
   * It starts in front, because a page with one window on it should not open
   * with that window greyed out, and it steps back only when another WindowPane
   * is pressed or focused. That is the whole rule: what makes a window inactive
   * is a *different window* becoming active, never a click on the prose beside
   * it.
   */
  const [attended, setAttended] = React.useState(true);
  const active = activeProp ?? attended;

  /**
   * The two lengths a roll-up animates between.
   *
   * `rolled` is what the window measures with nothing under its title bar, read
   * off the bar itself rather than off the metrics table so it is right whatever
   * box model the page is in. `pinned` is the height a window that was never
   * given one had at the moment it was rolled up: a transition needs a number to
   * travel from, and `auto` is not one.
   */
  const [rolled, setRolled] = React.useState<number | null>(null);
  const [pinned, setPinned] = React.useState<number | null>(null);

  /** Raised while a drag or a resize is running, which is when the window has to
   *  keep up with the pointer rather than ease after it. */
  const [gesturing, setGesturing] = React.useState(false);

  /**
   * Held for the length of one transition after a window is closed.
   *
   * A window that is simply dropped from the tree does not leave, it stops
   * existing — so it is kept for as long as it takes to fade, `inert` and
   * unpressable, and then let go. This is `opacity` carrying an *exit* rather
   * than a state, which is the same allowance every `Animate*` component makes.
   *
   * The flip is noticed during the render that carries it rather than in an
   * effect, which is React's own answer to "adjust some state when a prop
   * changes": the second render happens before anything is painted, so the
   * window never appears for a frame in the wrong state.
   */
  const [leaving, setLeaving] = React.useState(false);
  const [wasOpen, setWasOpen] = React.useState(open);

  if (wasOpen !== open) {
    setWasOpen(open);
    setLeaving(!open);
  }

  React.useEffect(() => {
    if (!leaving) {
      return;
    }

    const timer = window.setTimeout(() => setLeaving(false), 260);

    return () => window.clearTimeout(timer);
  }, [leaving]);

  const rootRef = React.useRef<HTMLDivElement | null>(null);
  const setRootRef = React.useCallback(
    (node: HTMLDivElement | null) => {
      rootRef.current = node;

      if (typeof ref === 'function') ref(node);
      else if (ref) ref.current = node;
    },
    [ref]
  );

  React.useEffect(() => {
    if (activeProp !== undefined) {
      return;
    }

    const root = rootRef.current;
    if (!root) {
      return;
    }

    const notice = (event: Event) => {
      const target = event.target;
      if (!(target instanceof Node)) {
        return;
      }

      if (root.contains(target)) {
        setAttended(true);
        return;
      }

      const element = target instanceof Element ? target : target.parentElement;
      if (element?.closest('.neba-window')) {
        setAttended(false);
      }
    };

    // Capture, so a press that a control inside another window stops from
    // bubbling still counts as that window being brought forward.
    document.addEventListener('pointerdown', notice, true);
    document.addEventListener('focusin', notice, true);

    return () => {
      document.removeEventListener('pointerdown', notice, true);
      document.removeEventListener('focusin', notice, true);
    };
  }, [activeProp]);

  /*
   * A gesture is torn down by the pointerup that ends it, and that event never
   * arrives if the window goes away first — closed, unmounted, routed past.
   * What is left behind is not only two listeners on a detached node: a drag
   * takes the document's text selection away while it runs, and nothing else
   * puts it back.
   */
  const teardownRef = React.useRef<(() => void) | null>(null);

  React.useEffect(() => () => teardownRef.current?.(), []);

  /**
   * The plumbing both gestures share: capture the pointer, take the selection
   * off the page, hand every move a delta from where the press started, and put
   * all of it back afterwards.
   */
  function beginGesture(
    event: React.PointerEvent<HTMLElement>,
    onMove: (dx: number, dy: number) => void
  ) {
    if (event.button !== 0) return;

    // The gesture before this one, if its pointerup was never delivered.
    teardownRef.current?.();

    const target = event.currentTarget;
    target.setPointerCapture(event.pointerId);
    target.dataset.dragging = 'true';
    // The window eases into a new size when a button put it there and follows
    // the pointer exactly when a hand is doing it. A transition on `width` while
    // a corner is being dragged is a window that lags behind the corner.
    setGesturing(true);

    const fromX = event.clientX;
    const fromY = event.clientY;

    // Written prefixed and through `setProperty` because WebKit implements only
    // `-webkit-user-select`: `style.userSelect = 'none'` hangs a plain JS
    // property off the object and Safari selects text through the whole drag.
    const selection = document.body.style.getPropertyValue('-webkit-user-select');
    document.body.style.setProperty('-webkit-user-select', 'none');

    const move = (moveEvent: PointerEvent) => {
      onMove(moveEvent.clientX - fromX, moveEvent.clientY - fromY);
    };

    const release = () => {
      teardownRef.current = null;
      setGesturing(false);
      target.removeEventListener('pointermove', move);
      target.removeEventListener('pointerup', release);
      target.removeEventListener('pointercancel', release);
      delete target.dataset.dragging;

      // Removed rather than blanked, so a page that never wrote the property
      // inline is left with the declaration it actually had.
      if (selection) document.body.style.setProperty('-webkit-user-select', selection);
      else document.body.style.removeProperty('-webkit-user-select');
    };

    teardownRef.current = release;
    target.addEventListener('pointermove', move);
    target.addEventListener('pointerup', release);
    target.addEventListener('pointercancel', release);
  }

  function beginDrag(event: React.PointerEvent<HTMLDivElement>) {
    if (!draggable || maximized) return;

    const from = { ...offset };
    beginGesture(event, (dx, dy) => setOffset({ x: from.x + dx, y: from.y + dy }));
  }

  const floor = {
    width: Math.max(0, minWidth),
    height: Math.max(metrics.bar, minHeight ?? metrics.bar)
  };

  function resizeTo(next: WindowPaneSize) {
    setSized(next);
    onResize?.(next);
  }

  function beginResize(edge: string, event: React.PointerEvent<HTMLDivElement>) {
    const root = rootRef.current;
    if (!root || maximized) return;

    const rect = root.getBoundingClientRect();
    const from = { width: rect.width, height: rect.height, x: offset.x, y: offset.y };

    const east = edge.includes('e');
    const west = edge.includes('w');
    const north = edge.includes('n');
    const south = edge.includes('s');

    beginGesture(event, (dx, dy) => {
      let { width: nextWidth, height: nextHeight } = from;
      let { x, y } = from;

      if (east) nextWidth = Math.max(floor.width, from.width + dx);
      if (south) nextHeight = Math.max(floor.height, from.height + dy);

      // Dragging a leading edge moves the window as it resizes it, and the
      // *clamped* width is what decides how far: at the minimum the edge stops
      // and the window has to stop with it, or a window held at 180px would
      // keep sliding out from under the pointer.
      if (west) {
        nextWidth = Math.max(floor.width, from.width - dx);
        x = from.x + (from.width - nextWidth);
      }
      if (north) {
        nextHeight = Math.max(floor.height, from.height - dy);
        y = from.y + (from.height - nextHeight);
      }

      resizeTo({ width: nextWidth, height: nextHeight });
      if (west || north) setOffset({ x, y });
    });
  }

  function nudge(dx: number, dy: number) {
    const root = rootRef.current;
    if (!root) return;

    const rect = root.getBoundingClientRect();
    resizeTo({
      width: Math.max(floor.width, rect.width + dx),
      height: Math.max(floor.height, rect.height + dy)
    });
  }

  const wanted =
    controls === true
      ? (['minimize', 'maximize', 'close'] as const)
      : controls === false
        ? []
        : controls;
  const drawn = orderControls(os, wanted);
  const canMaximize = drawn.includes('maximize');

  /**
   * Rolling the window up, and the only thing here that cannot be done in one
   * render.
   *
   * A window that was given a `height` has two numbers to travel between and
   * animates on its own. One that was not is `height: auto`, which is not a
   * length and so is not a thing CSS can transition *from* — so its height is
   * measured, pinned for one frame, and only then taken away. The pin is
   * released once the journey back is over, so content that grows later still
   * grows the window.
   */
  function rollUp(next: boolean) {
    const root = rootRef.current;
    const bar = root?.firstElementChild;

    if (root && bar instanceof HTMLElement) {
      // Measured rather than read off the metrics table: the collapsed height is
      // the bar plus whatever the borders come to, and which of those the height
      // property includes is the page's box model to decide.
      setRolled(bar.offsetHeight + (root.offsetHeight - root.clientHeight));
    }

    const auto = (sized?.height ?? height) === undefined;

    if (next && auto && root) {
      setPinned(root.getBoundingClientRect().height);
      requestAnimationFrame(() => setMinimized(true));
      return;
    }

    setMinimized(next);
  }

  /* The pin is only ever scaffolding for one transition. */
  React.useEffect(() => {
    if (minimized || pinned === null) {
      return;
    }

    const timer = window.setTimeout(() => setPinned(null), 400);

    return () => window.clearTimeout(timer);
  }, [minimized, pinned]);

  function command(control: NebaWindowControl) {
    if (control === 'close') setOpen(false);
    else if (control === 'minimize') rollUp(!minimized);
    else setMaximized(!maximized);
  }

  const labels = {
    minimize: minimizeLabel ?? messages.window.minimize,
    maximize: maximizeLabel ?? messages.window.maximize,
    restore: restoreLabel ?? messages.window.restore,
    close: closeLabel ?? messages.action.close
  };

  const barControls = (
    <WindowControls
      os={os}
      metrics={metrics}
      controls={drawn}
      maximized={maximized}
      active={active}
      labels={labels}
      onCommand={command}
    />
  );

  const named = hasContent(title) ? (
    <span id={titleId} className="min-w-0 truncate font-medium">
      {title}
    </span>
  ) : null;

  const mark = hasContent(icon) ? <span className="flex shrink-0 items-center">{icon}</span> : null;

  const bar = (
    <div
      className={cx(
        'relative flex shrink-0 items-center select-none',
        iconClasses,
        draggable && !maximized ? 'cursor-grab active:cursor-grabbing' : ''
      )}
      style={{
        height: metrics.bar,
        paddingInlineStart: metrics.padX,
        // Nothing at the trailing edge on Windows: a caption button is a corner
        // target, and a corner target that stops 12px short of the corner is the
        // one detail that stops a Windows title bar looking like one.
        paddingInlineEnd: metrics.padEnd,
        gap: Math.round(metrics.title * 0.7),
        fontSize: metrics.title,
        background: 'var(--n-window-bar)',
        color: 'var(--n-window-bar-fg)',
        // Windows 10 is the one of the four that rules its title bar off from
        // the body. On the others the two are one sheet in two shades.
        borderBlockEnd: chrome.rule ? '1px solid var(--n-window-line)' : undefined
      }}
      onPointerDown={beginDrag}
      // What every one of these systems does when the bar is double-clicked,
      // and the one gesture a caller would notice the absence of.
      onDoubleClick={canMaximize ? () => setMaximized(!maximized) : undefined}
    >
      {chrome.controlsSide === 'start' ? barControls : null}

      {chrome.titleAlign === 'center' ? (
        // Centred over the *window* rather than over what is left of the bar,
        // which is the difference between a macOS title and a Windows one. The
        // padding is the room the controls take, so a long name truncates
        // before it reaches them rather than running underneath.
        <span
          aria-hidden="true"
          className="pointer-events-none absolute inset-x-0 flex items-center justify-center"
          style={{ paddingInline: metrics.controlsWidth(drawn.length) + metrics.padX * 2 }}
        >
          <span
            className="flex min-w-0 items-center"
            style={{ gap: Math.round(metrics.title * 0.5) }}
          >
            {mark}
            {named}
          </span>
        </span>
      ) : (
        <>
          {mark}
          {named}
        </>
      )}

      <span className="flex-1" />

      {hasContent(actions) ? (
        <span
          className="flex shrink-0 items-center"
          style={{ gap: Math.round(metrics.title * 0.5) }}
          onPointerDown={(event) => event.stopPropagation()}
        >
          {actions}
        </span>
      ) : null}

      {chrome.controlsSide === 'end' ? barControls : null}
    </div>
  );

  const geometry: React.CSSProperties = maximized
    ? // `100%` rather than `inset: 0`, and on every `position`: both ends of a
      // maximize have to be lengths for the window to travel between them, and
      // `auto` is not one.
      { left: 0, top: 0, width: '100%', height: '100%' }
    : {
        left: offset.x,
        top: offset.y,
        width: sized?.width ?? width,
        // A rolled-up window is as tall as its title bar, whatever it was told
        // to be — the height belongs to the body, and the body has gone.
        height: minimized
          ? (rolled ?? metrics.bar)
          : (sized?.height ?? height ?? pinned ?? undefined)
      };

  const pane = useRender({
    render,
    ref: setRootRef,
    props: {
      role: 'group',
      'aria-labelledby': named ? titleId : undefined,
      // A hook rather than a style, the way `neba-link` and `neba-mockup` are:
      // it is how a caller reaches the window without counting elements.
      className: cx(
        'neba-window relative flex min-w-0 flex-col overflow-hidden',
        // The acrylic is what a translucent window is made of. An opaque one
        // has nothing to blur and pays for nothing.
        transparency > 0 ? surfaceClasses : '',
        // Maximizing, restoring and rolling up are journeys between two
        // geometries, so the window travels rather than jumps. No `transform` is
        // in the list and none should be added: a window that scaled would
        // resample every glyph in it for the length of the move, which is the
        // whole of what the house rule protects.
        '[transition-property:left,top,width,height,opacity,box-shadow,background-color,border-color,border-radius]',
        '[transition-duration:var(--neba-duration-window)]',
        '[transition-timing-function:var(--neba-ease)]',
        'motion-reduce:[transition-duration:0ms]',
        // Under a hand, the window keeps up rather than eases after.
        'data-[gesture]:[transition-property:none]',
        className
      ),
      'data-gesture': gesturing ? '' : undefined,
      // Nothing in a window on its way out can be pressed or reached, and the
      // page underneath it is available again from the frame the close lands on.
      inert: !open || undefined,
      style: {
        opacity: open ? undefined : 0,
        ...windowSlots({ os, color, accent, transparency, active, elevation }),
        position: position === 'static' ? 'relative' : position,
        ...geometry,
        // Square while maximized, as on every one of the four: a window filling
        // the screen has no corners to cut.
        borderRadius: maximized ? 0 : metrics.radius,
        border: '1px solid var(--n-window-line)',
        boxShadow: 'var(--n-window-shadow), var(--neba-plate-glass)',
        ...style
      } as React.CSSProperties,
      children: (
        <>
          {bar}

          {/*
            Kept in the tree while the window is rolled up rather than unmounted,
            which is what lets the roll-up be a journey rather than a cut — the
            root's own `overflow: hidden` is what hides it. `inert` is what makes
            it honest: a zero-height box its content is still perfectly focusable
            inside is the exact shape of the bug where a keyboard reader lands
            somewhere nobody can see.
          */}
          <div
            className={cx('min-h-0 flex-1', scroll ? 'overflow-auto' : 'overflow-hidden')}
            style={{ background: 'var(--n-window-body)' }}
            inert={minimized}
          >
            {children}
          </div>

          {resizable && !maximized && !minimized
            ? resizeHandles.map((handle) => {
                const corner = handle.edge === 'se';

                return (
                  <div
                    key={handle.edge}
                    // One of the eight is reachable without a pointer, and it is
                    // the corner that changes both axes at once: eight tab stops
                    // around every window would cost a keyboard reader more than
                    // the seven extra directions are worth.
                    role={corner ? 'button' : undefined}
                    tabIndex={corner ? 0 : undefined}
                    aria-label={corner ? (resizeLabel ?? messages.window.resize) : undefined}
                    aria-hidden={corner ? undefined : 'true'}
                    className={cx(
                      'absolute z-10 touch-none',
                      handle.className,
                      corner
                        ? 'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]'
                        : ''
                    )}
                    onPointerDown={(event) => beginResize(handle.edge, event)}
                    onKeyDown={
                      corner
                        ? (event) => {
                            const step = {
                              ArrowRight: [KEYBOARD_STEP, 0],
                              ArrowLeft: [-KEYBOARD_STEP, 0],
                              ArrowDown: [0, KEYBOARD_STEP],
                              ArrowUp: [0, -KEYBOARD_STEP]
                            }[event.key];

                            if (!step) return;
                            event.preventDefault();
                            nudge(step[0], step[1]);
                          }
                        : undefined
                    }
                  />
                );
              })
            : null}
        </>
      ),
      ...props
    }
  });

  // The early return a closed window wants cannot be an early return: `useRender`
  // is a hook, and a component that stops calling it on the render where it
  // closes is a component that calls a different number of hooks than it did
  // last time.
  return open || leaving ? pane : null;
});

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { PageLayoutContext } from '../../internal/page-layout.js';
import { cx, surfaceClasses, surfaceSlots, transitionClasses } from '../../internal/styles.js';
import type {
  NebaColor,
  NebaDensity,
  NebaElevation,
  NebaPosition,
  NebaSize,
  NebaVariant
} from '../../types.js';

export interface FooterProps extends Omit<
  React.ComponentPropsWithoutRef<'footer'>,
  'color' | 'title'
> {
  /**
   * How the bar sits in the page's scroll. `static` — the default, and the
   * opposite of [Header]'s — is what a footer is: the thing at the end of the
   * document, reached by scrolling to it. `sticky` and `fixed` are for the bar
   * that has to stay in reach — a form's save row, a cookie notice — and a
   * [PageLayout] reserves the height a `fixed` one takes out of the flow.
   * @default 'static'
   */
  position?: NebaPosition;
  /**
   * Weight of the sheet, said the way a *container* says it: the bar is never
   * dyed, because what is on it arrives with colours of its own.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /**
   * The bar's scale — its gutter and the air above and below its content. As on
   * Box, `size` here is the size of the *sheet*.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** @default 'default' */
  density?: NebaDensity;
  /** Drop shadow depth. `0` (the default) is flat. @default 0 */
  elevation?: NebaElevation;
  /**
   * Draws a hairline along the top edge. On by default: a footer is the one
   * sheet on the page with content directly above it and nothing below, so the
   * line is the whole of what says the document ended.
   * @default true
   */
  divider?: boolean;
  /**
   * Holds the content to a measure and centres it, while the sheet itself still
   * spans the window. On the same ladder Container's own `maxWidth` uses.
   * @default 'none'
   */
  maxWidth?: NebaSize | 'none';
  /** The gutter and the air above and below. @default true */
  padded?: boolean;
  /**
   * The name the bar is announced by. Worth writing when a page has more than
   * one `<footer>` in it — an article's own and the site's.
   */
  label?: string;
  /**
   * Renders something other than a `<footer>`. Base UI's own escape hatch, and
   * rarely what you want: at the top level of a document that tag is the
   * `contentinfo` landmark, and it is what says "this is the site's own
   * information" rather than "this is more of the article".
   */
  render?: useRender.RenderProp;
  /**
   * Everything in it. A footer's content is columns of links, a copyright line,
   * a logo — all of it the caller's, none of it something a component could
   * guess at, which is why this one has slots for nothing and space for
   * anything.
   */
  children?: React.ReactNode;
}

/** The three weights, said the way a *container* says them, exactly as on Header. */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-press)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel)',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

const positionClasses: Record<NebaPosition, string> = {
  static: '',
  sticky: 'sticky bottom-0 z-30',
  fixed: 'fixed inset-x-0 bottom-0 z-40'
};

/** The measure, in the same `rem` steps Container's ladder uses. */
const maxWidthClasses: Record<NebaSize, string> = {
  xs: 'max-w-[30rem]',
  sm: 'max-w-[40rem]',
  md: 'max-w-[48rem]',
  lg: 'max-w-[64rem]',
  xl: 'max-w-[80rem]'
};

/**
 * The sheet at the end of a page.
 *
 * A real `<footer>`, which is the whole reason it is a component rather than a
 * div: at the top level of a document that tag is the `contentinfo` landmark —
 * the region a screen reader offers as "the site's own information" and a
 * search engine reads the copyright, the address and the site map out of.
 *
 * It has no slots on purpose, which is the difference between it and [Header].
 * A header's three regions are a fixed arrangement worth writing once; a
 * footer's content is four columns on one site, one line on the next, and a
 * component that guessed at the arrangement would be a component every second
 * site fights. What it decides is the sheet: the surface, the gutter, the
 * hairline that says the document ended, and whether it stays in reach.
 *
 * Inside a [PageLayout] it also registers itself, so a `fixed` footer's height
 * is reserved rather than sitting on top of the last paragraph.
 */
export const Footer = React.forwardRef<HTMLElement, FooterProps>(function Footer(
  {
    position = 'static',
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    divider = true,
    maxWidth = 'none',
    padded = true,
    label,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const layout = React.useContext(PageLayoutContext);
  const { register } = layout;

  const setRef = React.useCallback(
    (node: HTMLElement | null) => {
      register('footer', node);

      if (typeof ref === 'function') ref(node);
      else if (ref) ref.current = node;
    },
    [register, ref]
  );

  const classNames = cx(
    'w-full min-w-0',
    variantClasses[variant],
    divider ? 'border-t [border-color:var(--n-line)]' : '',
    positionClasses[position],
    transitionClasses,
    className
  );

  return useRender({
    render: render ?? <footer />,
    ref: setRef,
    props: {
      'aria-label': label,
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children: (
        <div
          className={cx(
            'w-full',
            padded ? cx(boxPaddingXClasses[density][size], boxPaddingYClasses[density][size]) : '',
            maxWidth === 'none' ? '' : cx(maxWidthClasses[maxWidth], 'mx-auto')
          )}
        >
          {children}
        </div>
      ),
      ...props
    }
  });
});

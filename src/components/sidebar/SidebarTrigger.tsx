import * as React from 'react';
import { IconButton } from '../icon-button/IconButton.js';
import type { IconButtonProps } from '../icon-button/IconButton.js';
import { layoutMessages, useMessages } from '../../internal/i18n.js';
import { collapsedOnlyClasses, PageLayoutContext } from '../../internal/page-layout.js';
import type { PageLayoutCollapse, SidebarSide } from '../../internal/page-layout.js';
import { cx } from '../../internal/styles.js';

export interface SidebarTriggerProps extends Omit<IconButtonProps, 'icon' | 'label'> {
  /** Which of the layout's two sidebars it opens. @default 'start' */
  side?: SidebarSide;
  /**
   * The width below which the button appears — the same one the sidebar
   * collapses at, since the button exists exactly while the sidebar does not.
   * Inherited from the [PageLayout], which is where it should be set.
   */
  collapseBelow?: PageLayoutCollapse;
  /** The glyph. A hamburger, drawn here, unless something else is given. */
  icon?: React.ReactNode;
  /** What it does, in words. Defaults to the `locale`'s "Open sidebar" / "Close sidebar". */
  label?: string;
  /** Which language that word is in. Inherited from the [PageLayout]. */
  locale?: string;
}

/**
 * Three lines.
 *
 * Drawn here rather than in `internal/icons` because this is the only component
 * that needs it — the same place Avatar keeps its silhouette. It is the one
 * glyph in the library that is a picture of a menu rather than a picture of
 * what it does, and it is drawn anyway: thirty years of it have made it the
 * one shape a reader recognises without a word beside it, which is the only
 * argument that ever justifies a symbol.
 */
function MenuIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
      <path d="M4 7h16M4 12h16M4 17h16" strokeLinecap="round" />
    </svg>
  );
}

/**
 * The button that brings back a [Sidebar] the window has become too narrow to
 * hold.
 *
 * It is drawn only while that is true, and the "while" is a media query rather
 * than a piece of state: the button carries a class that hides it at and above
 * the breakpoint. That matters more than it looks — a trigger whose presence
 * depended on `matchMedia` would be absent from the markup a server sends and
 * would pop into the header a moment after the page arrived, on every phone,
 * every time.
 *
 * Put it in a [Header]'s `brand` slot, ahead of the logo, which is where thirty
 * years of hamburgers have taught readers to look for it. It has to be inside a
 * [PageLayout] to have something to open; outside one there is no sidebar it
 * could be talking about, and it renders nothing.
 */
export const SidebarTrigger = React.forwardRef<HTMLButtonElement, SidebarTriggerProps>(
  function SidebarTrigger(
    {
      side = 'start',
      collapseBelow: collapseBelowProp,
      icon,
      label,
      locale: localeProp,
      variant = 'text',
      className,
      onClick,
      ...props
    },
    ref
  ) {
    const layout = React.useContext(PageLayoutContext);
    const locale = localeProp ?? layout.locale;
    const messages = useMessages(layoutMessages, locale);

    if (!layout.present) {
      return null;
    }

    const collapseBelow = collapseBelowProp ?? layout.collapseBelow;
    const open = layout.open[side];

    return (
      <IconButton
        ref={ref}
        variant={variant}
        icon={icon ?? <MenuIcon />}
        label={label ?? (open ? messages.closeSidebar : messages.openSidebar)}
        aria-expanded={open}
        className={cx(collapsedOnlyClasses[collapseBelow], className)}
        onClick={(event) => {
          layout.setOpen(side, !open);
          onClick?.(event);
        }}
        {...props}
      />
    );
  }
);

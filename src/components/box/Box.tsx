import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types';

export interface BoxProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Drop shadow depth. `0` (the default) is flat — the acrylic edge is what
   * separates the box from the page. Raise it only for a surface that genuinely
   * floats above the content around it.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Inner padding, on the `size`/`density` scale below. Turn it off for
   * full-bleed content — an image, a table, a list that draws its own rows.
   * @default true
   */
  padded?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<section />}`,
   * `render={<li />}`, or a function for full control. Base UI's own escape
   * hatch, so it behaves the same here as on every Base UI primitive.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * Corner radius, and nothing else.
 *
 * Unlike every other component in the library, `size` here does **not** set a
 * height or a type scale. A box is as tall as what it holds, and its children
 * bring their own typography — a container that reset the type scale would make
 * the same paragraph render at two sizes depending on what it was wrapped in.
 * So `size` on a Box means the size of the *sheet*: its radius and its padding.
 */
const sizeClasses: Record<NebaSize, string> = {
  xs: 'rounded-(--neba-radius-xs)',
  sm: 'rounded-(--neba-radius-sm)',
  md: 'rounded-(--neba-radius-md)',
  lg: 'rounded-(--neba-radius-lg)',
  xl: 'rounded-(--neba-radius-xl)'
};

/**
 * The same two density tracks as Button, applied on both axes rather than
 * horizontally only: a control has a fixed height that its vertical padding
 * would fight, and a box does not.
 *
 * The per-axis tables are the same numbers split apart, for Card — which turns
 * this padding off and re-applies it section by section so its dividers can run
 * the full width of the sheet. They live here so the two can never drift.
 */
export const boxPaddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'p-2', sm: 'p-3', md: 'p-4', lg: 'p-5', xl: 'p-6' },
  compact: { xs: 'p-1.5', sm: 'p-2', md: 'p-2.5', lg: 'p-3', xl: 'p-4' }
};

export const boxPaddingXClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'px-2', sm: 'px-3', md: 'px-4', lg: 'px-5', xl: 'px-6' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-4' }
};

export const boxPaddingYClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'py-2', sm: 'py-3', md: 'py-4', lg: 'py-5', xl: 'py-6' },
  compact: { xs: 'py-1.5', sm: 'py-2', md: 'py-2.5', lg: 'py-3', xl: 'py-4' }
};

const baseClasses = [
  'block',
  // The same property list and durations as the controls, so a box whose color
  // or elevation changes settles at the house pace. There is no `:active`
  // override because a box is not pressed — it holds things that are.
  '[transition-property:background-color,border-color,box-shadow,color]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]'
].join(' ');

/** The frosted surface, identical to Button's — see the comment there. */
const surfaceClasses =
  '[background-image:var(--neba-grain),var(--neba-sheen)] [background-blend-mode:overlay,normal] [backdrop-filter:var(--neba-blur)]';

/**
 * The variants say the same three things they say on Button — filled, hairline,
 * bare — with the deviation TextField already makes: `solid` does not flood the
 * surface with `--n-fill`.
 *
 * What a box holds is other people's content, and it arrives with its own
 * colors: body text, links, buttons, fields. On an accent fill every one of
 * them would need an on-fill treatment of its own, which is the opposite of
 * what a container is for. So `solid` here is the acrylic sheet dyed a few
 * steps past `outline`, and the color family shows up as the tint and the edge.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
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
  // Grouping only — no surface to catch the light on, and so nothing to cast a
  // shadow either. `elevation` is deliberately ignored rather than drawing a
  // shadow around an invisible rectangle.
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * Maps `color` and `elevation` onto the local slots, for the same reason as on
 * Button: Tailwind only sees literal class names, so a per-family class would
 * have to be hardcoded once per color.
 *
 * There is no hover or press level here. A box does not rise under the cursor
 * and cannot be pressed.
 */
function styleSlots(color: NebaColor, elevation: NebaElevation): React.CSSProperties {
  return {
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-panel': `var(--neba-${color}-panel)`,
    '--n-panel-hover': `var(--neba-${color}-panel-hover)`,
    '--n-line': `var(--neba-${color}-line)`,
    '--n-elev': `var(--neba-shadow-${elevation})`
  } as React.CSSProperties;
}

/**
 * A sheet of acrylic with content on it. The plainest surface in the library:
 * it groups things, and that is all it does.
 *
 * Everything structural — a title, a footer, dividers — belongs to Card, which
 * is a Box with those sections laid out on it.
 */
export const Box = React.forwardRef<HTMLDivElement, BoxProps>(function Box(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    padded = true,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = [
    baseClasses,
    sizeClasses[size],
    padded ? boxPaddingClasses[density][size] : '',
    variantClasses[variant],
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: { ...styleSlots(color, elevation), ...style },
      children,
      ...props
    }
  });
});

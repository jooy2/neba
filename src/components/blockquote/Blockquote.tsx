import * as React from 'react';
import { boxPaddingClasses } from '../box/Box';
import { transitionProps } from '../../internal/animate';
import {
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles';
import type { NebaElevation, NebaSize, NebaStyleProps, NebaTransition } from '../../types';

/**
 * The props are a `<figure>`'s rather than a `<blockquote>`'s, which is a
 * consequence of where the drawing happens: everything a caller passes lands on
 * the wrapper, and the wrapper is a figure or a div. Both are `HTMLElement`, so
 * an event handler written against one works on the other.
 */
export interface BlockquoteProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'figure'>, 'color'> {
  /**
   * Drop shadow depth. `0` (the default) is flat — a quote is set *into* a page
   * rather than floating over it, so this is raised even less often than on a
   * Card.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * An entrance animation, run once on mount: `transition="fade"`, or an object
   * for the details. For a trigger, a replay or anything under your own
   * control, wrap it in an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /**
   * Who said it. Its presence is what turns the quote into a `<figure>` with a
   * `<figcaption>`, which is the markup the HTML spec asks for: an attribution
   * is *about* the quote and is not part of what was said.
   */
  author?: React.ReactNode;
  /**
   * Where it is from — a book, a talk, a page. Rendered inside a `<cite>`, which
   * is the element for the title of a work and, per the spec, never for the name
   * of a person. That is what `author` is.
   */
  source?: React.ReactNode;
  /**
   * URL of the document the quote was taken from. Lands on the `<blockquote>`'s
   * own `cite` attribute, which is machine-readable and shown to nobody — use
   * `source` for the part a reader should see.
   */
  cite?: string;
  /**
   * The mark drawn before the quote. Omit it for the house glyph, pass a node to
   * replace it, pass `false` to take it away — the same three-way spelling Alert
   * uses for the same idea.
   */
  icon?: React.ReactNode | false;
  /** What was said. */
  children?: React.ReactNode;
}

/**
 * The quote itself, one step above body copy with the leading opened up.
 *
 * The sizes are `sheetTitleClasses`', because a quote is set at a heading's
 * scale — but the leading is not: a title is a line or two and a quote is a
 * paragraph somebody has to read, so it gets the air a paragraph needs.
 */
const quoteTextClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]/[1.25rem]',
  sm: 'text-[0.8125rem]/[1.375rem]',
  md: 'text-[0.9375rem]/[1.625rem]',
  lg: 'text-[1.0625rem]/[1.875rem]',
  xl: 'text-[1.25rem]/[2.125rem]'
};

/**
 * The rule down the leading edge, and the one thing every variant has.
 *
 * `border-s`, not `border-l`: the rule belongs on the side the text starts on,
 * which is the right edge under RTL. Its width is the one number here that does
 * not come off a ladder — a quote rule is 2px at every size, because it is a
 * mark in the margin rather than a part of the type.
 */
const ruleClasses = 'border-s-2 [border-inline-start-color:var(--n-accent)]';

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Box and List. A quote holds somebody else's words, and
 * words on a tinted panel are words on a background nobody chose them against.
 *
 * `text` is the default and the one that belongs in running prose: a rule in the
 * margin and nothing else, which is what a quote has looked like since long
 * before there were surfaces to put one on.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  // `border-s-2` again, after `border`, so the hairline on the other three edges
  // does not flatten the rule back to a pixel.
  outline: [
    surfaceClasses,
    'border border-s-2 bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'bg-transparent'
};

/**
 * The quotation mark: a pair of commas turned up, drawn rather than typed.
 *
 * A real `“` would be set in whatever face the page uses and would change shape,
 * weight and baseline with it — and at 2em it is the largest single glyph in the
 * component, so it changing is the most visible thing that could. This is one
 * drawing at one weight, and it lives here rather than in `internal/icons.tsx`
 * because exactly one component draws it.
 */
function QuoteMarkIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.4 3.6c-2.3.9-3.7 2.8-3.7 5.1 0 2 1.2 3.3 2.8 3.3 1.4 0 2.5-1 2.5-2.4 0-1.3-.9-2.2-2.1-2.2-.2 0-.4 0-.6.1.3-1 1.1-1.8 2.2-2.3l-1.1-1.6ZM13.3 3.6c-2.3.9-3.7 2.8-3.7 5.1 0 2 1.2 3.3 2.8 3.3 1.4 0 2.5-1 2.5-2.4 0-1.3-.9-2.2-2.1-2.2-.2 0-.4 0-.6.1.3-1 1.1-1.8 2.2-2.3l-1.1-1.6Z"
        fill="currentColor"
      />
    </svg>
  );
}

/**
 * Somebody else's words, set apart from your own.
 *
 * There is no Base UI primitive under this and there should not be: a quote has
 * no state, no keyboard contract and nothing to interact with. What it has is
 * markup that is easy to get wrong, and getting it right is most of the point.
 *
 * **Nothing is drawn on the `<blockquote>` itself.** The surface, the rule and
 * the padding all belong to the element around it, and that is not tidiness —
 * `blockquote` is one of the handful of tags a host stylesheet still styles by
 * name. VitePress's `.vp-doc blockquote` sets a grey `border-left`, a
 * `padding-left` and a `color`, all at a specificity a one-class utility cannot
 * outrank, so a rule drawn on the quote itself would silently come out grey and
 * a pixel too thin. Moving the drawing onto a wrapper is what lets the docs undo
 * VitePress's version in `scope.css` without also undoing ours.
 *
 * The wrapper is a `<figure>` when there is an attribution and a `<div>` when
 * there is not, because the HTML spec is explicit that the attribution goes
 * *outside* the blockquote — a name inside it claims the speaker said their own
 * name — and a `<figure>` with no `<figcaption>` in it is a figure of nothing.
 */
export const Blockquote = React.forwardRef<HTMLElement, BlockquoteProps>(function Blockquote(
  {
    variant = 'text',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    author,
    source,
    cite,
    icon,
    transition,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const animation = transitionProps(transition);
  const attributed = hasContent(author) || hasContent(source);
  const glyph = icon === undefined ? <QuoteMarkIcon /> : icon;

  const shellClasses = [
    'flex flex-col text-(--neba-fg)',
    ruleClasses,
    // A quote is never a pill, and the corners on the ruled edge stay square: a
    // 2px rule that curves away from the text it marks is a bracket, not a
    // margin rule.
    variant === 'text' ? '' : `${radiusClasses[size]} rounded-s-none`,
    variantClasses[variant],
    boxPaddingClasses[density][size],
    transitionClasses,
    animation.className,
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  const quote = (
    <blockquote cite={cite} className={quoteTextClasses[size]}>
      {hasContent(glyph) ? (
        // The mark tracks the quote's own type scale at twice its size, so one
        // drawing is the right size at every step of the ladder.
        <span
          aria-hidden="true"
          className="mb-1 block size-[2em] text-(--n-soft-press) [&>svg]:size-full"
        >
          {glyph}
        </span>
      ) : null}
      {children}
    </blockquote>
  );

  const shellStyle = { ...surfaceSlots(color, elevation), ...animation.style, ...style };

  if (!attributed) {
    return (
      <div
        ref={ref as React.Ref<HTMLDivElement>}
        className={shellClasses}
        style={shellStyle}
        {...props}
      >
        {quote}
      </div>
    );
  }

  return (
    <figure ref={ref} className={shellClasses} style={shellStyle} {...props}>
      {quote}

      <figcaption
        className={[
          'mt-2 flex flex-wrap items-baseline gap-x-1.5 text-(--neba-muted-fg)',
          metaTextClasses[size]
        ].join(' ')}
      >
        {hasContent(author) ? (
          <span className="font-medium text-(--neba-fg)">
            {/* An em dash, the way an attribution has been set since print, and
                `aria-hidden` because a screen reader announcing "em dash" before
                a name is reading the typography rather than the text. */}
            <span aria-hidden="true">— </span>
            {author}
          </span>
        ) : null}
        {/* `<cite>` arrives italic from the browser's own stylesheet. The library
            has one type scale and italics are not on it. */}
        {hasContent(source) ? <cite className="not-italic">{source}</cite> : null}
      </figcaption>
    </figure>
  );
});

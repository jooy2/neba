'use client';

import * as React from 'react';
import { TextLink } from '../text-link/TextLink.js';
import {
  fillMessage,
  linkMessages,
  sourcesMessages,
  useMessages,
  type SourcesMessages
} from '../../internal/i18n.js';
import { opensElsewhere, safeHref, safeRel } from '../../internal/link.js';
import {
  citationMarkClasses,
  cx,
  focusRingClasses,
  hasContent,
  metaTextClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

type HoverCardModule = typeof import('../hover-card/HoverCard.js');

/** The preview's card once its chunk has arrived, for every citation on the page. */
let cardModule: HoverCardModule | undefined;
let cardRequest: Promise<HoverCardModule> | undefined;

/**
 * The preview's card, fetched only when somebody reaches for a citation.
 *
 * A HoverCard is Base UI's preview card and everything it positions with, which
 * was 34 kB of the 39 kB a citation weighed against the 5.6 kB of a TextLink —
 * carried by every answer with a footnote in it, whether anybody hovered one or
 * not. So this is the Image viewer's arrangement: the mark is drawn bare, and
 * the chunk is asked for when a pointer arrives over it, when the focus reaches
 * it or when a finger lands on it. The card's own delay before it opens is
 * longer than the fetch usually takes. A request that fails is forgotten, so
 * the next reach tries again rather than failing for good.
 *
 * An object rather than a function so a test can spy on it. Exported for that,
 * and deliberately left out of the barrel.
 */
export const hoverCardChunk = {
  load(): Promise<HoverCardModule> {
    cardRequest ??= import('../hover-card/HoverCard.js').then(
      (module) => {
        cardModule = module;

        return module;
      },
      (error: unknown) => {
        cardRequest = undefined;

        throw error;
      }
    );

    return cardRequest;
  }
};

/**
 * Where the mouse last was, kept by one listener per document from the first
 * time a citation is reached for. The hand-over asks the page what is under
 * that point rather than trusting the last event the old mark saw: a pointer
 * that left while the card's chunk was arriving told nobody, because the
 * element it left was already gone.
 */
let pointerAt: { x: number; y: number } | null = null;
const followed = new WeakSet<Document>();

function followPointer(doc: Document, x: number, y: number): void {
  pointerAt = { x, y };

  if (followed.has(doc)) {
    return;
  }

  followed.add(doc);
  doc.addEventListener(
    'pointermove',
    (event) => {
      pointerAt = { x: event.clientX, y: event.clientY };
    },
    { capture: true, passive: true }
  );
}

/**
 * Tells a trigger that has just replaced the element under a resting pointer
 * that the pointer is on it, and, if the first move after that is somewhere
 * else, that it has left. Returns what stops listening for that move. See the
 * hand-over in the component.
 */
function handPointerTo(node: HTMLElement): () => void {
  const doc = node.ownerDocument;
  const firstMove = (event: PointerEvent) => {
    doc.removeEventListener('pointermove', firstMove, true);

    if (!(event.target instanceof Node) || !node.contains(event.target)) {
      node.dispatchEvent(
        new MouseEvent('mouseleave', {
          clientX: event.clientX,
          clientY: event.clientY,
          relatedTarget: event.target
        })
      );
    }
  };

  node.dispatchEvent(new MouseEvent('mouseenter'));
  doc.addEventListener('pointermove', firstMove, true);

  return () => doc.removeEventListener('pointermove', firstMove, true);
}

export interface InlineCitationProps extends Omit<
  React.ComponentPropsWithoutRef<'a'>,
  'color' | 'title' | 'children'
> {
  /**
   * Which source this is, and the only thing the mark itself says. It is the
   * caller's number rather than one counted here: a citation sits in a
   * paragraph, and the list it points at is somewhere else on the page.
   */
  index: number;
  /** The heading of the preview. Without it there is nothing to preview. */
  title?: React.ReactNode;
  /** The line under it — the passage that was used, the publisher, a date. */
  description?: React.ReactNode;
  /** Where it came from, set beside the title in the preview. */
  site?: React.ReactNode;
  /**
   * Where the citation points. A scheme outside `http`, `https`, `mailto` and
   * `tel` leaves the mark as plain text rather than writing the URL out. Without
   * one the mark is a `<span>`, which takes the keyboard focus only when it has
   * a preview to open.
   */
  href?: string;
  /** Where the link opens. `rel` gains `noopener noreferrer` whenever it leaves the tab. */
  target?: string;
  /**
   * Shows the preview on hover and on focus. Off, the mark is a bare link, and
   * the reader has the list at the bottom of the answer and nothing else.
   * @default true
   */
  preview?: boolean;
  /** The type scale of the preview. The mark itself is sized in `em`. @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** Which language the mark's accessible name is written in, as a BCP 47 tag. */
  locale?: string;
  /** That sentence, written out. Overrides the `locale`'s. */
  labels?: Partial<SourcesMessages>;
}

/**
 * A numbered footnote in the body of an answer, with the source behind it a
 * hover away.
 *
 * The mark is the same square a [Sources](./sources) row draws, and that is the
 * whole arrangement: a reader sees `2` in a sentence and finds `2` in the list
 * underneath. Both read one class from `internal/styles.ts`, because two
 * drawings of one number is two chances for the pair to stop matching.
 *
 * `index` is the caller's rather than counted here. A citation sits inside a
 * paragraph and the list it points at is somewhere else on the page, so there
 * is no parent that could number it — and a component that numbered itself by
 * render order would renumber the whole answer whenever a sentence moved.
 *
 * The preview arrives in a chunk of its own, on the first reach — see
 * `hoverCardChunk`. Until then the mark is drawn bare, which is also what a
 * server renders.
 */
export const InlineCitation = React.forwardRef<HTMLElement, InlineCitationProps>(
  function InlineCitation(rawProps, ref) {
    const {
      index,
      title,
      description,
      site,
      href,
      target,
      rel,
      preview = true,
      size = 'md',
      color = 'primary',
      locale,
      labels,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    /*
     * Whether this mark has been reached for and the card's chunk is here.
     *
     * Set once the module has arrived rather than handed to `React.lazy`. A lazy
     * component suspends on its first render even when its chunk is already in,
     * and the boundary that catches it would draw a second copy of the mark for
     * a frame, taking the focus and the pointer away from the one being used. A
     * module that is here is simply rendered. The mark is still swapped once,
     * for the card's own trigger, and the effect below hands it what the old one
     * had: the focus, and a pointer resting on it.
     */
    const [ready, setReady] = React.useState(false);
    // Whether the mark holds the focus, and whether a mouse has come to rest on
    // it, as of the last event it saw.
    const focused = React.useRef(false);
    const hovered = React.useRef(false);

    const reach = () => {
      hoverCardChunk.load().then(
        () => setReady(true),
        () => {}
      );
    };

    const handlers = {
      onPointerEnter: (event: React.PointerEvent<HTMLElement>) => {
        props.onPointerEnter?.(event as React.PointerEvent<HTMLAnchorElement>);
        hovered.current = event.pointerType === 'mouse' || event.pointerType === 'pen';

        if (hovered.current) {
          followPointer(event.currentTarget.ownerDocument, event.clientX, event.clientY);
        }

        reach();
      },
      onPointerLeave: (event: React.PointerEvent<HTMLElement>) => {
        props.onPointerLeave?.(event as React.PointerEvent<HTMLAnchorElement>);
        hovered.current = false;
      },
      onTouchStart: (event: React.TouchEvent<HTMLElement>) => {
        props.onTouchStart?.(event as React.TouchEvent<HTMLAnchorElement>);
        reach();
      },
      onFocus: (event: React.FocusEvent<HTMLElement>) => {
        props.onFocus?.(event as React.FocusEvent<HTMLAnchorElement>);
        focused.current = true;
        reach();
      },
      onBlur: (event: React.FocusEvent<HTMLElement>) => {
        props.onBlur?.(event as React.FocusEvent<HTMLAnchorElement>);
        focused.current = false;
      }
    };

    // The mark as it is now, which the swap replaces, and the caller's ref.
    const node = React.useRef<HTMLElement | null>(null);
    const attach = React.useCallback(
      (element: HTMLElement | null) => {
        node.current = element;

        if (typeof ref === 'function') {
          ref(element);
        } else if (ref) {
          (ref as React.MutableRefObject<HTMLElement | null>).current = element;
        }
      },
      [ref]
    );

    /*
     * What the old mark had, carried across the swap. After the card's own
     * effects have run, which is where its trigger starts listening.
     *
     * The focus: the mark that held it is taken out of the page when the card's
     * trigger replaces it, and it falls to the body. The new mark takes it back,
     * which is also what opens the card for a reader on the keyboard.
     *
     * A pointer resting on it: the card opens on the trigger's `mouseenter`,
     * and the new element under a pointer that has not moved is not entered —
     * Firefox reports nothing until the pointer moves, and then nothing at all
     * if that move already leaves the mark. So if the pointer is still over the
     * trigger, it is told it was entered, and if the first move lands outside
     * it, that it was left, which is what lets the card close again.
     */
    React.useEffect(() => {
      const trigger = node.current;

      if (!ready || !trigger) {
        return undefined;
      }

      const doc = trigger.ownerDocument;

      if (focused.current && doc.activeElement !== trigger) {
        trigger.focus();
      }

      const under =
        hovered.current && pointerAt ? doc.elementFromPoint(pointerAt.x, pointerAt.y) : null;

      return under && trigger.contains(under) ? handPointerTo(trigger) : undefined;
    }, [ready]);

    const messages = useMessages(sourcesMessages, locale);
    const linkWords = useMessages(linkMessages, locale);
    const words = { ...messages, ...labels };
    const name = fillMessage(words.citation, { index: String(index) });
    const address = safeHref(href);
    const previews = preview && hasContent(title);

    // Not a superscript. A `<sup>` shrinks the number a second time on top of
    // the `0.8em` the mark already is, and at that size a digit in a tinted box
    // is a smudge rather than a number a reader can act on.
    const shared = {
      className: cx(
        citationMarkClasses,
        'align-[0.15em] no-underline',
        address ? 'cursor-pointer' : 'cursor-default',
        'hover:bg-(--n-soft-hover)',
        focusRingClasses,
        transitionClasses,
        className ?? ''
      ),
      style: {
        '--n-soft': `var(--neba-${color}-soft)`,
        '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
        '--n-on-tint': `var(--neba-${color}-on-tint)`,
        '--n-ring': `var(--neba-${color}-ring)`,
        ...style
      } as React.CSSProperties
    };

    /*
     * With no address there is no link, and an `<a>` without an `href` is not
     * one: it takes no focus, and an `aria-label` on an element with no role is
     * one a screen reader may not read. So the mark is a `<span>` that says its
     * name in text, and takes the focus only when there is a preview for the
     * focus to open.
     */
    const mark = address ? (
      <a
        ref={attach}
        href={address}
        target={target}
        rel={safeRel(target, rel)}
        // The name is the whole of what is read, so the words that say the link
        // opens a new tab go into it rather than beside it.
        aria-label={opensElsewhere(target) ? `${name} ${linkWords.newTab}` : name}
        {...shared}
        {...props}
        {...(previews ? handlers : null)}
      >
        {index}
      </a>
    ) : (
      <span
        ref={attach}
        tabIndex={previews ? 0 : undefined}
        {...shared}
        {...(props as React.HTMLAttributes<HTMLSpanElement>)}
        {...(previews ? handlers : null)}
      >
        <span className={srOnlyClasses}>{name}</span>
        <span aria-hidden="true">{index}</span>
      </span>
    );

    const HoverCard = ready ? cardModule?.HoverCard : undefined;

    if (!previews || !HoverCard) {
      return mark;
    }

    return (
      <HoverCard
        size={size}
        color={color}
        trigger={mark}
        title={
          address ? (
            <TextLink
              href={address}
              underline="hover"
              target={target}
              rel={safeRel(target, rel)}
              locale={locale}
            >
              {title}
            </TextLink>
          ) : (
            title
          )
        }
        description={site}
      >
        {hasContent(description) ? (
          <span className={cx('text-(--neba-muted-fg)', metaTextClasses[size])}>{description}</span>
        ) : null}
      </HoverCard>
    );
  }
);

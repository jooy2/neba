'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { spoilerMessages, useMessages } from '../../internal/i18n.js';
import { boxPaddingClasses, boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../../types.js';

export interface SpoilerProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'onChange'
> {
  /** Whether the content is uncovered. Pass it to drive the Spoiler yourself. */
  revealed?: boolean;
  /**
   * Where an uncontrolled Spoiler starts.
   * @default false
   */
  defaultRevealed?: boolean;
  /** Called when the reveal or hide button is pressed. */
  onRevealedChange?: (revealed: boolean) => void;
  /**
   * Which language the default label and notice are written in — a BCP 47 tag
   * such as `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   *
   * Both strings can be written out instead, in `label` and `description`; this
   * is for the far more common case where the page already knows its language
   * and nobody should have to translate a button that says "Reveal".
   */
  locale?: string;
  /** The reveal button's label. Defaults to the `locale`'s word for it. */
  label?: React.ReactNode;
  /** The hide button's label, when `reversible` is on. */
  hideLabel?: React.ReactNode;
  /**
   * The line above the button, saying why the content is covered. Defaults to
   * the `locale`'s wording; pass `false` for a cover with nothing written on it.
   */
  description?: React.ReactNode | false;
  /**
   * Replaces the default reveal button entirely.
   *
   * The replacement is yours to wire up: pass `revealed` and
   * `onRevealedChange` and drive it from your own control. `label` is the prop
   * for the far commoner case of wanting different words on the button that is
   * already there.
   */
  action?: React.ReactNode;
  /**
   * Keeps the content coverable: once revealed, a hide button appears under it.
   * @default false
   */
  reversible?: boolean;
  /**
   * Clamps the covered box to this height — a CSS length, or a number in
   * pixels. Revealing releases it and the content takes whatever height it
   * needs.
   *
   * Left out, the box is exactly as tall as what it holds, which is the right
   * default for a paragraph or a picture. Set it for something long enough that
   * a page of blurred content would be a page of nothing.
   */
  maxHeight?: number | string;
  /**
   * How hard the content is blurred, in pixels.
   * @default 10
   */
  blur?: number;
  /**
   * Inner padding around the content, on Box's own `size`/`density` scale. Turn
   * it off for something that should reach the edges — a picture, a video.
   * @default true
   */
  padded?: boolean;
  /**
   * Weight of the box's surface. `text` draws no box at all, which is what a
   * spoiler sitting inside running prose usually wants.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** The sheet's radius, and the size of the button on it. @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** Padding around the cover's own text and button. @default 'default' */
  density?: NebaDensity;
  /** Drop shadow depth. `0` (the default) is flat. @default 0 */
  elevation?: NebaElevation;
  /** What is being covered. */
  children?: React.ReactNode;
}

/**
 * The same three weights, with the deviation every container in the library
 * makes: `solid` does not flood the sheet with the colour family.
 *
 * What a Spoiler holds is other people's content — a photograph, a paragraph,
 * a plot twist — and it arrives with its own colours. The family shows up in
 * the hairline and on the button, and the sheet stays neutral.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'bg-transparent'
};

/**
 * The wash between the blurred content and the words on top of it.
 *
 * Blur alone is not cover. It takes a paragraph apart but leaves its colour and
 * its rhythm — a photograph blurred at 10px is still recognisably a photograph
 * of a face — and it leaves the button standing on whatever happened to be
 * underneath it. Mixing the page's own surface over the top settles both: the
 * content goes to a wash of its own colours, and the button gets something to
 * stand on.
 */
const scrimClasses = '[background-color:color-mix(in_oklab,var(--neba-surface)_55%,transparent)]';

/**
 * Content that is covered until somebody asks for it.
 *
 * The cover is a blur rather than a `display: none`, which is the whole point:
 * a reader can see that there is something there, roughly how much of it there
 * is, and — with `maxHeight` — that it has been clamped. What they cannot do is
 * read it by accident, which is the one thing a spoiler is for.
 *
 * While it is covered the content is `inert`, so it is not tabbable, not
 * readable by a screen reader and not selectable by a drag across the page. A
 * spoiler that could be defeated by Ctrl-A is not a spoiler.
 */
export const Spoiler = React.forwardRef<HTMLDivElement, SpoilerProps>(function Spoiler(
  {
    revealed,
    defaultRevealed = false,
    onRevealedChange,
    locale,
    label,
    hideLabel,
    description,
    action,
    reversible = false,
    maxHeight,
    blur = 10,
    padded = true,
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const messages = useMessages(spoilerMessages, locale);
  const contentId = React.useId();

  const [uncontrolled, setUncontrolled] = React.useState(defaultRevealed);
  const open = revealed ?? uncontrolled;

  const change = (next: boolean) => {
    if (revealed === undefined) {
      setUncontrolled(next);
    }

    onRevealedChange?.(next);
  };

  const notice = description === false ? null : (description ?? messages.notice);

  return (
    <div
      ref={ref}
      className={cx(
        'relative isolate overflow-hidden',
        radiusClasses[size],
        variantClasses[variant],
        transitionClasses,
        className ?? ''
      )}
      style={{ ...surfaceSlots(color, elevation), ...style }}
      {...props}
    >
      <div
        id={contentId}
        className={cx(
          'min-w-0',
          padded ? boxPaddingClasses[density][size] : '',
          '[transition:filter_var(--neba-duration-fill)_var(--neba-ease)]',
          'motion-reduce:[transition-duration:0ms]',
          open ? '' : 'select-none'
        )}
        style={{
          filter: open ? undefined : `blur(${blur}px)`,
          // The clamp is only ever on the covered state: revealing something and
          // leaving it in a box with a scrollbar is answering the wrong question.
          maxHeight: open ? undefined : maxHeight,
          overflow: open ? undefined : 'hidden'
        }}
        // `inert` rather than `aria-hidden`, the same choice Pill makes for a
        // collapsed panel: it takes the content out of the tab order, off the
        // accessibility tree and out of the selection in one attribute, and
        // `aria-hidden` alone would leave a keyboard reader tabbing into a link
        // their screen reader has been told is not there.
        inert={!open}
      >
        {children}
      </div>

      {open ? null : (
        <div
          className={[
            'absolute inset-0 z-10 flex flex-col items-center justify-center gap-2 text-center',
            boxPaddingClasses[density][size],
            scrimClasses
          ].join(' ')}
        >
          {hasContent(notice) ? (
            <p className={`m-0 text-(--neba-muted-fg) ${metaTextClasses[size]}`}>{notice}</p>
          ) : null}

          {action ?? (
            <Button
              size={size}
              color={color}
              density={density}
              onClick={() => change(true)}
              aria-expanded={false}
              aria-controls={contentId}
            >
              {label ?? messages.reveal}
            </Button>
          )}
        </div>
      )}

      {open && reversible ? (
        <div
          className={[
            'flex justify-end',
            boxPaddingXClasses[density][size],
            // The row takes the sheet's padding on both axes and then gives the
            // top back: `padded` content already ends with a full gap, and two
            // of them stacked is a hole between the text and the way back out.
            // `pt-0` beating `py-*` is Tailwind's own longhand-after-shorthand
            // ordering rather than an accident of how these are concatenated.
            boxPaddingYClasses[density][size],
            'pt-0'
          ].join(' ')}
        >
          <Button
            variant="text"
            size={size}
            color={color}
            density={density}
            onClick={() => change(false)}
            aria-expanded
            aria-controls={contentId}
          >
            {hideLabel ?? messages.hide}
          </Button>
        </div>
      ) : null}
    </div>
  );
});

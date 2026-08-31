'use client';

import * as React from 'react';
import { AspectRatio } from '../aspect-ratio/AspectRatio.js';
import { Dialog } from '../dialog/Dialog.js';
import { Skeleton } from '../skeleton/Skeleton.js';
import { cx, radiusClasses, transitionClasses } from '../../internal/styles.js';
import type { NebaAspectFit } from '../aspect-ratio/AspectRatio.js';
import type { NebaSize, NebaSlots } from '../../types.js';

/** The parts an Image draws behind its root. */
export type ImageSlot = 'image' | 'placeholder' | 'fallback';

/**
 * The four fits, written out.
 *
 * Not `object-${fit}`: Tailwind only ever sees class names that are written
 * literally, so a template literal generates nothing and the picture falls back
 * to `fill` — which is the design language's rule about per-instance values in
 * its plainest form.
 */
const objectFitClasses: Record<NebaAspectFit, string> = {
  cover: 'object-cover',
  contain: 'object-contain',
  fill: 'object-fill',
  none: 'object-none'
};

/** Where the picture is in its own life. */
type Phase = 'loading' | 'loaded' | 'failed';

export interface ImageProps extends Omit<
  React.ComponentPropsWithoutRef<'img'>,
  'width' | 'height' | 'children'
> {
  /** Required, and required to be right. See the note on the component. */
  alt: string;
  /**
   * The proportion to hold while the file is still arriving.
   *
   * This is the whole reason to use this over an `<img>`: a picture with no
   * reserved box is a picture that pushes the page down when it lands, which is
   * the single largest source of layout shift on most sites. `'auto'` opts out
   * and lets the file decide, which is right only when the space around it can
   * absorb the jump.
   * @default 'auto'
   */
  ratio?: number | string | 'auto';
  /** How the picture fills that box. @default 'cover' */
  fit?: NebaAspectFit;
  /** Rounds the corners at this step of the radius ladder. `false` for square. */
  rounded?: NebaSize | boolean;
  /**
   * What stands in while the file is arriving. A Skeleton of the right shape by
   * default, `false` for nothing at all.
   */
  placeholder?: React.ReactNode | false;
  /**
   * What is drawn instead when the file does not arrive.
   *
   * Something rather than nothing by default: a broken image icon is the
   * browser telling the reader that the *page* is broken, and a box that says
   * what was meant to be there is a better answer than a blank space.
   */
  fallback?: React.ReactNode;
  /** Called when the file fails. Useful for swapping a `src` you control. */
  onLoadingStatusChange?: (status: Phase) => void;
  /**
   * Opens the full picture in a Dialog when it is clicked.
   *
   * The picture becomes a button when this is on, so it is reachable by
   * keyboard — an image you can only enlarge with a pointer is an image half
   * the readers cannot enlarge.
   * @default false
   */
  preview?: boolean;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ImageSlot>;
}

/**
 * A picture that holds its space, says when it is loading and says when it
 * failed.
 *
 * An `<img>` does none of those three, and each is a real defect rather than a
 * nicety: an unsized picture shoves the page down when it lands, a slow one
 * leaves a hole with no explanation, and a broken one draws the browser's own
 * torn-page glyph, which tells a reader the site is broken rather than that one
 * file is missing.
 *
 * `alt` is required by the type, which is deliberate and is the one place this
 * component is stricter than the tag it wraps. A missing `alt` and an empty one
 * mean different things — "nobody wrote this" and "this picture says nothing a
 * reader needs" — and only the second is ever correct. Being made to type
 * `alt=""` is being made to say which one you meant.
 */
export const Image = React.forwardRef<HTMLImageElement, ImageProps>(function Image(
  {
    alt,
    ratio = 'auto',
    fit = 'cover',
    rounded = false,
    placeholder,
    fallback,
    onLoadingStatusChange,
    preview = false,
    className,
    classNames,
    style,
    src,
    ...props
  },
  ref
) {
  const [phase, setPhase] = React.useState<Phase>('loading');
  const [open, setOpen] = React.useState(false);

  // A `src` that changes is a different picture, so it starts over. Without
  // this a second file inherits the first one's "loaded" and never shows a
  // placeholder — and a second file that fails inherits a success.
  React.useEffect(() => {
    setPhase('loading');
  }, [src]);

  const settle = (next: Phase) => {
    setPhase(next);
    onLoadingStatusChange?.(next);
  };

  const radius = rounded === false ? '' : radiusClasses[rounded === true ? 'md' : rounded];

  const picture = (
    <img
      ref={ref}
      src={src}
      alt={alt}
      className={cx(
        'block size-full',
        objectFitClasses[fit],
        radius,
        transitionClasses,
        // Faded in rather than swapped in: a picture that appears at full
        // strength the instant it decodes is the same jolt as one that resizes.
        phase === 'loaded' ? 'opacity-100' : 'opacity-0',
        classNames?.image
      )}
      onLoad={() => settle('loaded')}
      onError={() => settle('failed')}
      {...props}
    />
  );

  const cover =
    phase === 'failed' ? (
      <span
        className={cx(
          'absolute inset-0 flex items-center justify-center',
          'bg-(--neba-disabled-bg) text-(--neba-muted-fg)',
          radius,
          classNames?.fallback
        )}
      >
        {fallback ?? <span className="px-2 text-center text-sm">{alt || 'Image unavailable'}</span>}
      </span>
    ) : phase === 'loading' && placeholder !== false ? (
      <span className={cx('absolute inset-0', classNames?.placeholder)}>
        {placeholder ?? <Skeleton shape="rect" className={cx('size-full', radius)} />}
      </span>
    ) : null;

  // One stack — the picture with whatever is standing over it — wrapped either
  // in a box that holds a proportion or in one that does not.
  const stack = (
    <span className="relative block size-full">
      {picture}
      {cover}
    </span>
  );

  const framed =
    ratio === 'auto' ? (
      <span className={cx('relative block overflow-hidden', radius, className)} style={style}>
        {stack}
      </span>
    ) : (
      // `fit` is already on the `<img>`; AspectRatio's own is for a direct
      // child, and the stack is in the way.
      <AspectRatio ratio={ratio} className={cx('overflow-hidden', radius, className)} style={style}>
        {stack}
      </AspectRatio>
    );

  if (!preview) {
    return framed;
  }

  return (
    <>
      <button
        type="button"
        // The accessible name is the picture's own: two names for one thing is
        // a screen reader reading the same sentence twice.
        aria-label={alt}
        className={cx(
          'block w-full cursor-zoom-in [outline:none]',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:2px]',
          radius
        )}
        onClick={() => setOpen(true)}
      >
        {framed}
      </button>

      <Dialog open={open} onOpenChange={setOpen} size="xl" title={alt}>
        <img src={src} alt={alt} className="mx-auto block max-h-[70vh] w-auto max-w-full" />
      </Dialog>
    </>
  );
});

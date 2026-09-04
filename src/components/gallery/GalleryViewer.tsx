'use client';

import * as React from 'react';
import { Dialog } from '../dialog/Dialog.js';
import { IconButton } from '../icon-button/IconButton.js';
import { Image } from '../image/Image.js';
import { ChevronIcon } from '../../internal/icons.js';
import { fill } from '../../internal/i18n.js';
import { cx, metaTextClasses } from '../../internal/styles.js';
import type { GalleryMessages } from '../../internal/i18n.js';
import type { NebaImageProtection, NebaImageWatermark } from '../image/Image.js';
import type { NebaGalleryItem } from './Gallery.js';

export interface GalleryViewerProps {
  items: readonly NebaGalleryItem[];
  /** Which picture is open, or `null` for none. */
  index: number | null;
  onIndexChange: (index: number | null) => void;
  locale?: string;
  watermark?: NebaImageWatermark;
  protect?: boolean | NebaImageProtection;
  /** Resolved by the Gallery, so the viewer resolves nothing a second time. */
  messages: GalleryMessages;
}

/**
 * One picture from a Gallery, full size, with the rest of the set an arrow key
 * away.
 *
 * A file of its own rather than a branch inside `Gallery`, and that is the
 * whole point of it: this is the only thing in the component that needs a
 * Dialog, and a Dialog is more than the gallery that opens it. Reached through
 * `React.lazy`, a wall of thumbnails costs nothing for a viewer nobody opened.
 *
 * The picture is not a Carousel. A carousel is a set somebody is being shown in
 * order, and this is one picture with a way to the next — so there is no
 * autoplay, no wrap, and the arrows stop at the ends rather than looping back
 * to a photograph the reader has already seen.
 */
export function GalleryViewer({
  items,
  index,
  onIndexChange,
  locale,
  watermark,
  protect,
  messages
}: GalleryViewerProps) {
  const open = index !== null;
  const current = index === null ? undefined : items[index];
  const atStart = index === null || index <= 0;
  const atEnd = index === null || index >= items.length - 1;

  const go = (to: number) => {
    if (to >= 0 && to < items.length) onIndexChange(to);
  };

  /*
   * The arrows are bound on the dialog rather than on the buttons, because the
   * focus is wherever the reader last put it — on a button, on the picture, on
   * the × — and a key that only worked from one of those is a key that looks
   * broken from the other two. Escape is Base UI's and is left alone.
   */
  const onKeyDown = (event: React.KeyboardEvent) => {
    if (index === null || event.metaKey || event.ctrlKey || event.altKey) return;

    if (event.key === 'ArrowRight') {
      event.preventDefault();
      go(index + 1);
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault();
      go(index - 1);
    }
  };

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onIndexChange(null);
      }}
      size="xl"
      locale={locale}
      title={current?.title ?? current?.alt ?? ''}
      description={current?.description}
      onKeyDown={onKeyDown}
    >
      <div className="flex flex-col gap-3">
        <div className="relative flex items-center justify-center">
          {current ? (
            <Image
              // Keyed on the picture, so moving to the next one starts its own
              // load rather than showing the previous file under a new caption.
              key={current.id ?? current.src}
              src={current.full ?? current.src}
              alt={current.alt}
              ratio="auto"
              fit="contain"
              rounded="md"
              watermark={watermark}
              protect={protect}
              className="max-h-[70vh] w-auto"
              classNames={{ image: 'max-h-[70vh] w-auto object-contain' }}
            />
          ) : null}

          {items.length > 1 ? (
            <div className="pointer-events-none absolute inset-x-0 flex items-center justify-between px-1">
              <IconButton
                variant="solid"
                elevation={1}
                label={messages.previous}
                disabled={atStart}
                className="pointer-events-auto"
                // Drawn pointing down and turned, which is the one allowance the
                // no-transform rule makes — and turned the other way under RTL,
                // where "previous" is on the other side of the frame.
                icon={
                  <span className="flex items-center rotate-90 rtl:-rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go((index ?? 0) - 1)}
              />
              <IconButton
                variant="solid"
                elevation={1}
                label={messages.next}
                disabled={atEnd}
                className="pointer-events-auto"
                icon={
                  <span className="flex items-center -rotate-90 rtl:rotate-90">
                    <ChevronIcon />
                  </span>
                }
                onClick={() => go((index ?? 0) + 1)}
              />
            </div>
          ) : null}
        </div>

        {items.length > 1 ? (
          <p
            className={cx('m-0 text-center text-(--neba-muted-fg)', metaTextClasses.md)}
            // Announced when it changes, so an arrow key says where it landed
            // to a reader who cannot see the picture it landed on.
            aria-live="polite"
          >
            {fill(messages.item, {
              index: String((index ?? 0) + 1),
              total: String(items.length)
            })}
          </p>
        ) : null}
      </div>
    </Dialog>
  );
}

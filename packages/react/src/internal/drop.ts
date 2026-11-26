'use client';

/**
 * What a drop actually handed over, and the state of the box it landed on.
 *
 * Two components take dropped files — a
 * [FilePicker](../components/inputs/file-picker), and a
 * [PromptInput](../components/agent/prompt-input) whose shell is a drop target
 * — and both have to get the same things right. None of them is hard; all of
 * them are the kind of thing that is written correctly once and approximately
 * the second time.
 */

import * as React from 'react';

/**
 * Whether what was dropped is a file at all.
 *
 * A folder dragged onto a page arrives in `dataTransfer.files` as a `File` with
 * no type and a size of zero, and there is no flag on it that says so. The only
 * thing that does is `webkitGetAsEntry`, which is on the *item* rather than on
 * the file — so the two lists are walked in step, and a browser too old to have
 * it is left trusting what it was given.
 *
 * Silently accepting a folder is worse than refusing it: it goes into the list
 * looking like a file, and the upload that follows sends nothing.
 */
export function droppedFiles(transfer: DataTransfer): File[] {
  const items = [...transfer.items];
  const files = [...transfer.files];

  // The two out of step means the browser has told us nothing we can line up,
  // so the files are returned as they are rather than filtered by the wrong
  // index.
  if (items.length !== files.length) {
    return files;
  }

  return files.filter((_, index) => {
    const entry = items[index]?.webkitGetAsEntry?.();

    return entry ? entry.isFile : true;
  });
}

/**
 * Whether a drag is carrying files.
 *
 * `types` is all a page may read of a drag until it is dropped, and a file is
 * the type `Files`. Anything else — text selected somewhere and dragged, a link
 * — is left to the browser, which for a field means inserting it.
 */
function carriesFiles(event: React.DragEvent): boolean {
  return [...(event.dataTransfer?.types ?? [])].includes('Files');
}

/** What a drop zone hands back: whether a drag is over it, and the listeners. */
export interface DropZone {
  /** A drag is over the zone right now. Always `false` while it is off. */
  over: boolean;
  /**
   * Spread onto the element that *is* the zone — the whole area a drop is a
   * gesture over, rather than the control inside it.
   */
  handlers: {
    onDragEnter?: React.DragEventHandler;
    onDragOver?: React.DragEventHandler;
    onDragLeave?: React.DragEventHandler;
    onDrop?: React.DragEventHandler;
  };
}

/**
 * An area that takes dropped files.
 *
 * `accept` is called with the files, folders already filtered out, and never
 * with none. Pass `undefined` and the zone is off: no listeners at all, and
 * `over` never turns true — which is what a disabled or read-only control
 * wants, and what a component with nothing to do with files wants.
 *
 * Three details are the whole reason this is shared rather than written twice.
 *
 * **Only a drag with files in it.** Every other drag is let through untouched:
 * text dragged into a PromptInput is the field's to insert, and a zone that
 * took it would light up, swallow the text and report no files.
 *
 * **The depth count.** `dragenter` and `dragleave` fire for every child the
 * pointer crosses, so a boolean flickers the entire time a file is over a box
 * with anything in it — which is every box worth dropping on.
 *
 * **The drag that never comes back.** Escape cancels a drag, and a drop outside
 * the window ends it somewhere the zone will never hear about; neither fires a
 * `dragleave` here, so the counter stays up and the box keeps its lit edge
 * until some later drag happens to balance it. `dragend` fires on the source
 * and `drop` on whatever accepted it, so both are listened for at the document,
 * with capture.
 */
export function useDropZone(accept: ((files: File[]) => void) | undefined): DropZone {
  const depth = React.useRef(0);
  const [over, setOver] = React.useState(false);
  const enabled = accept !== undefined;

  React.useEffect(() => {
    if (!enabled) {
      return undefined;
    }

    const clear = () => {
      depth.current = 0;
      setOver(false);
    };

    document.addEventListener('dragend', clear, true);
    document.addEventListener('drop', clear, true);

    return () => {
      document.removeEventListener('dragend', clear, true);
      document.removeEventListener('drop', clear, true);
    };
  }, [enabled]);

  if (!enabled) {
    return { over: false, handlers: {} };
  }

  return {
    over,
    handlers: {
      onDragEnter: (event) => {
        if (!carriesFiles(event)) {
          return;
        }

        event.preventDefault();
        depth.current += 1;
        setOver(true);
      },
      onDragOver: (event) => {
        if (!carriesFiles(event)) {
          return;
        }

        // Without this the browser opens the file instead of dropping it, which
        // is the default and is never what anybody wants.
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
      },
      onDragLeave: (event) => {
        if (!carriesFiles(event)) {
          return;
        }

        depth.current = Math.max(0, depth.current - 1);

        if (depth.current === 0) {
          setOver(false);
        }
      },
      onDrop: (event) => {
        if (!carriesFiles(event)) {
          return;
        }

        event.preventDefault();
        depth.current = 0;
        setOver(false);

        // A drop of nothing but folders leaves nothing to hand over, and a call
        // with an empty list reads to a caller as a drop that cleared the list.
        const files = droppedFiles(event.dataTransfer);

        if (files.length > 0) {
          accept(files);
        }
      }
    }
  };
}

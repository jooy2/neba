'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { Dialog } from '../dialog/Dialog.js';
import { confirmMessages, useMessages } from '../../internal/i18n.js';
import type { NebaColor, NebaSize } from '../../types.js';

/** What a confirm asks, and how it is dressed. */
export interface ConfirmOptions {
  /** The question. The dialog's heading, and what a screen reader announces. */
  title?: React.ReactNode;
  /** What answering costs — the consequence, not a restatement of the title. */
  description?: React.ReactNode;
  /** Overrides the confirming button's label. Defaults to the locale's word. */
  confirmLabel?: React.ReactNode;
  /** Overrides the cancelling button's label. */
  cancelLabel?: React.ReactNode;
  /**
   * The colour family. `danger` for anything that destroys something, which is
   * what most confirms are for.
   */
  color?: NebaColor;
  size?: NebaSize;
  /**
   * Drops the cancelling button, leaving one way out.
   *
   * For telling rather than asking — a result the reader has to acknowledge.
   * It still resolves, always `true`, so the same `await` works either way.
   * @default false
   */
  alert?: boolean;
  /**
   * Whether Escape and a click on the backdrop answer *no*.
   *
   * Off makes a question the reader has to answer with a button. Use it for the
   * ones where an accidental dismissal is the expensive answer, and almost
   * never otherwise: a modal with no way out is the thing people report.
   * @default true
   */
  dismissible?: boolean;
  /** BCP 47 tag deciding the two default labels. Defaults to the provider's. */
  locale?: string;
  /** How wide the sheet is, passed to Dialog. */
  width?: number | string;
}

/** Asks, and resolves to what the reader answered. */
export type ConfirmFunction = (options: ConfirmOptions | string) => Promise<boolean>;

const ConfirmContext = /* @__PURE__ */ React.createContext<ConfirmFunction | null>(null);

export interface ConfirmProviderProps {
  children?: React.ReactNode;
  /** Defaults for every confirm raised under it. Each call can override them. */
  defaults?: Pick<ConfirmOptions, 'color' | 'size' | 'width' | 'locale'>;
}

/** One pending question: what to ask, and the promise waiting on the answer. */
interface Pending {
  options: ConfirmOptions;
  settle: (answer: boolean) => void;
}

/**
 * Hosts the one dialog every `useConfirm` under it raises.
 *
 * A provider for `ToastProvider`'s reason: what a caller has at the moment a
 * confirmation is warranted is a click handler, not a place in the tree, and
 * `<Dialog open={…}>` with a piece of state per question is the shape this
 * exists to avoid — the state is always the same three fields, and it is always
 * written again.
 *
 * **Questions queue.** Two raised at once are two questions somebody meant to
 * ask, and resolving the older one `false` to make room would be reporting an
 * answer the reader never gave — which reads, at the call site, as "they said
 * no". So the second waits for the first, and no promise is settled by anything
 * but a person.
 */
export function ConfirmProvider({ children, defaults }: ConfirmProviderProps) {
  const [queue, setQueue] = React.useState<Pending[]>([]);
  // The question on the sheet, which is *not* the same as the head of the
  // queue: Base UI keeps a dialog mounted while its exit transition runs, and
  // reading the queue directly would empty the heading and the description out
  // from under the fade. So the sheet keeps the last thing it was asked.
  const [shown, setShown] = React.useState<ConfirmOptions | undefined>(undefined);

  const current = queue[0];

  // Adjusted during render rather than in an effect: an effect would show the
  // sheet one committed frame late, and the frame in between is a dialog with
  // no words in it. React re-runs this component before touching the DOM, so
  // nothing is painted twice.
  if (current && current.options !== shown) {
    setShown(current.options);
  }

  const confirm = React.useCallback<ConfirmFunction>(
    (options) =>
      new Promise<boolean>((resolve) => {
        setQueue((waiting) => [
          ...waiting,
          {
            options: typeof options === 'string' ? { title: options } : options,
            settle: resolve
          }
        ]);
      }),
    []
  );

  const answer = (value: boolean) => {
    if (!current) {
      return;
    }
    current.settle(value);
    setQueue((waiting) => waiting.slice(1));
  };

  const merged: ConfirmOptions = { ...defaults, ...shown };
  const messages = useMessages(confirmMessages, merged.locale);

  return (
    <ConfirmContext.Provider value={confirm}>
      {children}

      <Dialog
        open={current !== undefined}
        onOpenChange={(next) => {
          // Escape and the backdrop are the cancelling button by another route,
          // so they answer the same way rather than leaving a promise pending.
          if (!next) {
            answer(false);
          }
        }}
        size={merged.size ?? 'sm'}
        color={merged.color ?? 'primary'}
        width={merged.width}
        title={merged.title}
        description={merged.description}
        dismissible={merged.dismissible ?? true}
        showClose={false}
        actions={
          <>
            {merged.alert ? null : (
              <Button variant="text" color="secondary" onClick={() => answer(false)}>
                {merged.cancelLabel ?? messages.cancel}
              </Button>
            )}
            <Button
              variant="solid"
              color={merged.color ?? 'primary'}
              onClick={() => answer(true)}
              autoFocus
            >
              {merged.confirmLabel ?? messages.confirm}
            </Button>
          </>
        }
      />
    </ConfirmContext.Provider>
  );
}

/**
 * Asks a question and waits for the answer.
 *
 * ```tsx
 * const confirm = useConfirm();
 *
 * if (await confirm({ title: 'Delete the project?', color: 'danger' })) {
 *   remove();
 * }
 * ```
 *
 * A promise rather than an `onConfirm` callback, because the code that asks is
 * the code that acts: a callback splits one decision across two functions and
 * leaves the caller to carry whatever it was about to do into the second.
 *
 * Cancelling, Escape and a click on the backdrop all resolve `false`. It never
 * rejects — a question that was answered "no" is an answer, not a failure, and
 * a promise that throws for it turns every call site into a `try`.
 */
export function useConfirm(): ConfirmFunction {
  const confirm = React.useContext(ConfirmContext);

  if (!confirm) {
    throw new Error('neba: useConfirm() needs a <ConfirmProvider> above it.');
  }

  return confirm;
}

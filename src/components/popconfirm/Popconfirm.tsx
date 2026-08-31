'use client';

import * as React from 'react';
import { Button } from '../button/Button.js';
import { Popover, PopoverClose } from '../popover/Popover.js';
import { severityIcon } from '../../internal/icons.js';
import { confirmMessages, useMessages } from '../../internal/i18n.js';
import { cx, gapClasses } from '../../internal/styles.js';
import type { NebaAlign, NebaColor, NebaSide, NebaSize, NebaSlots } from '../../types.js';

/** The parts a Popconfirm draws behind its root. */
export type PopconfirmSlot = 'icon' | 'title' | 'description' | 'actions';

export interface PopconfirmProps {
  /**
   * The control the question hangs off and that raises it. Exactly one element,
   * which must accept a ref and spread props — every Neba component does.
   */
  trigger?: React.ReactElement;
  /** The question. */
  title?: React.ReactNode;
  /** What answering costs — the consequence, not a restatement of the title. */
  description?: React.ReactNode;
  /** Called when the reader confirms. May return a promise; see `onConfirm`. */
  onConfirm?: () => void | Promise<unknown>;
  /** Called when the reader cancels. Dismissing does not call it. */
  onCancel?: () => void;
  /** Overrides the confirming button's label. Defaults to the locale's word. */
  confirmLabel?: React.ReactNode;
  /** Overrides the cancelling button's label. */
  cancelLabel?: React.ReactNode;
  /**
   * The colour family. `danger` for anything that destroys something, which is
   * most of what a Popconfirm is for.
   * @default 'danger'
   */
  color?: NebaColor;
  size?: NebaSize;
  /**
   * Draws the family's own severity mark beside the question.
   *
   * On by default, and it is not decoration: a question that says "this is
   * destructive" only in red says it only to some readers, so the shape has to
   * carry the meaning too. Pass a node for one of your own, or `false` for none.
   * @default true
   */
  icon?: React.ReactNode | false;
  side?: NebaSide;
  align?: NebaAlign;
  /** Whether the bubble is open. Use with `onOpenChange` to control it. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** BCP 47 tag deciding the two default labels. Defaults to the browser's. */
  locale?: string;
  /** How wide the bubble is. */
  width?: number | string;
  className?: string;
  classNames?: NebaSlots<PopconfirmSlot>;
}

/**
 * A question asked where the answer will be acted on.
 *
 * The small sibling of [Confirm](./confirm), and the difference is not size. A
 * Confirm takes the page away, which is right when the consequence reaches past
 * what is on screen — deleting the workspace everything else belongs to. A
 * Popconfirm stays anchored to the control that raised it, which is right when
 * the consequence is that control's own row: the reader can still see what they
 * are about to delete, and losing that context is most of what makes a modal
 * feel heavy for a small act.
 *
 * So the rule is about *reach* rather than about danger: one row, a Popconfirm;
 * the page, a Confirm.
 *
 * It closes itself once `onConfirm` settles, so an async handler keeps the
 * bubble up — and its confirming button busy — until the work is actually done.
 * A question that vanished before its answer landed is a question the reader
 * has no way to know was heard.
 */
export function Popconfirm({
  trigger,
  title,
  description,
  onConfirm,
  onCancel,
  confirmLabel,
  cancelLabel,
  color = 'danger',
  size = 'sm',
  icon = true,
  side = 'top',
  align = 'center',
  open: openProp,
  defaultOpen,
  onOpenChange,
  locale,
  width = 280,
  className,
  classNames
}: PopconfirmProps) {
  const messages = useMessages(confirmMessages, locale);

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
  const open = openProp ?? uncontrolledOpen;
  const [running, setRunning] = React.useState(false);

  const setOpen = (next: boolean) => {
    if (openProp === undefined) {
      setUncontrolledOpen(next);
    }
    onOpenChange?.(next);
  };

  const confirm = async () => {
    try {
      setRunning(true);
      await onConfirm?.();
      setOpen(false);
    } finally {
      setRunning(false);
    }
  };

  const mark = icon === true ? severityIcon(color) : icon;

  return (
    <Popover
      trigger={trigger}
      open={open}
      onOpenChange={setOpen}
      side={side}
      align={align}
      size={size}
      color={color}
      width={width}
      showClose={false}
      className={className}
    >
      <div className={cx('flex', gapClasses[size])}>
        {mark ? (
          <span
            aria-hidden="true"
            className={cx('mt-px shrink-0 text-(--n-accent)', classNames?.icon)}
          >
            {mark}
          </span>
        ) : null}

        <div className={cx('flex min-w-0 flex-1 flex-col', gapClasses[size])}>
          {title ? (
            <p className={cx('font-medium text-(--neba-fg)', classNames?.title)}>{title}</p>
          ) : null}

          {description ? (
            <p className={cx('text-(--neba-muted-fg)', classNames?.description)}>{description}</p>
          ) : null}

          <div className={cx('flex justify-end gap-1.5 pt-0.5', classNames?.actions)}>
            <PopoverClose
              render={
                <Button size={size} variant="text" color="secondary" onClick={() => onCancel?.()}>
                  {cancelLabel ?? messages.cancel}
                </Button>
              }
            />
            <Button size={size} color={color} loading={running} onClick={confirm}>
              {confirmLabel ?? messages.confirm}
            </Button>
          </div>
        </div>
      </div>
    </Popover>
  );
}

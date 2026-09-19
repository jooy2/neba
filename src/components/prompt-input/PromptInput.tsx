'use client';

import * as React from 'react';
import { IconButton } from '../icon-button/IconButton.js';
import { useDropZone } from '../../internal/drop.js';
import { spotlightSlot, glowClasses, trackPointer } from '../../internal/glow.js';
import { matchesShortcut } from '../../internal/keys.js';
import { promptMessages, useMessages, type PromptMessages } from '../../internal/i18n.js';
import {
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldFocusTransitionClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  fieldRingClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  srOnlyClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaSize, NebaSlots, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';

/**
 * The parts a PromptInput draws behind its root.
 *
 * `shell` is the framed box — the thing wearing the border, the fill and the
 * focus ring — and `control` the `<textarea>` inside it. `toolbar` is the row
 * under the text and `send` the one button the component draws itself.
 */
export type PromptInputSlot = 'shell' | 'control' | 'toolbar' | 'send';

/** Which key sends, spelled the way [Shortcut] draws it. */
export type PromptSubmitKey = 'Enter' | 'Mod+Enter';

type NativeControlProps = Omit<
  React.ComponentPropsWithoutRef<'textarea'>,
  'color' | 'size' | 'value' | 'defaultValue' | 'onChange' | 'onSubmit' | 'children'
>;

export interface PromptInputProps
  extends Pick<NebaStyleProps, 'size' | 'variant' | 'color' | 'density'>, NativeControlProps {
  /** What is in the field. Pass it with `onValueChange` to drive it yourself. */
  value?: string;
  /** What an uncontrolled field starts with. @default '' */
  defaultValue?: string;
  /** Called on every keystroke, with the whole value. */
  onValueChange?: (value: string) => void;
  /**
   * Called with the value when the field is sent — by the key, by the button,
   * or by a form submission. An empty field never sends.
   *
   * It does **not** clear the field. What happens to what was typed is the
   * application's: a message that failed to send should still be there.
   */
  onSubmit?: (value: string) => void;
  /**
   * Whether an answer is being written. The send button becomes a stop button,
   * and stays pressable — which is the whole reason it is one button and not
   * two: the thing a reader reaches for to stop an answer is exactly where
   * they last pressed to start it.
   * @default false
   */
  submitting?: boolean;
  /** Called when the stop button is pressed. */
  onStop?: () => void;
  /**
   * Which key sends. `Enter` sends and `Shift+Enter` breaks the line;
   * `Mod+Enter` is the other way round, for a field people write paragraphs in.
   *
   * Neither fires while an input method is composing — a Korean or Japanese
   * reader pressing Enter to accept a candidate is finishing a word, not
   * sending a message.
   * @default 'Enter'
   */
  submitKey?: PromptSubmitKey;
  /**
   * Passing it makes the shell a drop target. It is called with the files, and
   * what happens to them is the application's.
   *
   * A folder dropped onto a page arrives looking like a zero-byte file, and
   * those are filtered out before this is called — the same check a
   * [FilePicker](../inputs/file-picker) makes.
   */
  onFiles?: (files: File[]) => void;
  /** The field's accessible name, drawn for a screen reader and nobody else. */
  label?: React.ReactNode;
  /** How many rows the field is at its shortest. @default 1 */
  minRows?: number;
  /**
   * And at its tallest, after which it scrolls. A prompt field that grows
   * without a ceiling pushes the conversation it belongs to off the screen.
   * @default 8
   */
  maxRows?: number;
  /** Controls at the start of the toolbar under the text — attach, a model Select. */
  start?: React.ReactNode;
  /** Controls at its end, before the send button — a token count, a mode toggle. */
  end?: React.ReactNode;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Which language the two button labels are written in, as a BCP 47 tag. */
  locale?: string;
  /** Those words, written out. Overrides the `locale`'s. */
  labels?: Partial<PromptMessages>;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<PromptInputSlot>;
  /** A strip above the field — the attachments that have been added, a reply-to line. */
  children?: React.ReactNode;
}

/** The arrow that sends. Up rather than right, because the thread is above it. */
function SendIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 13V3.5m0 0L3.75 7.75M8 3.5l4.25 4.25"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** And the square that stops. Solid, at the optical weight of the arrow. */
function StopIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
      <rect x="4" y="4" width="8" height="8" rx="1.5" />
    </svg>
  );
}

/** The type scale and the radius. One step rounder than a field, because this box is tall. */
const sizeClasses: Record<NebaSize, string> = {
  xs: `${radiusClasses.sm} ${controlTextLeadingClasses.xs}`,
  sm: `${radiusClasses.md} ${controlTextLeadingClasses.sm}`,
  md: `${radiusClasses.lg} ${controlTextLeadingClasses.md}`,
  lg: `${radiusClasses.xl} ${controlTextLeadingClasses.lg}`,
  xl: `${radiusClasses.xl} ${controlTextLeadingClasses.xl}`
};

/** The gap between the text, the toolbar and whatever is above them. */
const stackClasses: Record<NebaSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1.5',
  md: 'gap-2',
  lg: 'gap-2.5',
  xl: 'gap-3'
};

/**
 * Everything a prompt goes out through: the text, the attach and model
 * controls, and one button that sends and then stops.
 *
 * A [TextField](../inputs/text-field) with `multiline` plus a
 * [Toolbar](../surfaces/toolbar) gets the shell. What it does not get is the
 * three things that are rewritten at every call site: a field that grows with
 * what is typed and then stops growing, a send button that becomes a stop
 * button without moving, and Enter meaning *send* while Shift+Enter means a new
 * line.
 *
 * The composition guard is the part most easily missed and the one that matters
 * most outside English: pressing Enter to accept a candidate from a Korean or
 * Japanese input method is finishing a word, and a field that read it as a
 * send would make the language unusable.
 */
export const PromptInput = React.forwardRef<HTMLTextAreaElement, PromptInputProps>(
  function PromptInput(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      value: valueProp,
      defaultValue = '',
      onValueChange,
      onSubmit,
      submitting = false,
      onStop,
      submitKey = 'Enter',
      onFiles,
      label,
      minRows = 1,
      maxRows = 8,
      start,
      end,
      locale,
      labels,
      classNames,
      disabled: disabledProp,
      readOnly = false,
      onKeyDown,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const disabled = useFieldsetDisabled(disabledProp);
    const lit = !disabled && !readOnly;
    const messages = useMessages(promptMessages, locale);
    const words = { ...messages, ...labels };

    const [text, setText] = React.useState(defaultValue);
    const controlled = valueProp !== undefined;
    const value = controlled ? valueProp : text;

    /*
     * The depth count behind the ready state, and the document listeners that
     * put it out when a drag is abandoned rather than dropped, are
     * `internal/drop.ts`' — a FilePicker's zone is the same box.
     */
    const { over: dropping, handlers } = useDropZone(onFiles);
    const controlId = React.useId();
    const controlRef = React.useRef<HTMLTextAreaElement | null>(null);
    const setControlRef = React.useCallback(
      (node: HTMLTextAreaElement | null) => {
        controlRef.current = node;
        if (typeof ref === 'function') {
          ref(node);
        } else if (ref) {
          ref.current = node;
        }
      },
      [ref]
    );

    /*
     * The field's own height, measured rather than declared.
     *
     * `field-sizing: content` is the one-line version of this and is years past
     * the browsers this library still supports, so the height is set from the
     * content's own `scrollHeight` — reset to `auto` first, because a box that
     * is already tall reports its current height rather than the text's.
     *
     * A layout effect and not an effect: this runs between React writing the
     * text and the browser painting it, so the box is never drawn at the wrong
     * height for a frame.
     */
    React.useLayoutEffect(() => {
      const node = controlRef.current;

      if (!node) {
        return;
      }

      node.style.height = 'auto';
      node.style.height = `${node.scrollHeight}px`;
    }, [value]);

    const send = () => {
      const outgoing = value.trim();

      if (!outgoing || disabled || readOnly || submitting) {
        return;
      }

      onSubmit?.(value);
    };

    const canSend = value.trim().length > 0 && !disabled && !readOnly;

    return (
      <form
        // A real form, so a phone's keyboard offers its own send key and the
        // button below can be a `type="submit"` rather than a click handler
        // pretending to be one.
        onSubmit={(event) => {
          event.preventDefault();
          send();
        }}
        className={cx('flex w-full flex-col', className ?? '')}
        style={{
          ...surfaceSlots(color, elevation),
          ...(lit ? spotlightSlot : undefined),
          ...style
        }}
      >
        {hasContent(label) ? (
          <label htmlFor={controlId} className={srOnlyClasses}>
            {label}
          </label>
        ) : null}

        <div
          data-dropping={dropping || undefined}
          {...handlers}
          // The spotlight, and only the spotlight — see `internal/glow.ts`.
          onPointerMove={trackPointer(undefined, lit)}
          onPointerDown={(event) => {
            // Pressing the shell's own padding puts the caret in the field, the
            // way pressing anywhere inside a native input does. A press on the
            // text or on a toolbar control is left alone.
            if (event.target === event.currentTarget && !disabled) {
              event.preventDefault();
              controlRef.current?.focus();
            }
          }}
          className={cx(
            'relative flex w-full flex-col py-2',
            '[-webkit-tap-highlight-color:transparent]',
            sizeClasses[size],
            stackClasses[size],
            paddingXClasses[density][size],
            transitionClasses,
            fieldFocusTransitionClasses,
            fieldRingClasses,
            iconClasses,
            disabled
              ? disabledClasses[variant]
              : readOnly
                ? fieldReadOnlyClasses[variant]
                : `${fieldRestClasses[variant]} ${glowClasses}`,
            dropping ? '[border-color:var(--n-ring)] bg-(--n-soft)' : '',
            classNames?.shell ?? ''
          )}
        >
          {children}

          <textarea
            ref={setControlRef}
            id={controlId}
            rows={minRows}
            value={value}
            disabled={disabled}
            readOnly={readOnly}
            onChange={(event) => {
              if (!controlled) {
                setText(event.target.value);
              }
              onValueChange?.(event.target.value);
            }}
            className={cx(
              'neba-input block w-full resize-none bg-transparent [font:inherit] text-inherit',
              // Not `outline-none`: that utility zeroes `--tw-outline-style`,
              // which the shell's focus ring is drawn with. The shorthand takes
              // the outline off this element and leaves the ring alone.
              '[outline:none]',
              'min-h-(--n-min-rows) max-h-(--n-max-rows) overflow-y-auto',
              'placeholder:text-(--neba-muted-fg)',
              'caret-(--n-accent) selection:bg-(--n-soft-press)',
              'disabled:cursor-not-allowed',
              classNames?.control ?? ''
            )}
            style={
              {
                '--n-min-rows': `calc(${Math.max(minRows, 1)} * 1lh)`,
                '--n-max-rows': `calc(${Math.max(maxRows, minRows, 1)} * 1lh)`
              } as React.CSSProperties
            }
            {...props}
            onKeyDown={(event) => {
              /*
               * An input method is mid-word. A Korean or Japanese reader
               * pressing Enter to accept a candidate is finishing what they are
               * typing, and a field that read that as a send would make the
               * language unusable.
               */
              if (!event.nativeEvent.isComposing && matchesShortcut(event, submitKey)) {
                event.preventDefault();
                send();
              }

              onKeyDown?.(event);
            }}
          />

          <div
            className={cx(
              'flex min-w-0 items-center gap-2',
              metaTextClasses[size],
              classNames?.toolbar ?? ''
            )}
          >
            {hasContent(start) ? (
              <div className="flex min-w-0 items-center gap-1">{start}</div>
            ) : null}

            <div className="ms-auto flex shrink-0 items-center gap-2">
              {hasContent(end) ? <div className="flex items-center gap-1">{end}</div> : null}

              <IconButton
                // One button, never two. What a reader reaches for to stop an
                // answer is exactly where they last pressed to start it, and a
                // second button appearing beside the first would move it.
                type={submitting ? 'button' : 'submit'}
                size={size}
                color={color}
                icon={submitting ? <StopIcon /> : <SendIcon />}
                label={submitting ? words.stop : words.send}
                disabled={submitting ? false : !canSend}
                onClick={submitting ? onStop : undefined}
                className={classNames?.send}
              />
            </div>
          </div>

          {dropping ? (
            <div
              aria-hidden="true"
              className={cx(
                'pointer-events-none absolute inset-0 flex items-center justify-center',
                'font-medium text-(--n-accent)',
                sizeClasses[size]
              )}
            >
              {words.drop}
            </div>
          ) : null}
        </div>
      </form>
    );
  }
);

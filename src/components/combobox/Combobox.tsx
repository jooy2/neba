import * as React from 'react';
import { Combobox as BaseUICombobox } from '@base-ui/react/combobox';
import { Field } from '@base-ui/react/field';
import { Chip } from '../chip/Chip';
import { CheckIcon, ChevronIcon, CloseIcon, PlusIcon } from '../../internal/icons';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlTextLeadingClasses,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles';
import type { NebaColor, NebaElevation, NebaSize, NebaStyleProps } from '../../types';

/**
 * What a Combobox's value may be — the same two types a [Select](../select)
 * submits, and for the same reason: a form control's value is what a form
 * sends, and every escape from that buys flexibility by making the common case
 * harder to write.
 *
 * A value the list does not contain is a `string`: it is what the user typed.
 */
export type ComboboxValue = string | number;

export interface ComboboxOption {
  /** Submitted, and what `value` / `onValueChange` speak in. */
  value: ComboboxValue;
  /**
   * Shown in the list, in the input and on the chip. Defaults to the value.
   *
   * A `string` rather than a `ReactNode`, which is the one place this differs
   * from Select: the label is typed against by the filter and written into a
   * text input, and neither of those can be done to an element.
   */
  label?: string;
  /** Unavailable, but still listed — the option exists, it just cannot be picked. */
  disabled?: boolean;
}

/** One value, or an array of them, depending on `multiple`. */
type Selection<Multiple extends boolean | undefined> = Multiple extends true
  ? ComboboxValue[]
  : ComboboxValue | null;

export interface ComboboxProps<
  Multiple extends boolean | undefined = false
> extends NebaStyleProps {
  /**
   * The options, as data — the same shape Select takes, and for the same
   * reason: what a caller has is almost always an array already.
   */
  items: readonly ComboboxOption[];
  /**
   * Whether more than one value may be held. The chosen ones become chips
   * inside the field, and the input goes on filtering after each.
   * @default false
   */
  multiple?: Multiple;
  /** The chosen value. Use with `onValueChange` for a controlled combobox. */
  value?: Selection<Multiple> | null;
  /** The initially chosen value, for an uncontrolled combobox. */
  defaultValue?: Selection<Multiple> | null;
  onValueChange?: (value: Selection<Multiple>) => void;
  /** Called as the text in the input changes — the filter query, not the value. */
  onInputValueChange?: (inputValue: string) => void;
  /**
   * Whether a value the list does not contain may be committed.
   *
   * On by default, and it is what separates this from a searchable Select: the
   * typed text is offered as its own row at the end of the list, so committing
   * it is a choice the user makes rather than something that happens to them on
   * blur. Turn it off for a field whose values are a closed set.
   * @default true
   */
  allowCustom?: boolean;
  /** What that row says. Receives the trimmed query. */
  customLabel?: (query: string) => React.ReactNode;
  /**
   * Shows a × that empties the field. Off by default — a field that can be
   * cleared in one click is a field that can be emptied by accident.
   * @default false
   */
  clearable?: boolean;
  /** Shown in the popup when nothing matches and no value may be added. */
  emptyMessage?: React.ReactNode;
  /** The most rows the list will show at once. `-1` is all of them. @default -1 */
  limit?: number;
  /** Shown in the input while nothing is typed. */
  placeholder?: string;
  /**
   * Drop shadow depth of the *field*. The popup has its own, fixed: it
   * genuinely floats above the page, which is the one case elevation is for.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Label above the field, wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text below the field. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the combobox invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /** Content placed before the input. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The value is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be chosen before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  /** The popup is open. Use with `onOpenChange` for a controlled popup. */
  open?: boolean;
  /** Whether the popup starts open. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Accessible name of the clear button. */
  clearLabel?: string;
  /** Accessible name of a chip's remove button. Receives the chip's label. */
  removeLabel?: (label: string) => string;
  /** A ref to the text input the user types into. */
  inputRef?: React.Ref<HTMLInputElement>;
  id?: string;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * What Base UI holds. Our public value is a string or a number; the object is
 * what carries the label the input and the filter need, plus the flag that says
 * "this row is offering a value the list does not have".
 */
interface Entry {
  value: ComboboxValue;
  label: string;
  disabled?: boolean;
  custom?: boolean;
}

/** The field, and it is a TextField's shell to the pixel. */
const shellBaseClasses = [
  'group relative flex w-full cursor-text items-center',
  '[-webkit-tap-highlight-color:transparent]',
  transitionClasses,
  'focus-within:[transition-duration:0ms]',
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * With chips in it the field cannot have a fixed height — the chips wrap. The
 * padding is `(control height − chip height) / 2` instead, which makes a
 * one-row combobox exactly as tall as the field beside it, and `min-h-*`
 * catches the variants that carry no border.
 *
 * Keyed by `size` and never by `density`: density is horizontal padding only.
 */
const chipsInsetClasses: Record<NebaSize, string> = {
  xs: 'min-h-5.5 py-0',
  sm: 'min-h-6.5 py-[2px]',
  md: 'min-h-8 py-[3px]',
  lg: 'min-h-10 py-[4px]',
  xl: 'min-h-12 py-[4px]'
};

/**
 * The popup is one of the few surfaces in the library that is *supposed* to
 * float, so unlike everything else it carries a shadow by default — at level 3,
 * which is as far as the scale goes without hovering. Identical to Select's,
 * because a combobox's list and a select's list are the same list.
 */
const popupClasses = [
  surfaceClasses,
  'max-h-[min(20rem,var(--available-height))] overflow-y-auto overscroll-contain',
  'w-[var(--anchor-width)] border bg-(--n-panel-press) p-1',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]'
].join(' ');

const itemClasses = [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--neba-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--n-soft-hover)',
  'data-[selected]:text-(--n-accent) data-[selected]:font-medium',
  'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
  '[outline:none]'
].join(' ');

/** The chevron and the ×, which sit in the field rather than in the list. */
const adornmentClasses = [
  'inline-flex h-[1lh] shrink-0 cursor-pointer items-center justify-center',
  'rounded-(--neba-radius-xs) text-(--neba-muted-fg)',
  '[transition:color_var(--neba-duration)_var(--neba-ease)]',
  'hover:text-(--n-accent)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
  'disabled:cursor-not-allowed disabled:text-(--neba-disabled-fg)'
].join(' ');

/** Always an array inside, however the caller spells it. */
function toArray(value: unknown): ComboboxValue[] {
  if (value === null || value === undefined) {
    return [];
  }
  return Array.isArray(value) ? (value.slice() as ComboboxValue[]) : [value as ComboboxValue];
}

/**
 * A field you can type into and also choose from.
 *
 * The shell is a TextField's, wearing a chevron, exactly as Select's trigger is
 * — the three have to be indistinguishable in a form or the form looks
 * assembled rather than designed. What is different is what the text does: it
 * filters the list, and — unless `allowCustom` is off — it can become the value
 * itself, offered as the last row rather than committed silently on blur.
 *
 * With `multiple` the chosen values become [Chip](../../display/chip)s inside
 * the field and the input goes on filtering after each one, so a set of tags is
 * built without the field ever closing.
 *
 * Base UI owns everything hard about this: the filtering and its collator, the
 * popup's positioning and flipping, the `combobox`/`listbox` wiring, arrow-key
 * navigation across both the list and the chips, and the hidden input that
 * makes the whole thing submit with a form.
 */
export function Combobox<Multiple extends boolean | undefined = false>({
  variant = 'outline',
  size = 'md',
  color = 'primary',
  density = 'default',
  elevation = 0,
  items,
  multiple,
  value,
  defaultValue,
  onValueChange,
  onInputValueChange,
  allowCustom = true,
  customLabel,
  clearable = false,
  emptyMessage = 'No matches',
  limit,
  placeholder,
  label,
  description,
  error,
  invalid,
  startIcon,
  fullWidth = false,
  disabled = false,
  readOnly = false,
  required = false,
  name,
  open,
  defaultOpen,
  onOpenChange,
  clearLabel = 'Clear',
  removeLabel = (chip) => `Remove ${chip}`,
  inputRef,
  id,
  className,
  style
}: ComboboxProps<Multiple>) {
  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
  // the caret and the message all turn over together.
  const family: NebaColor = isInvalid ? 'danger' : color;
  const isMultiple = multiple === true;

  const options = React.useMemo<Entry[]>(
    () =>
      items.map((item) => ({
        value: item.value,
        label: item.label ?? String(item.value),
        disabled: item.disabled
      })),
    [items]
  );

  // The selection is mirrored internally even when the caller controls it. The
  // "add this" row has to know what has already been chosen — otherwise a tag
  // that was just added goes on being offered — and in uncontrolled mode there
  // is nowhere else that knowledge lives.
  const [ownSelection, setOwnSelection] = React.useState<ComboboxValue[]>(() =>
    toArray(defaultValue)
  );
  const selection = value === undefined ? ownSelection : toArray(value);

  const [query, setQuery] = React.useState('');

  const entryFor = React.useCallback(
    (item: ComboboxValue): Entry =>
      options.find((option) => option.value === item) ?? {
        value: item,
        label: String(item),
        custom: true
      },
    [options]
  );

  // The row that offers what was typed. It is a real item rather than a special
  // case in the keyboard handling, so Enter, a click and the arrow keys all
  // reach it the same way every other row is reached — and Base UI's own filter
  // keeps it visible, because its label *is* the query.
  const trimmed = query.trim();
  const folded = trimmed.toLocaleLowerCase();
  const alreadyKnown =
    trimmed === '' ||
    options.some(
      (option) =>
        option.label.toLocaleLowerCase() === folded ||
        String(option.value).toLocaleLowerCase() === folded
    ) ||
    selection.some((item) => String(item).toLocaleLowerCase() === folded);
  const customValue = allowCustom && !readOnly && !disabled && !alreadyKnown ? trimmed : null;

  const listItems = React.useMemo<Entry[]>(
    () =>
      customValue === null
        ? options
        : [...options, { value: customValue, label: customValue, custom: true }],
    [options, customValue]
  );

  const baseValue = isMultiple
    ? selection.map(entryFor)
    : selection.length > 0
      ? entryFor(selection[0])
      : null;

  function commit(next: ComboboxValue[]) {
    if (value === undefined) {
      setOwnSelection(next);
    }
    onValueChange?.((isMultiple ? next : (next[0] ?? null)) as Selection<Multiple>);
  }

  const padX = paddingXClasses[density][size];

  const shellClasses = [
    shellBaseClasses,
    controlTextLeadingClasses[size],
    radiusClasses[size],
    gapClasses[size],
    isMultiple ? chipsInsetClasses[size] : controlHeightClasses[size],
    // The chevron brings its own hit area; stacking the field's padding on top
    // of it would leave the glyph floating in the middle of a gap.
    `${padX} pe-1.5`,
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? disabledClasses[variant]
      : readOnly
        ? fieldReadOnlyClasses[variant]
        : fieldRestClasses[variant]
  ].join(' ');

  const inputClasses = [
    'min-w-0 flex-1 self-stretch bg-transparent [font:inherit] text-inherit',
    // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
    // shell's focus ring is drawn from the same variable family.
    '[outline:none]',
    'placeholder:text-(--neba-muted-fg)',
    'caret-(--n-accent) selection:bg-(--n-soft-press)',
    'disabled:cursor-not-allowed'
  ].join(' ');

  const input = (
    <BaseUICombobox.Input
      ref={inputRef}
      placeholder={placeholder}
      className={isMultiple ? `${inputClasses} min-w-16 h-[1lh]` : inputClasses}
    />
  );

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={[
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(family, elevation), ...style }}
    >
      {label ? (
        <Field.Label
          className={[
            metaTextClasses[size],
            'font-medium',
            disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)'
          ].join(' ')}
        >
          {label}
        </Field.Label>
      ) : null}

      <BaseUICombobox.Root<Entry, boolean>
        id={id}
        name={name}
        items={listItems}
        multiple={isMultiple}
        value={baseValue}
        onValueChange={(next) => {
          const chosen = next === null ? [] : Array.isArray(next) ? next : [next];
          commit(chosen.map((entry) => entry.value));
        }}
        // The text is Base UI's to own, not ours: in single mode it is the
        // chosen option's label, which has to be there from the first paint,
        // and in multiple mode it empties itself after each pick. What is kept
        // here is a copy, and only so the "add this" row knows what was typed.
        onInputValueChange={(next) => {
          setQuery(next);
          onInputValueChange?.(next);
        }}
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        // The first match lights up as you type, so Enter commits without an
        // arrow key first. This is what makes the "add this" row reachable from
        // the keyboard at all: a value the list does not have is the only match
        // there is, so it is the one Enter lands on.
        autoHighlight
        itemToStringLabel={(entry) => entry.label}
        itemToStringValue={(entry) => String(entry.value)}
        isItemEqualToValue={(a, b) => a.value === b.value}
        limit={limit}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        <BaseUICombobox.InputGroup className={shellClasses}>
          {startIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
              {startIcon}
            </span>
          ) : null}

          {isMultiple ? (
            <BaseUICombobox.Chips className="flex min-w-0 flex-1 flex-wrap items-center gap-1">
              <BaseUICombobox.Value>
                {(chosen: Entry[]) => (
                  <React.Fragment>
                    {chosen.map((entry) => (
                      <BaseUICombobox.Chip
                        key={String(entry.value)}
                        render={
                          <Chip
                            variant="outline"
                            size={size}
                            color={family}
                            density="compact"
                            disabled={disabled}
                            endIcon={
                              readOnly || disabled ? null : (
                                <BaseUICombobox.ChipRemove
                                  aria-label={removeLabel(entry.label)}
                                  className={chipRemoveClasses}
                                >
                                  <CloseIcon />
                                </BaseUICombobox.ChipRemove>
                              )
                            }
                          />
                        }
                      >
                        {entry.label}
                      </BaseUICombobox.Chip>
                    ))}
                    {input}
                  </React.Fragment>
                )}
              </BaseUICombobox.Value>
            </BaseUICombobox.Chips>
          ) : (
            input
          )}

          {clearable && !readOnly ? (
            <BaseUICombobox.Clear aria-label={clearLabel} className={adornmentClasses}>
              <CloseIcon />
            </BaseUICombobox.Clear>
          ) : null}

          <BaseUICombobox.Trigger
            aria-label={typeof label === 'string' ? undefined : 'Open'}
            className={adornmentClasses}
          >
            <BaseUICombobox.Icon
              className={[
                // The chevron is the one thing here that may turn: it is a
                // glyph, not a label, and nothing about it resamples.
                'flex items-center',
                '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
                'data-[popup-open]:rotate-180'
              ].join(' ')}
            >
              <ChevronIcon />
            </BaseUICombobox.Icon>
          </BaseUICombobox.Trigger>
        </BaseUICombobox.InputGroup>

        <BaseUICombobox.Portal>
          {/* `neba-portal` is a hook, not a style: a portalled popup leaves the
              subtree its host may have scoped a CSS reset to. */}
          <BaseUICombobox.Positioner className="neba-portal z-50 [outline:none]" sideOffset={6}>
            <BaseUICombobox.Popup
              className={`${popupClasses} ${radiusClasses[size]} ${controlTextLeadingClasses[size]}`}
            >
              <BaseUICombobox.Empty className="px-2 py-1.5 text-(--neba-muted-fg) empty:hidden">
                {emptyMessage}
              </BaseUICombobox.Empty>

              <BaseUICombobox.List>
                {(entry: Entry) => (
                  <BaseUICombobox.Item
                    key={`${entry.custom ? 'custom:' : ''}${String(entry.value)}`}
                    value={entry}
                    disabled={entry.disabled}
                    className={itemClasses}
                  >
                    {entry.custom ? (
                      <React.Fragment>
                        <span className="absolute start-1.5 flex size-4 items-center justify-center text-(--n-accent) [&_svg]:size-4">
                          <PlusIcon />
                        </span>
                        <span className="truncate">
                          {customLabel ? customLabel(entry.label) : `Add “${entry.label}”`}
                        </span>
                      </React.Fragment>
                    ) : (
                      <React.Fragment>
                        <BaseUICombobox.ItemIndicator className="absolute start-1.5 flex size-4 items-center justify-center">
                          <CheckIcon />
                        </BaseUICombobox.ItemIndicator>
                        <span className="truncate">{entry.label}</span>
                      </React.Fragment>
                    )}
                  </BaseUICombobox.Item>
                )}
              </BaseUICombobox.List>
            </BaseUICombobox.Popup>
          </BaseUICombobox.Positioner>
        </BaseUICombobox.Portal>
      </BaseUICombobox.Root>

      {description ? (
        <Field.Description className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}>
          {description}
        </Field.Description>
      ) : null}

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--n-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
}

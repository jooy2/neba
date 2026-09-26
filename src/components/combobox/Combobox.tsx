'use client';

import * as React from 'react';
import { Combobox as BaseUICombobox } from '@base-ui/react/combobox';
import { Field } from '@base-ui/react/field';
import { Chip } from '../chip/Chip.js';
import { actionMessages, comboboxMessages, fillMessage, useMessages } from '../../internal/i18n.js';
import { CheckIcon, ChevronIcon, CloseIcon, PlusIcon } from '../../internal/icons.js';
import { keyHandler } from '../../internal/keys.js';
import { FieldNotch, NotchFrame } from '../../internal/notch.js';
import {
  chipRemoveClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldFocusTransitionClasses,
  fieldHeightClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  fieldRingClasses,
  fieldSheetClasses,
  fieldSheetDisabledClasses,
  fieldSheetReadOnlyClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  popupFadeClasses,
  radiusClasses,
  readOnlyFilterClasses,
  stackGapClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaElevation,
  NebaFieldSlot,
  NebaLabelPlacement,
  NebaShortcuts,
  NebaSize,
  NebaSlots,
  NebaStyleProps
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { fieldLight, fieldSpotlightSlot, glowClasses } from '../../internal/glow.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';

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

/**
 * The parts a Combobox draws behind its root.
 *
 * `shell` is the framed box, `control` the `<input>` the reader types into, and
 * `chip` one of the tokens a multiple-selection combobox puts in front of it.
 * `popup` and `item` are portalled, so nothing written against the root reaches
 * them.
 */
export type ComboboxSlot = NebaFieldSlot | 'shell' | 'chip' | 'popup' | 'item';

export interface ComboboxProps<Multiple extends boolean | undefined = false>
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
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
  /**
   * How the typed text narrows the list, when the default is not what should
   * happen.
   *
   * `false` turns the filter off, which is what a list that is **already**
   * narrowed needs: a server that matched on a keyword, a description or a
   * synonym sends back rows whose visible label does not contain the query at
   * all, and filtering them a second time here drops exactly the results the
   * search was for. Fetch on `onInputValueChange`, hand the answer to `items`,
   * and let it through.
   *
   * A function decides per option — matching a `value` as well as a label, or
   * matching from the start of a word rather than anywhere in it. The row that
   * offers to add what was typed is never filtered out: it *is* the query.
   *
   * @default the accent- and case-insensitive match Base UI does
   */
  filter?: false | ((option: ComboboxOption, query: string) => boolean);
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
  /**
   * Which language the combobox writes its own words in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * The strings below write the words out instead; this is for the far more
   * common case where the page already knows its own language.
   */
  locale?: string;
  /**
   * Shown in the popup when nothing matches and no value may be added. Defaults
   * to the `locale`'s wording.
   */
  emptyMessage?: React.ReactNode;
  /**
   * The most options the list will show at once. `-1` is all of them. The row
   * that offers to add what was typed is drawn beyond it, so a full list can
   * still take a new value.
   * @default -1
   */
  limit?: number;
  /** Shown in the input while nothing is typed. */
  placeholder?: string;
  /**
   * Drop shadow depth of the *field*. The popup has its own, fixed: it
   * genuinely floats above the page, which is the one case elevation is for.
   * @default 0
   */
  elevation?: NebaElevation;
  /** The field's name, wired to the input by Base UI's Field. */
  label?: React.ReactNode;
  /**
   * Where the label is drawn: above the field, in a notch cut into its top
   * edge, or inside it until the field is focused, holds text or has a chip in
   * it. A `startIcon` keeps a `float` label in the notch.
   * @default 'top'
   */
  labelPlacement?: NebaLabelPlacement;
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
  /** Accessible name of the clear button. Defaults to the `locale`'s word. */
  clearLabel?: string;
  /**
   * Accessible name of the chevron that opens the list, when the field has no
   * string `label` to name it by. Defaults to the `locale`'s word.
   */
  openLabel?: string;
  /**
   * Accessible name of a chip's remove button. Receives the chip's label, and
   * defaults to the `locale`'s wording.
   */
  removeLabel?: (label: string) => string;
  /** A ref to the text input the user types into. */
  inputRef?: React.Ref<HTMLInputElement>;
  id?: string;
  /**
   * Class names for the parts behind the root. `className` is the root — the
   * column holding the label, the shell and the two lines under it — so the
   * `<input>` itself is `classNames.control`.
   */
  classNames?: NebaSlots<ComboboxSlot>;
  /**
   * Key combinations to act on, spelled the way
   * [Shortcut](../display/shortcut) draws them — `{ 'Mod+Enter': createAndGo }`.
   *
   * This is the only way in. A Combobox's keystrokes are the list's: the arrows
   * move the highlight, `Escape` closes the popup and `Enter` commits, and the
   * ones the list acts on never reach a plain `onKeyDown` on the root at all.
   * Bound to the `<input>`, and it runs before the list does — but it does not
   * *replace* what the list does, so a shortcut on `Enter` fires alongside the
   * commit rather than instead of it.
   */
  shortcuts?: NebaShortcuts<HTMLInputElement>;
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
  fieldFocusTransitionClasses,
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
 *
 * Its `--n-*` slots are set on the popup itself, exactly as Select's are: it is
 * portalled to the end of `<body>`, so nothing declared on the Field reaches it
 * and every `var()` in here would otherwise resolve to nothing — a
 * `currentColor` border and a highlight that does not light.
 */
const popupClasses = [
  surfaceClasses,
  'max-h-[min(20rem,var(--available-height))] overflow-y-auto overscroll-contain',
  'w-[var(--anchor-width)] border bg-(--n-panel-press) p-1',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  popupFadeClasses
].join(' ');

const itemClasses = [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--neba-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--n-soft-hover) data-[highlighted]:text-(--n-on-tint)',
  'data-[selected]:text-(--n-on-tint) data-[selected]:font-medium',
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
export function Combobox<Multiple extends boolean | undefined = false>(
  rawProps: ComboboxProps<Multiple>
) {
  const {
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
    filter,
    onInputValueChange,
    allowCustom = true,
    customLabel,
    clearable = false,
    locale,
    emptyMessage,
    limit,
    placeholder,
    label,
    labelPlacement = 'top',
    description,
    error,
    invalid,
    startIcon,
    fullWidth = false,
    disabled: disabledProp,
    readOnly = false,
    required = false,
    name,
    open,
    defaultOpen,
    onOpenChange,
    clearLabel,
    openLabel,
    removeLabel,
    inputRef,
    shortcuts,
    id,
    className,
    classNames,
    style,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledBy,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale', 'labelPlacement']);
  const disabled = useFieldsetDisabled(disabledProp);
  // A read-only field is a label that happens to be field-shaped, and a
  // disabled one has dropped the family the light would be drawn in.
  const lit = !disabled && !readOnly;

  const messages = useMessages(comboboxMessages, locale);
  const actions = useMessages(actionMessages, locale);
  const nameRemove =
    removeLabel ?? ((chip: string) => fillMessage(messages.remove, { label: chip }));

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

  /* A map rather than a `find`: this is called once per chosen item, and a
     multi-select with a hundred options and twenty chips in it would otherwise
     walk the list twenty times on every render. */
  const byValue = React.useMemo(
    () => new Map(options.map((option) => [option.value, option])),
    [options]
  );

  const entryFor = React.useCallback(
    (item: ComboboxValue): Entry =>
      byValue.get(item) ?? {
        value: item,
        label: String(item),
        custom: true
      },
    [byValue]
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

  // Base UI's own matcher, for the one case this component filters itself.
  const matcher = BaseUICombobox.useFilter({ locale });

  /* With a `limit`, Base UI cuts the filtered list to that many rows in order,
     and the row that adds what was typed is last, so a full list cut it off and
     Enter chose the first option instead. When there is such a row the options
     are filtered and cut here, with the same matcher, and the row goes after
     them; everywhere else Base UI filters as it always has. */
  const cutsItself = customValue !== null && limit !== undefined && limit > -1;

  const listItems = React.useMemo<Entry[]>(() => {
    if (customValue === null) {
      return options;
    }

    const custom: Entry = { value: customValue, label: customValue, custom: true };

    if (!cutsItself) {
      return [...options, custom];
    }

    const matching =
      filter === false
        ? options
        : options.filter((option) =>
            filter ? filter(option, customValue) : matcher.contains(option.label, customValue)
          );

    return [...matching.slice(0, limit), custom];
  }, [options, customValue, cutsItself, filter, matcher, limit]);

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

  const notched = labelPlacement !== 'top' && hasContent(label);
  const rests = notched && labelPlacement === 'float' && !hasContent(startIcon);

  const shellClasses = [
    shellBaseClasses,
    controlTextLeadingClasses[size],
    radiusClasses[size],
    gapClasses[size],
    isMultiple ? chipsInsetClasses[size] : fieldHeightClasses[size],
    // The chevron brings its own hit area; stacking the field's padding on top
    // of it would leave the glyph floating in the middle of a gap.
    `${padX} pe-1.5`,
    // The notch draws the ring when it draws the edge.
    notched ? '' : fieldRingClasses,
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? (notched ? fieldSheetDisabledClasses : disabledClasses)[variant]
      : readOnly
        ? notched
          ? `${fieldSheetReadOnlyClasses[variant]} ${readOnlyFilterClasses}`
          : fieldReadOnlyClasses[variant]
        : `${(notched ? fieldSheetClasses : fieldRestClasses)[variant]} ${glowClasses}`,
    classNames?.shell
  ]
    .filter(Boolean)
    .join(' ');

  const inputClasses = [
    // `self-stretch` and no height of its own, in both modes. An input centres
    // its own text in its box, so letting the box be the full height of the row
    // it sits on — the field in single mode, the chip line in multiple — is what
    // puts the placeholder on the same baseline as the chips beside it. A fixed
    // `1lh` here left it sitting a pixel or two high.
    'neba-input min-w-0 flex-1 self-stretch bg-transparent [font:inherit] text-inherit',
    // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
    // shell's focus ring is drawn from the same variable family.
    '[outline:none]',
    'placeholder:text-(--neba-muted-fg)',
    'caret-(--n-accent) selection:bg-(--n-soft-press)',
    'disabled:cursor-not-allowed',
    // The hook a resting label reads the field's emptiness through.
    rests ? 'neba-float-control' : '',
    classNames?.control
  ]
    .filter(Boolean)
    .join(' ');

  /**
   * `afterChips` is the space between the last chip and where typing starts.
   *
   * The row's own `gap-1` is the distance between two chips, which is the right
   * amount between two things of the same kind and too little between a chip and
   * a caret — the query reads as another chip's label rather than as the field's
   * own text. It is only added when there is a chip to be clear of, so an empty
   * multi-select lines its placeholder up with every other field in the form.
   */
  const renderInput = (afterChips: boolean) => (
    <BaseUICombobox.Input
      ref={inputRef}
      // A name written on the component is the input's. On the root it named a
      // `<div>`, and a Combobox with no visible label had an unnamed input.
      aria-label={ariaLabel}
      aria-labelledby={ariaLabelledBy}
      onKeyDown={keyHandler(shortcuts)}
      // `:placeholder-shown` is how a resting label knows the field is empty,
      // and it never matches an input that has no placeholder.
      placeholder={rests ? placeholder || ' ' : placeholder}
      className={
        isMultiple ? `${inputClasses} min-w-16 ${afterChips ? 'ms-1.5' : ''}` : inputClasses
      }
    />
  );

  const inputGroup = (
    <BaseUICombobox.InputGroup
      className={shellClasses}
      // The spotlight, and only the spotlight, and out again while the
      // reader is typing — see `internal/glow.ts`.
      {...fieldLight<HTMLDivElement>(lit)}
    >
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
                        className={classNames?.chip}
                        endIcon={
                          readOnly || disabled ? null : (
                            <BaseUICombobox.ChipRemove
                              aria-label={nameRemove(entry.label)}
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
                {renderInput(chosen.length > 0)}
              </React.Fragment>
            )}
          </BaseUICombobox.Value>
        </BaseUICombobox.Chips>
      ) : (
        renderInput(false)
      )}

      {clearable && !readOnly ? (
        <BaseUICombobox.Clear aria-label={clearLabel ?? actions.clear} className={adornmentClasses}>
          <CloseIcon />
        </BaseUICombobox.Clear>
      ) : null}

      <BaseUICombobox.Trigger
        aria-label={typeof label === 'string' ? undefined : (openLabel ?? messages.open)}
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

      {notched ? (
        <FieldNotch
          label={label}
          variant={variant}
          disabled={disabled}
          readOnly={readOnly}
          rests={rests}
          // The chips are not an input, so a multiple field says it is
          // empty itself: nothing chosen and nothing typed.
          empty={isMultiple ? selection.length === 0 && query === '' : undefined}
          labelClassName={classNames?.label}
        />
      ) : null}
    </BaseUICombobox.InputGroup>
  );

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={cx(
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className ?? ''
      )}
      style={{
        ...surfaceSlots(family, elevation),
        ...(lit ? fieldSpotlightSlot : undefined),
        ...style
      }}
      {...props}
    >
      {label && !notched ? (
        <Field.Label
          className={cx(
            metaTextClasses[size],
            'font-medium',
            disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)',
            classNames?.label
          )}
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
        limit={cutsItself ? -1 : limit}
        // `null` is Base UI's "keep everything", and the custom row is exempt
        // from a caller's own answer because it is the query written out.
        filter={
          cutsItself || filter === false
            ? null
            : filter
              ? (entry: Entry, query: string) => entry.custom === true || filter(entry, query)
              : undefined
        }
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        {notched ? (
          <NotchFrame
            label={label}
            size={size}
            density={density}
            variant={variant}
            labelClassName={classNames?.label}
          >
            {inputGroup}
          </NotchFrame>
        ) : (
          inputGroup
        )}

        <BaseUICombobox.Portal>
          {/* `neba-portal` is a hook, not a style: a portalled popup leaves the
              subtree its host may have scoped a CSS reset to. */}
          <BaseUICombobox.Positioner
            className="neba-portal z-(--neba-z-portal) [outline:none]"
            sideOffset={6}
          >
            <BaseUICombobox.Popup
              className={cx(
                popupClasses,
                radiusClasses[size],
                controlTextLeadingClasses[size],
                classNames?.popup
              )}
              style={surfaceSlots(family, 3)}
            >
              <BaseUICombobox.Empty className="px-2 py-1.5 text-(--neba-muted-fg) empty:hidden">
                {emptyMessage ?? messages.empty}
              </BaseUICombobox.Empty>

              <BaseUICombobox.List>
                {(entry: Entry) => (
                  <BaseUICombobox.Item
                    key={`${entry.custom ? 'custom:' : ''}${String(entry.value)}`}
                    value={entry}
                    disabled={entry.disabled}
                    className={cx(itemClasses, classNames?.item)}
                  >
                    {entry.custom ? (
                      <React.Fragment>
                        <span className="absolute start-1.5 flex size-4 items-center justify-center text-(--n-accent) [&_svg]:size-4">
                          <PlusIcon />
                        </span>
                        <span className="truncate">
                          {customLabel
                            ? customLabel(entry.label)
                            : fillMessage(messages.add, { label: entry.label })}
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
        <Field.Description
          className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)', classNames?.description)}
        >
          {description}
        </Field.Description>
      ) : null}

      {hasError ? (
        <Field.Error
          match
          className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
        >
          {error}
        </Field.Error>
      ) : (
        // No message of our own, so whatever the validity has: the browser's
        // own text for a failed constraint, or the entry a Form's `errors`
        // put here. Renders nothing at all while the field is valid.
        <Field.Error
          className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
        />
      )}
    </Field.Root>
  );
}

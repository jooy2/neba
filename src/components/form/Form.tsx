'use client';

import * as React from 'react';
import { Form as BaseUIForm } from '@base-ui/react/form';
import { cx, sheetSectionGapClasses } from '../../internal/styles.js';
import type { NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * When a field decides whether it is valid.
 *
 * Base UI's own three, kept under its own spelling because they are what a
 * caller will read about everywhere else and a nicer synonym would only be a
 * word to translate back.
 */
export type FormValidationMode = 'onSubmit' | 'onBlur' | 'onChange';

/** Errors that came from somewhere else, keyed by the field's `name`. */
export type FormErrors = Record<string, string | string[]>;

export interface FormProps extends Omit<React.ComponentPropsWithoutRef<'form'>, 'onSubmit'> {
  /**
   * When a field validates.
   *
   * - `onSubmit` — on submit, and on every change afterwards. The default, and
   *   the only one that does not tell somebody their email is wrong while they
   *   are still typing it.
   * - `onBlur` — when a field loses focus.
   * - `onChange` — on every keystroke.
   * @default 'onSubmit'
   */
  validationMode?: FormValidationMode;
  /**
   * Errors from outside the browser's own validation — a server, a form action,
   * a schema — keyed by the `name` of the field each belongs to. They are shown
   * on the field, and cleared as soon as that field changes.
   */
  errors?: FormErrors;
  /**
   * Called on a valid submit, with the form's values. When it is given, the
   * native submit event is prevented, so nothing navigates. Without it the
   * submit goes ahead, which is what lets an `action` run (a function `action`
   * is React 19's).
   */
  onSubmit?: (values: Record<string, unknown>) => void;
  /**
   * The gap between the form's children. A form is a stack, and this is which
   * rung of the ladder it stacks on.
   * @default 'md'
   */
  size?: NebaSize;
  children?: React.ReactNode;
}

/**
 * A `<form>` that knows which of its fields is wrong.
 *
 * On its own, a page of [TextField](./text-field)s validates one field at a
 * time and a failed submit leaves the reader to find the red one. What this
 * adds is the part that has to be owned above the fields: a submit collects
 * every field's validity at once, focuses the first one that failed, and
 * `errors` puts a server's answer back on the field it belongs to rather than
 * in a banner at the top.
 *
 * It is not a form *library*. There is no schema, no resolver and no field
 * array here — a project that wants those keeps them and hands the result to
 * `errors`, which is the seam this is built around.
 */
/**
 * The values a field carries a list under, as the list.
 *
 * Base UI keys `values` by the fields registered with it, one value each, and a
 * DateRangePicker's two ends or a multiple TreeSelect's choices are one name
 * with several inputs under it. The picker marks the input it registers, and
 * the name it carries is read back from the form as `FormData.getAll` reads it,
 * so what `onSubmit` is handed agrees with what a native submit sends.
 */
function withRepeated(
  values: Record<string, unknown>,
  form: EventTarget | null
): Record<string, unknown> {
  if (!(form instanceof HTMLFormElement)) {
    return values;
  }

  const marked = form.querySelectorAll<HTMLInputElement>(
    'input[data-neba-repeats][name]:not(:disabled)'
  );

  if (marked.length === 0) {
    return values;
  }

  const data = new FormData(form);
  const next = { ...values };

  for (const input of marked) {
    next[input.name] = data.getAll(input.name);
  }

  return next;
}

export const Form = React.forwardRef<HTMLFormElement, FormProps>(function Form(rawProps, ref) {
  const {
    validationMode = 'onSubmit',
    errors,
    onSubmit,
    size = 'md',
    className,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size']);
  return (
    <BaseUIForm
      ref={ref}
      validationMode={validationMode}
      errors={errors}
      // Only when there is somebody to hand the values to. Base UI prevents the
      // native submit whenever this is set, and React then skips a function
      // `action` for a prevented submit — so passing it unconditionally made
      // `<Form action={…}>` a form that did nothing at all.
      onFormSubmit={
        onSubmit
          ? (values, details) => onSubmit(withRepeated(values, details.event.target))
          : undefined
      }
      className={cx('flex flex-col', sheetSectionGapClasses[size], className ?? '')}
      {...props}
    >
      {children}
    </BaseUIForm>
  );
});

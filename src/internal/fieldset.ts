'use client';

import * as React from 'react';

/**
 * Whether a Fieldset around a field is disabled.
 *
 * Base UI's own Fieldset already stops every field inside it answering, and
 * says nothing a Neba component can read: its context is not part of the
 * package's public exports. So a field went on drawing itself available inside
 * a disabled group, because each one decides how it looks from its own
 * `disabled` prop. This is the half Base UI does not carry.
 */
export const FieldsetDisabledContext = React.createContext(false);

/** A field's own `disabled`, or the Fieldset's around it. */
export function useFieldsetDisabled(disabled: boolean | undefined): boolean {
  return React.useContext(FieldsetDisabledContext) || disabled === true;
}

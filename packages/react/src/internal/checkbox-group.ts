'use client';

import * as React from 'react';
import type { NebaColor, NebaSize } from '../types.js';

/**
 * What a Checkbox inherits from the CheckboxGroup around it.
 *
 * A Checkbox is a component in its own right and a group of them is a second
 * one, so the context lives here rather than in either folder: Checkbox reads
 * it without importing the group, which is the arrangement `button-group.ts`
 * makes for a Button and the ButtonGroup around it.
 *
 * Unlike that context every field here is filled in, because the group has
 * already settled each of them. A Checkbox's own prop still wins over `size`,
 * `color`, `readOnly` and `name`. `invalid` and `disabled` win over the
 * Checkbox instead: a question that was answered wrongly is wrong in every
 * option, and a disabled group cannot hold an option that answers.
 *
 * `name` is the half Base UI does not carry. Its group takes the name from the
 * Field around it, and each Neba Checkbox draws a Field of its own, so without
 * this the inputs would reach a native submit with no name at all.
 */
export interface CheckboxGroupContextValue {
  size: NebaSize;
  color: NebaColor;
  invalid: boolean;
  disabled: boolean;
  readOnly: boolean;
  name: string | undefined;
}

export const CheckboxGroupContext = React.createContext<CheckboxGroupContextValue | null>(null);

'use client';

import * as React from 'react';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../types.js';

/**
 * What a Button inherits from the ButtonGroup around it — and what a Toggle
 * inherits from the ToggleGroup around it, which is the same six values and so
 * is the same context rather than a second one spelled identically.
 *
 * The alternative — `React.Children.map` with `cloneElement` — breaks the moment
 * a caller wraps one of the buttons in a Tooltip, a `<Fragment>` or a `.map()`,
 * which is most of the time. A context reaches the Button wherever it ended up.
 *
 * Every field is optional and every one of them means "not specified": a Button
 * falls back to its own default rather than to a value the group invented, so
 * `<ButtonGroup>` with no props changes nothing except the corners.
 *
 * It lives in `internal/` rather than in the button-group folder so that Button
 * can read it without the two components importing each other — and by now four
 * components read it, which is the arrangement `menu.ts` makes for the same
 * reason.
 */
export interface ButtonGroupContextValue {
  variant?: NebaVariant;
  size?: NebaSize;
  color?: NebaColor;
  density?: NebaDensity;
  elevation?: NebaElevation;
  disabled?: boolean;
}

export const ButtonGroupContext = React.createContext<ButtonGroupContextValue | null>(null);

import * as React from 'react';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaVariant } from '../types.js';

/**
 * What a Button inherits from the ButtonGroup around it.
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
 * can read it without the two components importing each other.
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

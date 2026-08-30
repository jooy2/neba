'use client';

import * as React from 'react';
import type { AvatarShape } from '../components/avatar/Avatar.js';
import type { NebaColor, NebaElevation, NebaSize, NebaVariant } from '../types.js';

/**
 * What an Avatar inherits from the AvatarGroup around it.
 *
 * `button-group.ts`'s arrangement, one component over and for the same reason:
 * a stack of avatars where the fourth one is a size out is not a stack, and
 * `React.Children.map` with `cloneElement` stops working the moment a caller
 * wraps one of them in a Tooltip or produces them from a `.map()`.
 *
 * It lives here rather than in the avatar-group folder so that Avatar can read
 * it without the two components importing each other.
 */
export interface AvatarGroupContextValue {
  size?: NebaSize;
  shape?: AvatarShape;
  variant?: NebaVariant;
  color?: NebaColor;
  elevation?: NebaElevation;
}

export const AvatarGroupContext = React.createContext<AvatarGroupContextValue | null>(null);

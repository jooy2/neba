'use client';

import * as React from 'react';
import type { NebaDensity, NebaSize, NebaVariant } from '../types.js';

/**
 * The prop values an application can set once instead of at every call site.
 *
 * Four, and the list is closed on purpose. These are the axes whose right value
 * is a property of the *product* rather than of the control — a dense
 * application is dense everywhere, and a Korean one is Korean everywhere.
 *
 * `color` is deliberately not among them. A component's colour default is often
 * semantic — an Alert is `info`, a Popconfirm is `danger`, severity carries
 * meaning — and one global override would silently repaint those into
 * something that means something else. `elevation` is out for the design
 * language's reason: a shadow is opt-in, per surface, and an application-wide
 * one is the moulded-plastic look the whole thing is against.
 */
export interface NebaDefaults {
  size?: NebaSize;
  density?: NebaDensity;
  variant?: NebaVariant;
  /** BCP 47 tag for every component that says a word on its own behalf. */
  locale?: string;
}

/** Which of the four a given component actually accepts. */
export type DefaultableKey = keyof NebaDefaults;

/**
 * `null` when there is no provider, which is the common case and the one worth
 * making free: `useStyleDefaults` hands the props straight back without
 * allocating, so a page with no provider pays a `useContext` and nothing else.
 */
export const DefaultsContext = /* @__PURE__ */ React.createContext<NebaDefaults | null>(null);

/**
 * Fills in the axes the caller left out, from the provider above.
 *
 * Called by every component that takes one of them, with the props it was
 * given, *before* its own destructuring runs — so the order of precedence is
 * the one a reader expects: the call site, then the provider, then the
 * component's own literal default.
 *
 * The keys are passed in rather than worked out, and that is load-bearing. A
 * key a component does not destructure stays in the props it spreads onto its
 * root, so filling `density` into a component that has none would put
 * `density="compact"` on a `<div>` — and `size` on an `<input>` is a real
 * attribute that would quietly resize the field.
 */
export function useStyleDefaults<P extends object>(props: P, keys: DefaultableKey[]): P {
  const defaults = React.useContext(DefaultsContext);

  if (!defaults) {
    return props;
  }

  const given = props as Record<string, unknown>;
  let filled: Record<string, unknown> | null = null;

  for (const key of keys) {
    const value = defaults[key];

    if (value !== undefined && given[key] === undefined) {
      filled = filled ?? { ...given };
      filled[key] = value;
    }
  }

  return (filled ?? given) as P;
}

'use client';

import * as React from 'react';

/**
 * Whether this subtree is drawn on a Mockup's screen.
 *
 * A picture of a page is not the page. A `PageLayout` on a Mockup's screen
 * would otherwise add a second `<main>`, a second `id="main"` and a second skip
 * link to a document that already has its own, so the layout reads this and
 * leaves all three out. It is a module of its own so that a Mockup providing it
 * does not import the layout, and a layout reading it does not import the
 * device.
 */
export const ScreenContext = React.createContext(false);

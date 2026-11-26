'use client';

import * as React from 'react';

/**
 * `useLayoutEffect` in a browser and `useEffect` on a server.
 *
 * A layout effect is how a component measures itself or corrects a value before
 * the frame is painted, which is why the library has so many of them. On a
 * server there is nothing to measure and nothing to paint, and React 18's server
 * renderer says so with a warning for every component that asks — once per
 * component per request, in the console of whoever renders the page. React 19
 * dropped the warning; the peer range still promises 18.
 *
 * Chosen once, when the module is evaluated, rather than per call: the choice is
 * about the environment, which does not change between renders, and a hook that
 * is sometimes one function and sometimes the other within one process would
 * break the rules of hooks.
 */
export const useLayoutEffectOnClient =
  typeof document === 'undefined' ? React.useEffect : React.useLayoutEffect;

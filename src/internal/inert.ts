import * as React from 'react';

/**
 * The value that puts `inert` on an element in the React the page is running.
 *
 * React 19 knows `inert` as a boolean attribute and writes it for `true`. React
 * 18 does not know it at all: it drops a boolean on an attribute it does not
 * know, with a warning, and writes a string as it is. So under 18 the attribute
 * is only written for `''`, and under 19 an empty string is read as false and
 * warned about. Both are inside the peer range, and a panel that is meant to be
 * out of reach and is not is a keyboard reader tabbing into hidden content.
 *
 * `false` is always `undefined`, which removes the attribute under either.
 */
export function inertValue(on: boolean, version: string = React.version): boolean | undefined {
  if (!on) {
    return undefined;
  }

  return Number.parseInt(version, 10) >= 19 ? true : ('' as unknown as boolean);
}

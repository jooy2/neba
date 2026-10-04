import type * as React from 'react';

/**
 * Characters drawn about twice as wide as a Latin letter: Hangul, the CJK
 * blocks and the fullwidth forms. An emoji needs no entry, since it is already
 * two UTF-16 units long.
 */
const wide =
  /[\u1100-\u115f\u2e80-\ua4cf\uac00-\ud7a3\uf900-\ufaff\ufe30-\ufe4f\uff00-\uff60\uffe0-\uffe6]/g;

/** A string's length, in units of roughly half an em. */
function roughLength(text: string): number {
  return text.length + (text.match(wide)?.length ?? 0);
}

/**
 * The share of the longest string's length a string has to reach to be laid
 * out at all.
 *
 * A length is not a width, and the gap between the two is what this absorbs.
 * Capitals take about a third more room per character than lower case, a run
 * of `i`s and `l`s far less, and a combining mark counts as a character while
 * taking no room at all. Across the labels a list actually holds, the room one
 * character takes stays well inside two and a half times what another's does,
 * so a string under two fifths of the longest one's length is never the widest
 * — and a box laid out for it reserves nothing another sample has not already
 * reserved.
 */
const CONTENDER = 0.4;

/**
 * The samples a `WidthSizer` needs, out of all of them.
 *
 * Only the widest sample decides the width, so a Select with two hundred and
 * fifty countries was two hundred and fifty boxes laid out for the sake of one.
 * A string is kept when it is long enough to be the widest and dropped
 * otherwise. Anything that is not a string is kept whatever it is, since
 * nothing short of laying it out says how wide a node is.
 */
export function widestSamples(samples: readonly React.ReactNode[]): React.ReactNode[] {
  let longest = 0;

  for (const sample of samples) {
    if (typeof sample === 'string') {
      longest = Math.max(longest, roughLength(sample));
    }
  }

  return samples.filter(
    (sample) => typeof sample !== 'string' || roughLength(sample) >= longest * CONTENDER
  );
}

/**
 * Holds a control open at the width of the widest thing it could ever say.
 *
 * A control that is not `fullWidth` is sized by what it is *currently* saying,
 * which for anything whose value changes means the box changes with it. A Select
 * showing `Seoul` is narrower than the same Select showing `Washington DC`; a
 * DatePicker on the 1st is fourteen pixels narrower than the same picker on the
 * 28th. Either way the field moves under the pointer that just used it, and the
 * whole row of controls beside it shuffles along.
 *
 * So the alternatives are laid out too, stacked in a box that is clipped to no
 * height. The control's intrinsic width becomes the widest of them and stops
 * depending on the value.
 *
 * Three things it deliberately is not:
 *
 * - **Not `hidden`, and not `display: none`.** Both take the box out of layout,
 *   and a box that is not laid out reserves nothing.
 * - **Not read out.** `aria-hidden`, or a screen reader would announce every
 *   value the control might hold before the one it does.
 * - **Not text.** A string sample is drawn as generated content off a data
 *   attribute rather than as a text node. `content: attr(…)` lays out exactly
 *   like text, so it reserves the same width — but it leaves nothing for
 *   `getByText` or a screen reader's find-in-page to trip over, and a caller's
 *   test asking for the option they selected keeps finding one element rather
 *   than two. Only a sample that is not a string — a Select option whose label
 *   is a node — has to be rendered for real, because there is nothing to put in
 *   an attribute.
 */
export function WidthSizer({ samples }: { samples: readonly React.ReactNode[] }) {
  if (samples.length === 0) {
    return null;
  }

  return (
    <span aria-hidden="true" className="invisible h-0 min-h-0 overflow-hidden">
      {samples.map((sample, index) =>
        typeof sample === 'string' ? (
          <span
            key={`${index}:${sample}`}
            data-sample={sample}
            className="block whitespace-nowrap before:content-[attr(data-sample)]"
          />
        ) : (
          <span key={index} className="block whitespace-nowrap">
            {sample}
          </span>
        )
      )}
    </span>
  );
}

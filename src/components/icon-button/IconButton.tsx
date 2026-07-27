import * as React from 'react';
import { Button, type ButtonProps } from '../button/Button';

export interface IconButtonProps extends Omit<ButtonProps, 'children' | 'startIcon' | 'endIcon'> {
  /**
   * The glyph. Wrap it in an `Icon` when it needs a size of its own; passed bare
   * it is sized in `em` against the button, exactly as a `startIcon` is.
   */
  icon: React.ReactNode;
  /**
   * What the button does, in words.
   *
   * Required, and the one prop here that is. A button whose whole label is a
   * drawing has no accessible name at all, and "an icon button with no
   * `aria-label`" is the single most common accessibility defect a component
   * library ships. Making it required is the only fix that survives review.
   */
  label: string;
}

/**
 * A round button with a glyph in it and nothing else.
 *
 * A [Button] with an icon and no children already goes square — the same height,
 * the same width, the acrylic corners cut off it. This is the other shape: a
 * disc.
 *
 * That disc is a deliberate exception to the house radius rule, which holds
 * every corner just short of the 50% that would make a control a pill, because
 * the flat run along the top and bottom edge is what still reads as a sheet with
 * its corners cut. The rule is about *labelled* controls: the flat run is there
 * for the line of text to sit on, and a glyph has no line of text. A circle with
 * a single mark centred in it is a punched token rather than a moulded key, so
 * it says the thing the rule exists to protect by a different route.
 *
 * Everything else is Button's, unchanged and on purpose: the variants, the
 * elevation ladder, the pointer light, `loading`, `readOnly`, and the values a
 * surrounding ButtonGroup sets. Two components that draw the same surface from
 * two copies of the same table are two components that will eventually disagree.
 */
export const IconButton = React.forwardRef<HTMLButtonElement, IconButtonProps>(function IconButton(
  { icon, label, style, ...props },
  ref
) {
  return (
    <Button
      ref={ref}
      aria-label={label}
      // The icon goes in `startIcon` rather than in `children`, which is what
      // puts Button on its icon-only path: square footprint, no horizontal
      // padding, and the spinner taking the glyph's place while `loading`.
      startIcon={icon}
      // An inline style rather than `rounded-full`, and for once not as a
      // shortcut. Button already writes a `rounded-*` utility of its own, and two
      // utilities setting the same property resolve by their order in the
      // generated stylesheet — which is not something a component may depend on.
      // An inline declaration is the one form that wins deterministically, and it
      // still leaves the caller's own `style` free to override it below.
      style={{ borderRadius: '9999px', ...style }}
      {...props}
    />
  );
});

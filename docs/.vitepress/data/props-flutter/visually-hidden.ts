import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  VisuallyHidden: [
    renamed('VisuallyHidden', 'children', 'child', { type: WIDGET }),
    from('VisuallyHidden', 'visible', { type: 'bool' })
  ]
} satisfies Record<string, PropRow[]>;

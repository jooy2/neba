import {
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Box: [
    variantRow('Box', 'NebaVariant.outline'),
    sizeRow('Box'),
    from('Box', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Box'),
    elevationRow('Box'),
    from('Box', 'padded', { type: 'bool' }),
    renamed('Box', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;

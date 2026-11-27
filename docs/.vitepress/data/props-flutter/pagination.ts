import { densityRow, from, renamed, sizeRow, variantRow, type PropRow } from './shared';

export default {
  Pagination: [
    from('Pagination', 'locale', { type: 'Locale?', default: undefined }),
    variantRow('Pagination', 'NebaVariant.text'),
    sizeRow('Pagination'),
    from('Pagination', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Pagination', 'NebaDensity.compact'),
    from('Pagination', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Pagination', 'count', { type: 'int' }),
    from('Pagination', 'page', { type: 'int?' }),
    from('Pagination', 'defaultPage', { type: 'int' }),
    from('Pagination', 'onPageChange', { type: 'ValueChanged<int>?' }),
    from('Pagination', 'siblingCount', { type: 'int' }),
    from('Pagination', 'boundaryCount', { type: 'int' }),
    from('Pagination', 'showEdges', { type: 'bool' }),
    from('Pagination', 'showArrows', { type: 'bool' }),
    from('Pagination', 'disabled', { type: 'bool' }),
    renamed('Pagination', 'label', 'semanticLabel', { type: 'String?' }),
    from('Pagination', 'pageLabel', { type: 'String Function(int page)?' }),
    from('Pagination', 'previousLabel', { type: 'String?' }),
    from('Pagination', 'nextLabel', { type: 'String?' }),
    from('Pagination', 'firstLabel', { type: 'String?' }),
    from('Pagination', 'lastLabel', { type: 'String?' })
  ]
} satisfies Record<string, PropRow[]>;

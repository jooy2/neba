import { densityRow, from, renamed, sizeRow, variantRow, type PropRow } from './shared';

export default {
  Table: [
    variantRow('Table', 'NebaVariant.outline'),
    sizeRow('Table'),
    from('Table', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Table'),
    from('Table', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Table', 'headers', { type: 'List<NebaTableColumn<T>>' }),
    from('Table', 'items', { type: 'List<T>' }),
    renamed('Table', 'getRowKey', 'rowKey', {
      type: 'LocalKey Function(T row, int index)?',
      description: {
        ko: '행의 key. 정렬이나 필터로 행이 움직여도 행의 상태가 그 행을 따라갑니다. 생략하면 위치가 key입니다',
        en: 'A row’s key, which keeps its state with it when sorting or filtering moves the rows. Left out, the position is the key'
      }
    }),
    from('Table', 'caption', { type: 'Widget?' }),
    from('Table', 'empty', { type: 'Widget?' }),
    from('Table', 'striped', { type: 'bool' }),
    from('Table', 'hoverable', { type: 'bool' }),
    from('Table', 'stickyHeader', { type: 'bool' }),
    from('Table', 'maxHeight', {
      type: 'double?',
      description: {
        ko: '행이 스크롤되기 전까지 표가 커질 수 있는 최대 높이(논리 픽셀). 가장자리까지 포함한 시트 전체에 적용됩니다',
        en: 'The tallest the table grows before its rows scroll, in logical pixels, for the whole sheet with its edge'
      }
    }),
    renamed('Table', 'onRowClick', 'onRowPressed', { type: 'void Function(T row, int index)?' }),
    from('Table', 'locale', { type: 'Locale?', default: undefined }),
    {
      name: 'transition',
      type: 'NebaTransition?',
      description: {
        ko: '처음 빌드될 때 한 번 실행되는 등장 애니메이션 (`const NebaTransition.fade()`)',
        en: 'An entrance animation, run once when the table is first built (`const NebaTransition.fade()`)'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

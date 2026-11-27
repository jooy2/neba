import { from, renamed, sizeRow, densityRow, WIDGET, type PropRow } from './shared';

export default {
  Anchor: [
    from('Anchor', 'items', { type: 'List<NebaAnchorItem>' }),
    renamed('Anchor', 'activeHref', 'activeTarget', {
      type: 'GlobalKey?',
      description: {
        ko: '표시할 제목. 직접 정하면 추적은 계속 돌아가므로 onActiveChange는 여전히 읽는 위치를 알려 줍니다',
        en: 'The heading whose row is marked, when you decide it. The tracking keeps running, so onActiveChange still reports where the reader is'
      }
    }),
    from('Anchor', 'onActiveChange', {
      type: 'ValueChanged<GlobalKey?>?',
      description: {
        ko: '읽는 사람이 들어간 제목이 바뀔 때 그 제목의 key로 불립니다. 첫 제목보다 위에서는 null입니다',
        en: 'Called with the key of the heading the reader has scrolled into, or null above the first'
      }
    }),
    from('Anchor', 'offset', { type: 'double' }),
    from('Anchor', 'rail', { type: 'bool' }),
    sizeRow('Anchor'),
    from('Anchor', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Anchor'),
    from('Anchor', 'locale', { type: 'Locale?', default: undefined }),
    renamed('Anchor', 'label', 'semanticLabel', { type: 'String?' })
  ],
  AnchorItem: [
    renamed('AnchorItem', 'href', 'target', {
      type: 'GlobalKey',
      description: {
        ko: '제목 위젯의 key. 행을 누르면 여기로 스크롤하고, 추적은 이 위젯의 위치를 잽니다. 그려지지 않은 제목은 표시되지 않습니다',
        en: 'The key of the heading’s widget: what a row scrolls to and what the tracking measures. A heading that is not built is never marked'
      }
    }),
    from('AnchorItem', 'label', { type: WIDGET }),
    from('AnchorItem', 'depth', { type: 'int' })
  ]
} satisfies Record<string, PropRow[]>;

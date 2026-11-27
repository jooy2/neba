import { from, renamed, type PropRow } from './shared';

export default {
  Skeleton: [
    from('Skeleton', 'shape', { type: 'NebaSkeletonShape', default: 'NebaSkeletonShape.line' }),
    from('Skeleton', 'lines', { type: 'int' }),
    from('Skeleton', 'size', { type: 'NebaSize?', default: 'NebaSize.md' }),
    from('Skeleton', 'color', { type: 'NebaColor?', default: 'NebaColor.secondary' }),
    from('Skeleton', 'width', {
      type: 'double?',
      description: {
        ko: '너비(논리 픽셀). 줄과 블록은 없으면 주어진 너비를 차지하고, 원은 정사각형입니다. 남은 공간의 일부만큼 그리려면 FractionallySizedBox로 감싸세요',
        en: 'The width in logical pixels. A line and a block take the width they are given without one, and a disc is square. A fraction of the room is a FractionallySizedBox around it'
      }
    }),
    from('Skeleton', 'height', {
      type: 'double?',
      description: {
        ko: '블록의 높이(논리 픽셀). double.infinity면 주어진 높이를 채웁니다',
        en: 'The height of a block in logical pixels; double.infinity fills the height it is given'
      }
    }),
    from('Skeleton', 'animated', { type: 'bool' }),
    renamed('Skeleton', 'label', 'semanticLabel', {
      type: 'String?',
      description: {
        ko: '기다리는 동안 화면 낭독기에 알릴 말. 주면 live region이 되고, 없으면 아무것도 알리지 않습니다',
        en: 'What a screen reader is told while it waits; given, the skeleton is a live region, and left out it says nothing'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;

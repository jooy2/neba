import { densityRow, from, renamed, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  Badge: [
    variantRow('Badge'),
    sizeRow('Badge'),
    from('Badge', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    densityRow('Badge'),
    from('Badge', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Badge', 'content', {
      type: `${WIDGET}?`,
      description: {
        ko: '표식에 들어갈 내용. 보통 Text이며, 생략하면 점이 됩니다. 숫자는 NebaBadge.count의 count로 넘깁니다',
        en: 'What the mark says, usually a Text; left out, the badge is a dot. A number goes to NebaBadge.count as count'
      }
    }),
    {
      name: 'count',
      type: 'int',
      description: {
        ko: 'NebaBadge.count가 보여 주는 숫자. max를 넘으면 99+로 줄이고, 0은 showZero가 없으면 감춥니다',
        en: 'The number NebaBadge.count shows: capped past max as 99+, and hidden at zero unless showZero'
      }
    },
    from('Badge', 'max', {
      type: 'int',
      description: {
        ko: 'NebaBadge.count에서 그대로 보여 줄 가장 큰 수. 넘으면 뒤에 +를 붙입니다',
        en: 'With NebaBadge.count, the largest count shown as it is; above it the badge adds a +'
      }
    }),
    from('Badge', 'dot', { type: 'bool' }),
    from('Badge', 'showZero', {
      type: 'bool',
      description: {
        ko: 'NebaBadge.count에서 0을 보여 줄지 여부',
        en: 'With NebaBadge.count, whether a count of zero is shown'
      }
    }),
    from('Badge', 'invisible', { type: 'bool' }),
    from('Badge', 'placement', { type: 'NebaCorner', default: 'NebaCorner.topEnd' }),
    from('Badge', 'overlap', { type: 'NebaBadgeOverlap', default: 'NebaBadgeOverlap.square' }),
    renamed('Badge', 'label', 'semanticLabel', { type: 'String?' }),
    renamed('Badge', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;

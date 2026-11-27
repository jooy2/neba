import {
  densityRow,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Card: [
    variantRow('Card', 'NebaVariant.outline'),
    sizeRow('Card'),
    from('Card', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Card'),
    from('Card', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Card', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목. 보통 Text이며, 화면 개요에 넣어야 하면 Semantics(header: true, …)로 감싸세요. 제목의 타입은 그대로 유지됩니다',
        en: 'The heading, usually a Text. Wrap it in Semantics(header: true, …) when it belongs in the outline; it keeps the title type'
      }
    }),
    from('Card', 'subtitle', { type: `${WIDGET}?` }),
    from('Card', 'headerAction', { type: `${WIDGET}?` }),
    from('Card', 'footer', {
      type: `${WIDGET}?`,
      description: {
        ko: '아래 영역. 본문의 타입으로 그려집니다. 버튼 여러 개는 Row나 NebaFlex로 묶고, Spacer로 하나를 끝으로 밀 수 있습니다',
        en: 'The bottom area, in the body type. Several buttons go in a Row or a NebaFlex, where a Spacer pushes one to the end'
      }
    }),
    from('Card', 'dividers', { type: 'bool' }),
    renamed('Card', 'children', 'child', { type: `${WIDGET}?` }),
    transitionRow('Card', 'const NebaTransition.grow()')
  ]
} satisfies Record<string, PropRow[]>;

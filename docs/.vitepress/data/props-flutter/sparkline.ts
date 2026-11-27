import { from, sizeRow, type PropRow } from './shared';

export default {
  Sparkline: [
    from('Sparkline', 'data', {
      type: 'List<Object?>',
      description: {
        ko: '값들. 각 값은 num, 결측을 뜻하는 null, 또는 NebaChartPoint입니다. 다른 차트와 마찬가지로 null은 결측입니다',
        en: 'The values: each a num, a null for a gap, or a NebaChartPoint. null is a gap, exactly as it is on every other chart'
      }
    }),
    from('Sparkline', 'shape', {
      type: 'NebaSparklineShape',
      default: 'NebaSparklineShape.line'
    }),
    from('Sparkline', 'curve', { type: 'NebaChartCurve', default: 'NebaChartCurve.linear' }),
    from('Sparkline', 'nulls', { type: 'NebaChartNulls', default: 'NebaChartNulls.gap' }),
    sizeRow('Sparkline'),
    from('Sparkline', 'color', {
      type: 'Object?',
      description: {
        ko: '마크의 색. NebaColor 이름이나 Color를 받습니다. 전체 차트와 달리 색을 직접 받습니다. series가 하나이고 팔레트가 나눠 줄 범례도 없기 때문입니다',
        en: "The mark's colour, a NebaColor family or a Color, taken directly unlike the full charts: a sparkline has one series and no legend for a palette to hand out"
      }
    }),
    from('Sparkline', 'endDot', { type: 'bool' }),
    from('Sparkline', 'baseline', { type: 'double?' }),
    from('Sparkline', 'min', { type: 'double?' }),
    from('Sparkline', 'max', { type: 'double?' }),
    from('Sparkline', 'width', {
      type: 'double?',
      default: { ko: '부모의 너비', en: "the parent's width" },
      description: {
        ko: '너비(논리 픽셀). 기본은 부모의 너비를 채우고, 너비를 주지 않는 Row 안에서는 120입니다',
        en: "How wide, in logical pixels. Fills the parent's width by default, and is 120 in a row that gives it none"
      }
    }),
    from('Sparkline', 'label', {
      type: 'String?',
      description: {
        ko: '띠의 이름. 주면 그 이름의 이미지로 읽히고 값들이 뒤따라 읽힙니다. 주지 않으면 semantics 트리에서 완전히 빠집니다',
        en: 'A name for the strip. With one it is read as an image of that name, its values after it; without one it is left out of the semantics tree entirely'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;

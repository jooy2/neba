import { from, WIDGET, type PropRow } from './shared';
import { chartBaseRows } from './line-chart';

export default {
  PieChart: [
    from('PieChart', 'data', {
      type: 'List<Object?>',
      description: {
        ko: '조각들. 각 항목은 num, 값이 없는 조각을 뜻하는 null, 또는 자기 이름과 색을 들고 있는 NebaChartPoint입니다. pie는 series가 하나이므로 series 목록이 아니라 값의 목록을 받습니다',
        en: 'The slices: each a num, a null for a slice with no value, or a NebaChartPoint that carries its own name and colour. A pie has one series, so it takes the values directly'
      }
    }),
    from('PieChart', 'categories', { type: 'List<Object>?' }),
    from('PieChart', 'shape', { type: 'NebaPieShape', default: 'NebaPieShape.pie' }),
    from('PieChart', 'startAngle', { type: 'double' }),
    from('PieChart', 'hole', { type: 'double?' }),
    from('PieChart', 'gap', { type: 'double' }),
    from('PieChart', 'center', { type: `${WIDGET}?` }),
    from('PieChart', 'valueLabels', {
      type: 'NebaChartValueLabels',
      default: 'NebaChartValueLabels.none',
      description: {
        ko: 'all이면 각 조각에 그 비중을 씁니다. 글자가 양옆 여유까지 들어갈 만큼 넓은 조각에만 그려지고, 들어가지 않으면 잘리는 대신 그려지지 않습니다. pie는 none과 all만 읽습니다',
        en: "all writes each slice's share on it, only where the text fits with room on both sides; one that does not fit is dropped rather than clipped. A pie reads none and all only"
      }
    }),
    ...chartBaseRows('PieChart')
  ]
} satisfies Record<string, PropRow[]>;

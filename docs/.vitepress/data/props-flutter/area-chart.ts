import { from, type PropRow } from './shared';
import { cartesianRows, chartBaseRows } from './line-chart';

export default {
  AreaChart: [
    ...cartesianRows('AreaChart'),
    from('AreaChart', 'stacked', {
      type: 'NebaChartStacking',
      default: 'NebaChartStacking.off',
      description: {
        ko: 'on은 밴드를 쌓아 위 가장자리가 합계가 되게 하고, full은 각 category를 100%로 정규화해 크기가 아니라 비중의 차트로 만듭니다. React의 boolean | full을 enum 하나로 씁니다',
        en: "on stacks the bands so the top edge is the total; full normalises every category to 100%, which makes the chart about the mix rather than the size. React's boolean | 'full' as one enum"
      }
    }),
    from('AreaChart', 'curve', { type: 'NebaChartCurve', default: 'NebaChartCurve.linear' }),
    from('AreaChart', 'markers', { type: 'NebaChartMarkers', default: 'NebaChartMarkers.none' }),
    from('AreaChart', 'valueLabels', {
      type: 'NebaChartValueLabels',
      default: 'NebaChartValueLabels.none'
    }),
    from('AreaChart', 'nulls', { type: 'NebaChartNulls', default: 'NebaChartNulls.gap' }),
    ...chartBaseRows('AreaChart')
  ]
} satisfies Record<string, PropRow[]>;

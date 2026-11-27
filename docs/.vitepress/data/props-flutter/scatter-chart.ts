import { from, type PropRow } from './shared';
import { chartBaseRows } from './line-chart';

export default {
  ScatterChart: [
    from('ScatterChart', 'series', { type: 'List<NebaChartSeries>' }),
    from('ScatterChart', 'categories', {
      type: 'List<Object>?',
      description: {
        ko: '점이 x를 직접 들고 있지 않을 때 index로 찾아 쓰는 x 값. num이나 DateTime이어야 하고, 문자열은 수직선 위의 자리가 아니므로 그 점은 그려지지 않습니다',
        en: 'The x of a point that does not carry its own, found by index: a num or a DateTime. A string is not a place on a number line, so a point placed by one is not drawn'
      }
    }),
    from('ScatterChart', 'xAxis', { type: 'NebaChartAxis?' }),
    from('ScatterChart', 'yAxis', { type: 'NebaChartAxis?' }),
    from('LineChart', 'references', { type: 'List<NebaChartReference>?' }),
    from('ScatterChart', 'shape', {
      type: 'NebaScatterShape',
      default: 'NebaScatterShape.auto'
    }),
    from('ScatterChart', 'pointRadius', { type: 'double?' }),
    from('ScatterChart', 'maxRadius', { type: 'double?' }),
    ...chartBaseRows('ScatterChart')
  ]
} satisfies Record<string, PropRow[]>;

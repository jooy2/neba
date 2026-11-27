import { from, type PropRow } from './shared';
import { cartesianRows, chartBaseRows } from './line-chart';

export default {
  BarChart: [
    ...cartesianRows('BarChart'),
    from('BarChart', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.vertical'
    }),
    from('BarChart', 'stacked', {
      type: 'NebaChartStacking',
      default: 'NebaChartStacking.off',
      description: {
        ko: 'off인 묶인 막대는 "어느 series가 더 큰가"에, on인 쌓인 막대는 "이 합계가 무엇으로 되어 있나"에 답합니다. full은 비중을 묻습니다. React의 boolean | full을 enum 하나로 씁니다',
        en: 'Grouped bars (off) answer "which series is bigger"; stacked bars (on) answer "what is this total made of"; full asks about the mix. React\'s boolean | \'full\' as one enum'
      }
    }),
    from('BarChart', 'rounded', { type: 'bool' }),
    from('BarChart', 'barSize', { type: 'double?' }),
    from('BarChart', 'valueLabels', {
      type: 'NebaChartValueLabels',
      default: 'NebaChartValueLabels.none'
    }),
    ...chartBaseRows('BarChart')
  ]
} satisfies Record<string, PropRow[]>;

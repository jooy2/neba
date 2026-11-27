import { from, type PropRow } from './shared';
import { chartBaseRows } from './line-chart';

export default {
  HeatmapChart: [
    from('HeatmapChart', 'series', { type: 'List<NebaChartSeries>' }),
    from('HeatmapChart', 'categories', { type: 'List<Object>?' }),
    from('HeatmapChart', 'shape', { type: 'NebaHeatmapShape', default: 'NebaHeatmapShape.grid' }),
    from('HeatmapChart', 'scale', {
      type: 'NebaHeatmapScale',
      default: 'NebaHeatmapScale.sequential'
    }),
    from('HeatmapChart', 'midpoint', { type: 'double' }),
    from('HeatmapChart', 'min', { type: 'double?' }),
    from('HeatmapChart', 'max', { type: 'double?' }),
    from('HeatmapChart', 'valueLabels', {
      type: 'NebaChartValueLabels',
      default: 'NebaChartValueLabels.none',
      description: {
        ko: 'all이면 각 셀 위에 값을 씁니다. 들어갈 자리가 없는 라벨은 잘리는 대신 생략되고, 잉크는 셀의 단계에 따라 정해집니다. heatmap은 none과 all만 읽습니다',
        en: 'all writes each value on its cell. A label that does not fit is dropped rather than clipped, and its ink is picked from the step underneath it. A heatmap reads none and all only'
      }
    }),
    from('HeatmapChart', 'xAxis', { type: 'NebaChartAxis?' }),
    from('HeatmapChart', 'yAxis', { type: 'NebaChartAxis?' }),
    ...chartBaseRows('HeatmapChart').map((row) =>
      row.name === 'legend'
        ? from('HeatmapChart', 'legend', {
            type: 'Object?',
            description: {
              ko: 'true, false, 또는 side와 align을 읽는 NebaChartLegend. 양 끝에 값이 붙은 스케일 막대이고 swatch 목록이 아닙니다. 여기에는 이름을 가진 것이 없고 순서가 곧 의미입니다',
              en: 'true, false or a NebaChartLegend whose side and align are read. A scale bar with its ends labelled, not a list of swatches: nothing here has a name and the order is the meaning'
            }
          })
        : row
    )
  ]
} satisfies Record<string, PropRow[]>;

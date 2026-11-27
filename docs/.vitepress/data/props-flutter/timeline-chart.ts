import { from, type PropRow } from './shared';
import { chartBaseRows } from './line-chart';

export default {
  NebaTimelinePoint: [
    from('NebaTimelinePoint', 'start', {
      type: 'Object',
      description: {
        ko: '이 span이 시작하는 시각. DateTime 또는 밀리초 num입니다',
        en: 'When the span begins: a DateTime, or a num of milliseconds'
      }
    }),
    from('NebaTimelinePoint', 'end', { type: 'Object' }),
    from('NebaTimelinePoint', 'label', {
      type: 'String?',
      description: {
        ko: 'tooltip과 표에서 이 span을 부르는 이름. 캔버스와 표에 쓰는 글자라 문자열만 받습니다',
        en: 'What the span is called, in the tooltip and the table. Written on the canvas and in the table, so a string'
      }
    }),
    from('NebaTimelinePoint', 'color', {
      type: 'Object?',
      description: {
        ko: '이 span 하나만 행의 색 대신 이 색으로. NebaColor나 Color를 받습니다',
        en: "Overrides its row's colour for this one span: a NebaColor or a Color"
      }
    })
  ],

  TimelineChart: [
    from('TimelineChart', 'series', { type: 'List<NebaTimelineSeries>' }),
    from('TimelineChart', 'min', {
      type: 'Object?',
      description: {
        ko: '시간 축이 시작하는 지점. DateTime 또는 밀리초 num입니다. 생략하면 span에서 오고, 달력이 이름을 가진 날짜로 바깥쪽으로 반올림됩니다',
        en: 'Where the time axis starts: a DateTime, or a num of milliseconds. Taken from the spans otherwise, and rounded outward to a date a calendar has a name for'
      }
    }),
    from('TimelineChart', 'max', { type: 'Object?' }),
    from('TimelineChart', 'xAxis', { type: 'NebaChartAxis?' }),
    from('TimelineChart', 'yAxis', { type: 'NebaChartAxis?' }),
    from('LineChart', 'references', { type: 'List<NebaChartReference>?' }),
    from('TimelineChart', 'barSize', { type: 'double?' }),
    from('TimelineChart', 'rounded', { type: 'bool' }),
    ...chartBaseRows('TimelineChart', { legend: false })
  ]
} satisfies Record<string, PropRow[]>;

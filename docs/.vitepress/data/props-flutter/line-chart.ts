import { densityRow, from, renamed, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

/** The rows every cartesian chart opens with: its data and its axes. */
export function cartesianRows(component: string): PropRow[] {
  return [
    from(component, 'series', { type: 'List<NebaChartSeries>' }),
    from(component, 'categories', {
      type: 'List<Object>?',
      description: {
        ko: 'category 축의 위치 이름. String, num, DateTime을 받습니다. 대신 각 점이 x를 직접 들고 있어도 됩니다',
        en: "The category axis' labels: Strings, nums or DateTimes. Points may carry their own x instead"
      }
    }),
    from(component, 'xAxis', { type: 'NebaChartAxis?' }),
    from(component, 'yAxis', { type: 'NebaChartAxis?' }),
    from(component, 'secondaryAxis', { type: 'NebaChartAxis?' }),
    from(component, 'references', { type: 'List<NebaChartReference>?' })
  ];
}

/**
 * What every chart takes besides its data, as Dart spells it. `legend: false`
 * leaves out the legend row, for a chart that has none.
 */
export function chartBaseRows(component: string, options: { legend?: boolean } = {}): PropRow[] {
  return [
    variantRow(component, 'NebaVariant.text'),
    sizeRow(component),
    from(component, 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow(component),
    from(component, 'elevation', { type: 'NebaElevation', default: '0' }),
    {
      name: 'padded',
      type: 'bool',
      default: 'false',
      description: {
        ko: '시트가 차트 둘레에 여백을 둘지. 차트는 Card 안에 들어가는 그림이므로 꺼져 있습니다',
        en: 'Whether the sheet pads the chart. Off, since a chart is a drawing that goes inside a Card'
      }
    },
    from(component, 'height', {
      type: 'double?',
      description: {
        ko: '그림의 높이(논리 픽셀). 축 라벨도 이 높이 안에 그려지고, 범례는 그 바깥에 놓입니다',
        en: 'How tall the drawing is, in logical pixels. The axis labels are drawn inside it and the legend outside it'
      }
    }),
    from(component, 'label', { type: 'String?' }),
    from(component, 'format', {
      type: 'String Function(num value)?',
      description: {
        ko: '숫자를 쓰는 함수. 축·tooltip·값 라벨·표 모두에 쓰이고, 정수인 값은 int로 받습니다. 생략하면 만 이상은 축약하고(12.4K) 그 아래는 세 자리마다 쉼표로 묶습니다',
        en: 'Writes a number, everywhere one appears: the axis, the tooltip, the value labels, the table. A whole number arrives as an int. Left out, past ten thousand a number is compacted (12.4K) and below it grouped by threes'
      }
    }),
    from(component, 'locale', {
      type: 'Locale?',
      description: {
        ko: '차트가 스스로 쓰는 말의 언어. 이름, 설명 문장, 빈 상태의 문구입니다. 없으면 NebaProvider의 locale을, 그것도 없으면 앱의 locale을 씁니다',
        en: "The language of the chart's own words: its name, the sentence that describes it, its empty state. Falls back to NebaProvider's, then the app's"
      }
    }),
    ...(options.legend === false
      ? []
      : [
          from(component, 'legend', {
            type: 'Object?',
            description: {
              ko: 'true, false, 또는 NebaChartLegend. series가 둘 이상이면 자동으로 나오고 하나면 나오지 않습니다. 색 하나짜리 범례는 제목을 반복할 뿐입니다',
              en: 'true, false or a NebaChartLegend. Shown automatically from two series up and left off below that: a legend with one swatch restates the title'
            }
          })
        ]),
    from(component, 'tooltip', {
      type: 'Object?',
      description: {
        ko: 'true, false, 또는 NebaChartTooltip. tooltip에만 있는 값은 없습니다. 모든 값이 숨겨진 표에도 있습니다',
        en: 'true, false or a NebaChartTooltip. It never carries a value that is not also in the hidden table'
      }
    }),
    from(component, 'empty', { type: `${WIDGET}?` }),
    {
      name: 'transition',
      type: 'NebaTransition?',
      description: {
        ko: '처음 빌드될 때 한 번 실행되는 등장 애니메이션. 시트가 통째로 움직입니다',
        en: 'An entrance animation, run once when the chart is first built. The whole sheet moves'
      }
    }
  ];
}

export default {
  LineChart: [
    ...cartesianRows('LineChart'),
    from('LineChart', 'curve', { type: 'NebaChartCurve', default: 'NebaChartCurve.linear' }),
    from('LineChart', 'markers', { type: 'NebaChartMarkers', default: 'NebaChartMarkers.auto' }),
    from('LineChart', 'gradient', { type: 'bool' }),
    from('LineChart', 'nulls', { type: 'NebaChartNulls', default: 'NebaChartNulls.gap' }),
    from('LineChart', 'valueLabels', {
      type: 'NebaChartValueLabels',
      default: 'NebaChartValueLabels.none'
    }),
    from('LineChart', 'stacked', { type: 'bool' }),
    ...chartBaseRows('LineChart')
  ],

  NebaChartSeries: [
    from('NebaChartSeries', 'name', { type: 'String?' }),
    from('NebaChartSeries', 'data', {
      type: 'List<Object?>',
      description: {
        ko: 'category 순서대로의 값. 각 값은 num, 결측을 뜻하는 null, 또는 NebaChartPoint이고, 그 밖의 값은 결측으로 읽습니다',
        en: 'The values, in category order: each a num, a null for a gap, or a NebaChartPoint. Anything else is read as a gap'
      }
    }),
    from('NebaChartSeries', 'color', {
      type: 'Object?',
      description: {
        ko: '팔레트 슬롯을 덮어쓰는 NebaColor나 Color. series는 성공이나 위험이 아니라 개체이므로, 브랜드 색을 맞추거나 두 차트에서 같은 색을 유지할 때 쓰세요',
        en: 'A NebaColor or a Color over the palette slot. A series is an entity rather than a role, so reach for it to match a brand or to hold a colour steady across two charts'
      }
    }),
    from('NebaChartSeries', 'hidden', { type: 'bool' }),
    from('NebaChartSeries', 'axis', {
      type: 'NebaChartSeriesAxis',
      default: 'NebaChartSeriesAxis.primary'
    })
  ],

  NebaChartAxis: [
    from('NebaChartAxis', 'hidden', { type: 'bool' }),
    from('NebaChartAxis', 'label', { type: 'String?' }),
    from('NebaChartAxis', 'grid', { type: 'bool?' }),
    from('NebaChartAxis', 'min', { type: 'double?' }),
    from('NebaChartAxis', 'max', { type: 'double?' }),
    from('NebaChartAxis', 'tickCount', { type: 'int?' }),
    from('NebaChartAxis', 'tickFormat', {
      type: 'String Function(Object value, int index)?',
      description: {
        ko: '눈금 하나를 어떻게 쓸지. 차트의 format보다 우선합니다. 값 축은 눈금을 num으로, 정수이면 int로 넘기고, category 축은 받은 category를 그대로 넘깁니다',
        en: "How a tick is written, overriding the chart's own format. A value axis hands it the tick as a num, an int when whole; a category axis hands it the category as it was given"
      }
    }),
    from('NebaChartAxis', 'tickAngle', { type: 'double' }),
    from('NebaChartAxis', 'thickness', { type: 'double?' })
  ],

  NebaChartReference: [
    from('NebaChartReference', 'value', { type: 'double' }),
    from('NebaChartReference', 'to', { type: 'double?' }),
    from('NebaChartReference', 'axis', {
      type: 'NebaChartReferenceAxis',
      default: 'NebaChartReferenceAxis.value'
    }),
    from('NebaChartReference', 'label', {
      type: 'String?',
      description: {
        ko: '선의 이름. 먼 쪽 끝에 씁니다. 캔버스에 그리는 글자라 문자열만 받습니다. 이름이 있는 reference는 표 아래 숨은 목록으로도 읽힙니다',
        en: 'What it is called, written at the far end. Painted on the canvas, so a string. A reference that names itself is also read out with the data'
      }
    }),
    from('NebaChartReference', 'color', {
      type: 'Object?',
      description: {
        ko: '선의 색. NebaColor나 Color를 받습니다. 기본값이 중립인 데는 이유가 있습니다. reference를 danger로 칠하면 그 선이 나쁜 것이라는 말이 되는데, 보통 나쁜 것은 그 선을 넘은 데이터입니다',
        en: 'Its colour, a NebaColor or a Color. Neutral by default for a reason: a reference in danger says the line is the bad thing, when usually the bad thing is the data crossing it'
      }
    }),
    from('NebaChartReference', 'solid', { type: 'bool' })
  ],

  NebaChartLegend: [
    from('NebaChartLegend', 'side', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('NebaChartLegend', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('NebaChartLegend', 'interactive', { type: 'bool' }),
    from('NebaChartLegend', 'showValue', { type: 'bool' })
  ],

  NebaChartTooltip: [
    from('NebaChartTooltip', 'mode', {
      type: 'NebaChartTooltipMode?',
      default: 'NebaChartTooltipMode.category',
      description: {
        ko: 'category는 포인터가 있는 category의 모든 series를 crosshair와 함께, item은 가장 가까운 series 하나만 보여 줍니다. React의 index입니다. Dart는 enum에 index라는 이름을 쓸 수 없습니다',
        en: "category shows every series at the category under the pointer, with a crosshair; item shows the nearest series alone. React's index, a name Dart reserves on an enum"
      }
    }),
    from('NebaChartTooltip', 'crosshair', { type: 'bool' }),
    renamed('NebaChartTooltip', 'render', 'builder', {
      type: 'Widget Function(BuildContext, NebaChartTooltipContext)?'
    })
  ]
} satisfies Record<string, PropRow[]>;

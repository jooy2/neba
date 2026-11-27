import { DENSITY, ELEVATION, from, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  GaugeChart: [
    from('GaugeChart', 'value', { type: 'double?' }),
    from('GaugeChart', 'min', { type: 'double' }),
    from('GaugeChart', 'max', { type: 'double' }),
    from('GaugeChart', 'sweep', { type: 'double' }),
    from('GaugeChart', 'thickness', { type: 'double' }),
    from('GaugeChart', 'thresholds', { type: 'List<NebaThreshold>?' }),
    from('GaugeChart', 'ticks', {
      type: 'int?',
      default: 'null',
      description: {
        ko: '양 끝을 포함해 그려지는 눈금의 수. null이면 그리지 않습니다. 대시보드의 계기판은 비율로 읽히므로 기본은 꺼짐입니다. React의 false입니다',
        en: "How many marks are drawn around the dial, ends included; null draws none. Off by default: a gauge on a dashboard is read as a proportion. React's false"
      }
    }),
    from('GaugeChart', 'showRange', { type: 'bool' }),
    from('GaugeChart', 'center', {
      type: `${WIDGET}?`,
      description: {
        ko: '가운데에 들어갈 것. 기본은 format을 거친 값입니다. Text이면 값처럼 계기판 안의 자리에 맞춰 크기가 정해집니다',
        en: 'What goes in the middle. Left out, it is the value written through format. A Text is sized to the room in the dial, as the value is'
      }
    }),
    from('GaugeChart', 'caption', {
      type: `${WIDGET}?`,
      description: {
        ko: '값 아래 한 줄, 단위, 또는 무엇을 재고 있는지. Text이면 screen reader가 값 뒤에 이어 읽습니다',
        en: 'A line under the value: the unit, or what is being measured. A Text is also read out after the value'
      }
    }),
    from('GaugeChart', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    from('GaugeChart', 'height', {
      type: 'double?',
      description: {
        ko: '그림의 높이(논리 픽셀). 지정하지 않으면 size 사다리를 따릅니다',
        en: 'How tall the drawing is, in logical pixels. Defaults to the size ladder'
      }
    }),
    from('GaugeChart', 'format', {
      type: 'String Function(num value)?',
      description: {
        ko: '값과 범위 양 끝의 숫자를 쓰는 함수. 정수인 값은 int로 받습니다. 생략하면 만 이상은 축약하고(12.4K) 그 아래는 세 자리마다 쉼표로 묶습니다',
        en: 'Writes the value and the two ends of the scale. A whole number arrives as an int. Left out, past ten thousand a number is compacted (12.4K) and below it grouped by threes'
      }
    }),
    from('GaugeChart', 'label', {
      type: 'String?',
      description: {
        ko: '무엇을 재는지에 대한 이름. 있으면 계기판은 그 이름에 읽은 값을 값으로 가진 노드 하나가 됩니다. 없으면 가운데의 숫자가 그대로 텍스트로 읽힙니다',
        en: 'What the dial measures. Given one, the dial is one node of that name whose value is the reading; without one, the number in the middle is read as the text it is'
      }
    }),
    from('GaugeChart', 'empty', {
      type: `${WIDGET}?`,
      description: {
        ko: '범위가 없어 그릴 것이 없을 때 그리는 것',
        en: 'What to draw when the scale has no range'
      }
    }),
    sizeRow('GaugeChart'),
    variantRow('GaugeChart', 'NebaVariant.text'),
    from('GaugeChart', 'locale', {
      type: 'Locale?',
      description: {
        ko: '차트가 스스로 쓰는 말의 언어. 빈 상태의 문구입니다. 없으면 NebaProvider의 locale을, 그것도 없으면 앱의 locale을 씁니다',
        en: "The language of the chart's own words: its empty state. Falls back to NebaProvider's, then the app's"
      }
    }),
    from('GaugeChart', 'padded', { type: 'bool' }),
    {
      name: 'density',
      type: `${DENSITY}?`,
      default: 'NebaDensity.standard',
      description: {
        ko: '시트의 여백',
        en: "The sheet's padding"
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: '0',
      description: {
        ko: '시트의 그림자, 0부터 3까지',
        en: "The sheet's drop shadow, from 0 to 3"
      }
    },
    {
      name: 'transition',
      type: 'NebaTransition?',
      description: {
        ko: '처음 빌드될 때 한 번 실행되는 등장 애니메이션. 시트가 통째로 움직입니다',
        en: 'An entrance animation, run once when the dial is first built. The whole sheet moves'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

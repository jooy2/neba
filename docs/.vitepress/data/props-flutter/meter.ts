import { COLOR, colorRow, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Meter: [
    from('Meter', 'value', { type: 'double' }),
    from('Meter', 'min', { type: 'double' }),
    from('Meter', 'max', { type: 'double' }),
    from('Meter', 'thresholds', { type: 'List<NebaThreshold>?' }),
    from('Meter', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '무엇을 재고 있는지에 대한 이름. 보통 Text이며, Text이면 screen reader가 읽는 이름도 됩니다',
        en: 'A name for what is being measured, usually a Text. A Text is also the name a screen reader hears'
      }
    }),
    from('Meter', 'showValue', { type: 'bool' }),
    from('Meter', 'format', {
      type: 'String Function(double value)?',
      description: {
        ko: '값을 글자로 쓰는 함수. 범위 안으로 잡힌 값을 받으며, 앱이 쓰는 formatter와 언어로 씁니다. meter는 대개 실제 단위를 가지므로 프로그레스 바보다 자주 쓰입니다',
        en: "Writes the value as text. It is handed the value held to the range, in the app's own formatter and language. A meter usually has real units, which is when this matters more than it does on a progress bar"
      }
    }),
    sizeRow('Meter'),
    from('Meter', 'thickness', { type: 'double?' }),
    colorRow('Meter'),
    {
      ...semanticLabelRow,
      description: {
        ko: 'label 대신 screen reader가 읽는 이름. React의 `aria-label`에 해당합니다',
        en: "The name a screen reader announces in place of label: React's `aria-label`"
      }
    }
  ],

  NebaThreshold: [
    from('NebaThreshold', 'from', { type: 'double' }),
    from('NebaThreshold', 'color', { type: COLOR })
  ]
} satisfies Record<string, PropRow[]>;

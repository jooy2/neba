import { colorRow, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  ProgressLinear: [
    from('ProgressLinear', 'value', { type: 'double?' }),
    from('ProgressLinear', 'min', { type: 'double' }),
    from('ProgressLinear', 'max', { type: 'double' }),
    sizeRow('ProgressLinear'),
    colorRow('ProgressLinear'),
    from('ProgressLinear', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '무엇을 기다리는지. 보통 Text이며, Text이면 screen reader가 읽는 이름도 됩니다',
        en: 'A name for what is loading, usually a Text. A Text is also the name a screen reader hears'
      }
    }),
    from('ProgressLinear', 'showValue', { type: 'bool' }),
    from('ProgressLinear', 'format', {
      type: 'String Function(double value)?',
      description: {
        ko: '값을 글자로 쓰는 함수. 범위 안으로 잡힌 값을 받으며, 앱이 쓰는 formatter와 언어로 씁니다. 없으면 min…max에 대한 백분율입니다',
        en: "Writes the value as text. It is handed the value held to the range, in the app's own formatter and language. Without it the value is a percentage of min…max"
      }
    }),
    from('ProgressLinear', 'thickness', { type: 'double?' }),
    {
      ...semanticLabelRow,
      description: {
        ko: 'label 대신 screen reader가 읽는 이름. React의 `aria-label`에 해당합니다',
        en: "The name a screen reader announces in place of label: React's `aria-label`"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

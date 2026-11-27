import { colorRow, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  ProgressBox: [
    from('ProgressBox', 'value', { type: 'double?' }),
    from('ProgressBox', 'min', { type: 'double' }),
    from('ProgressBox', 'max', { type: 'double' }),
    sizeRow('ProgressBox'),
    colorRow('ProgressBox'),
    from('ProgressBox', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '무엇을 기다리는지. 보통 Text이며, Text이면 screen reader가 읽는 이름도 됩니다',
        en: 'A name for what is loading, usually a Text. A Text is also the name a screen reader hears'
      }
    }),
    from('ProgressBox', 'showValue', { type: 'bool' }),
    from('ProgressBox', 'format', {
      type: 'String Function(double value)?',
      description: {
        ko: '값을 글자로 쓰는 함수. 범위 안으로 잡힌 값을 받으며, 앱이 쓰는 formatter와 언어로 씁니다. 없으면 min…max에 대한 백분율입니다',
        en: "Writes the value as text. It is handed the value held to the range, in the app's own formatter and language. Without it the value is a percentage of min…max"
      }
    }),
    from('ProgressBox', 'count', {
      type: 'int',
      description: {
        ko: '판의 개수. 넷이면 파도가 파도로 읽히면서도 한눈에 셀 수 있습니다. 기다리는 대상에 실제로 단계가 있다면 그 수를 넣으세요. 1보다 작으면 판 하나를 그립니다',
        en: 'How many plates. Four reads as a wave and can still be counted at a glance. Set it to the number of steps when the thing being waited on genuinely has steps. Under one, one plate is drawn'
      }
    }),
    {
      ...semanticLabelRow,
      description: {
        ko: 'label 대신 screen reader가 읽는 이름. React의 `aria-label`에 해당합니다',
        en: "The name a screen reader announces in place of label: React's `aria-label`"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

import {
  densityRow,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Statistic: [
    from('Statistic', 'label', { type: `${WIDGET}?` }),
    from('Statistic', 'value', {
      type: 'Object',
      description: {
        ko: '수치. num이면 형식대로 쓰고 previousValue와 비교합니다. String이나 위젯은 그대로 그리며 비교하지 않습니다',
        en: 'The figure. A num is formatted and compared with previousValue; a String or a widget is drawn as it is and never compared'
      }
    }),
    from('Statistic', 'format', {
      type: 'String Function(num)?',
      description: {
        ko: '숫자를 쓰는 방법. 수치와 절대 변화량 모두에 쓰입니다. 생략하면 세 자리마다 쉼표로 묶고 소수점 아래는 세 자리까지 씁니다. 통화나 다른 언어의 구분 기호는 이 함수로 씁니다',
        en: 'How a number is written, the figure and an absolute change alike. Left out, digits are grouped by threes with a comma and at most three after the point; a currency or another language’s separators are this function’s'
      }
    }),
    from('Statistic', 'prefix', { type: `${WIDGET}?` }),
    from('Statistic', 'unit', { type: `${WIDGET}?` }),
    from('Statistic', 'icon', { type: `${WIDGET}?` }),
    from('Statistic', 'previousValue', { type: 'num?' }),
    from('Statistic', 'delta', {
      type: 'NebaStatisticDelta',
      default: 'NebaStatisticDelta.percent'
    }),
    from('Statistic', 'betterWhen', {
      type: 'NebaStatisticBetterWhen',
      default: 'NebaStatisticBetterWhen.up'
    }),
    from('Statistic', 'caption', { type: `${WIDGET}?` }),
    from('Statistic', 'align', { type: 'NebaAlign', default: 'NebaAlign.start' }),
    variantRow('Statistic', 'NebaVariant.outline'),
    sizeRow('Statistic'),
    from('Statistic', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Statistic'),
    from('Statistic', 'elevation', { type: 'NebaElevation', default: '0' }),
    renamed('Statistic', 'children', 'child', { type: `${WIDGET}?` }),
    transitionRow('Statistic', 'const NebaTransition.zoom()')
  ]
} satisfies Record<string, PropRow[]>;

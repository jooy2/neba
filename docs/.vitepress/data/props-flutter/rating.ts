import { from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Rating: [
    from('Rating', 'value', { type: 'double?' }),
    from('Rating', 'defaultValue', { type: 'double' }),
    from('Rating', 'onValueChange', { type: 'ValueChanged<double>?' }),
    from('Rating', 'count', { type: 'int' }),
    from('Rating', 'precision', { type: 'double' }),
    from('Rating', 'icon', { type: `${WIDGET}?` }),
    from('Rating', 'emptyIcon', { type: `${WIDGET}?` }),
    from('Rating', 'clearable', { type: 'bool' }),
    from('Rating', 'readOnly', { type: 'bool' }),
    from('Rating', 'disabled', { type: 'bool' }),
    sizeRow('Rating'),
    {
      name: 'color',
      type: 'NebaColor',
      default: 'NebaColor.warning',
      shared: true,
      description: { ko: '채워진 별의 색 계열', en: 'The family of a given point' }
    },
    from('Rating', 'locale', { type: 'Locale?', default: undefined }),
    renamed('Rating', 'label', 'semanticLabel', { type: 'String?' }),
    from('Rating', 'valueLabel', { type: 'String Function(double value, int count)?' }),
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '별 묶음의 focus node', en: 'The rating’s focus node' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '처음 그려질 때 focus를 가져갈지',
        en: 'Whether the rating takes the focus when it is first built'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

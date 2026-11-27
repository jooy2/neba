import {
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Toggle: [
    variantRow('Toggle', 'NebaVariant.outline'),
    sizeRow('Toggle'),
    from('Toggle', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    densityRow('Toggle'),
    elevationRow('Toggle'),
    from('Toggle', 'pressed', { type: 'bool?' }),
    from('Toggle', 'defaultPressed', { type: 'bool' }),
    from('Toggle', 'onPressedChange', { type: 'ValueChanged<bool>?' }),
    from('Toggle', 'value', { type: 'String?' }),
    from('Toggle', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞에 놓이는 아이콘. 토글이 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'An icon before the label, drawn at 1.2 times its size through the IconTheme the toggle hands down'
      }
    }),
    from('Toggle', 'endIcon', { type: `${WIDGET}?` }),
    from('Toggle', 'disabled', {
      type: 'bool?',
      description: {
        ko: '사용 불가. 중립 회색이 되며 focus 순서에서 빠집니다. 주지 않으면 그룹의 값을 따릅니다',
        en: "Unavailable. Turns neutral grey and leaves the focus order. Left out, it is the group's"
      }
    }),
    from('Toggle', 'fullWidth', { type: 'bool' }),
    renamed('Toggle', 'children', 'child', { type: `${WIDGET}?` }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

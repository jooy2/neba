import {
  densityRow,
  elevationRow,
  focusRows,
  from,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  IconButton: [
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      required: true,
      description: {
        ko: '버튼이 하는 일. null이면 다른 Flutter 버튼처럼 비활성입니다',
        en: 'What the button does. null disables it, as on every Flutter button'
      }
    },
    from('IconButton', 'icon', {
      type: WIDGET,
      description: {
        ko: '글리프. 버튼이 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'The glyph, drawn at 1.2 times the label size through the IconTheme the button hands down'
      }
    }),
    from('IconButton', 'label', { type: 'String' }),
    variantRow('IconButton'),
    sizeRow('IconButton'),
    from('IconButton', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    densityRow('IconButton'),
    elevationRow('IconButton'),
    from('IconButton', 'loading', {
      type: 'bool',
      description: {
        ko: '글리프 자리에 도는 링을 놓고 누름을 막습니다. focus는 그대로입니다',
        en: "Puts a turning ring in the glyph's place and stops the press, while keeping the focus"
      }
    }),
    from('IconButton', 'readOnly', { type: 'bool' }),
    from('IconButton', 'focusableWhenDisabled', {
      type: 'bool',
      description: {
        ko: '비활성 버튼을 focus 순서에 남겨 둡니다. 자기 누름으로 비활성이 되는 버튼이 focus를 잃지 않게 합니다',
        en: 'Keeps a disabled button in the focus order, so a button disabled by its own press keeps the focus'
      }
    }),
    from('IconButton', 'disabled', {
      type: 'bool?',
      description: {
        ko: '사용 불가. 중립 회색이 되며 focus 순서에서 빠집니다. 주지 않으면 ButtonGroup의 값을 따릅니다',
        en: "Unavailable. Turns neutral grey and leaves the focus order. Left out, it is the ButtonGroup's"
      }
    }),
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

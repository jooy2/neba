import {
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Button: [
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '버튼이 하는 일. 없으면 다른 Flutter 버튼처럼 비활성입니다',
        en: 'What the button does. Without it the button is disabled, as every Flutter button is'
      }
    },
    variantRow('Button'),
    sizeRow('Button'),
    from('Button', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    densityRow('Button'),
    elevationRow('Button'),
    from('Button', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞에 놓이는 아이콘. 버튼이 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'An icon before the label, drawn at 1.2 times its size through the IconTheme the button hands down'
      }
    }),
    from('Button', 'endIcon', { type: `${WIDGET}?` }),
    from('Button', 'loading', {
      type: 'bool',
      description: {
        ko: 'startIcon 자리에 도는 링을 두고 누름을 막지만 focus는 유지합니다',
        en: 'A turning ring in place of startIcon; stops the press but keeps the focus'
      }
    }),
    from('Button', 'readOnly', { type: 'bool' }),
    from('Button', 'disabled', {
      type: 'bool?',
      default: 'false',
      description: {
        ko: '사용할 수 없음. 색 계열을 버리고 중립 회색이 되며 focus 순서에서 빠집니다. onPressed를 생략한 것과 같고, 주지 않으면 ButtonGroup의 값을 따릅니다',
        en: "Unavailable. Drops the colour family for neutral grey and leaves the focus order: the same as leaving onPressed out. Left out, it is the ButtonGroup's"
      }
    }),
    from('Button', 'focusableWhenDisabled', {
      type: 'bool',
      description: {
        ko: '비활성 버튼을 focus 순서에 남겨 둡니다. 자기 누름으로 비활성이 되는 버튼이 focus를 잃지 않게 하는 것입니다',
        en: 'Keeps a disabled button in the focus order, so a button disabled by its own press keeps the focus'
      }
    }),
    from('Button', 'fullWidth', { type: 'bool' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '라벨 대신 화면 낭독기가 읽는 이름. 아이콘만 있는 버튼에 필요하며 React의 aria-label에 해당합니다',
        en: "The name a screen reader hears in place of the label: what a button with only an icon needs, React's aria-label"
      }
    },
    renamed('Button', 'children', 'child', { type: `${WIDGET}?` }),
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '호출하는 쪽이 focus를 다룰 때의 노드',
        en: 'The focus node, when the caller drives the focus'
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '처음 빌드될 때 focus를 받을지',
        en: 'Whether it takes the focus when first built'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

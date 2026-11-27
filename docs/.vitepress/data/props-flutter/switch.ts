import {
  colorRow,
  focusRows,
  from,
  semanticLabelRow,
  sizeRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Switch: [
    sizeRow('Switch'),
    colorRow('Switch'),
    from('Switch', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '트랙 옆의 글. 보통 Text이며, 누르면 스위치가 켜지거나 꺼지고 화면 낭독기는 이것을 스위치 이름으로 읽습니다',
        en: "The text beside the track, usually a Text. A press on it flips the switch, and a screen reader hears it as the switch's name"
      }
    }),
    from('Switch', 'description', { type: `${WIDGET}?` }),
    from('Switch', 'error', { type: `${WIDGET}?` }),
    from('Switch', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('Switch', 'checked', { type: 'bool?' }),
    from('Switch', 'defaultChecked', { type: 'bool' }),
    from('Switch', 'onCheckedChange', { type: 'ValueChanged<bool>?' }),
    from('Switch', 'labelSide', {
      type: 'NebaSwitchLabelSide',
      default: 'NebaSwitchLabelSide.end'
    }),
    from('Switch', 'readOnly', { type: 'bool' }),
    from('Switch', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 중립 회색이 되며 focus 순서에서 빠집니다',
        en: 'Unavailable. Turns neutral grey and leaves the focus order'
      }
    }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

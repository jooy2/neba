import { focusRows, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Checkbox: [
    sizeRow('Checkbox'),
    from('Checkbox', 'color', {
      type: 'NebaColor?',
      default: 'NebaColor.primary',
      description: {
        ko: '의미론적 색 역할. 주지 않으면 그룹의 값을 따릅니다',
        en: "Semantic colour role. Left out, it is the group's"
      }
    }),
    from('Checkbox', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '네모 옆의 글. 보통 Text이며, 누르면 체크되고 화면 낭독기는 이것을 체크박스 이름으로 읽습니다',
        en: "The text beside the square, usually a Text. A press on it ticks the box, and a screen reader hears it as the checkbox's name"
      }
    }),
    from('Checkbox', 'description', { type: `${WIDGET}?` }),
    from('Checkbox', 'error', { type: `${WIDGET}?` }),
    from('Checkbox', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('Checkbox', 'checked', { type: 'bool?' }),
    from('Checkbox', 'defaultChecked', { type: 'bool' }),
    from('Checkbox', 'onCheckedChange', { type: 'ValueChanged<bool>?' }),
    from('Checkbox', 'indeterminate', { type: 'bool' }),
    from('Checkbox', 'value', {
      type: 'String?',
      description: {
        ko: 'CheckboxGroup 안에서 이 체크박스를 식별하는 값. 체크되면 그룹의 value 리스트에 들어갑니다',
        en: "Identifies this checkbox inside a CheckboxGroup. Ticked, it is in the group's value list"
      }
    }),
    from('Checkbox', 'parent', {
      type: 'bool',
      description: {
        ko: 'allValues를 받은 CheckboxGroup 안에서 모든 옵션을 한 번에 체크하는 부모 체크박스로 만듭니다. 일부만 체크되면 중간 상태로 그려집니다',
        en: 'Inside a CheckboxGroup with allValues, makes this the checkbox that ticks every option at once. It draws itself indeterminate while only some are ticked'
      }
    }),
    from('Checkbox', 'readOnly', {
      type: 'bool?',
      default: 'false',
      description: {
        ko: '값은 보이지만 바꿀 수 없음. 채도만 빠지고 focus 순서에는 남습니다. 주지 않으면 그룹의 값을 따릅니다',
        en: "Shown but not changeable: drains the saturation and keeps its place in the focus order. Left out, it is the group's"
      }
    }),
    from('Checkbox', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 중립 회색이 되며 focus 순서에서 빠집니다. 비활성 그룹 안에서는 이 값과 상관없이 비활성입니다',
        en: 'Unavailable. Turns neutral grey and leaves the focus order. Inside a disabled group it is disabled whatever this says'
      }
    }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

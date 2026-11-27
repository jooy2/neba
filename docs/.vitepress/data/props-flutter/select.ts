import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Select: [
    variantRow('Select', 'NebaVariant.outline'),
    sizeRow('Select'),
    colorRow('Select'),
    densityRow('Select'),
    elevationRow('Select'),
    from('Select', 'items', {
      type: 'List<NebaSelectOption<T>>',
      description: {
        ko: '옵션 목록. NebaSelectOption(value, label, disabled, group)의 리스트이며, label은 보통 Text입니다. group이 같은 연속된 옵션 위에 제목이 붙습니다',
        en: 'The options, as a list of NebaSelectOption(value, label, disabled, group), each label usually a Text. Adjacent options naming the same group get a heading over them'
      }
    }),
    from('Select', 'value', {
      type: 'T?',
      description: {
        ko: '선택된 옵션의 값. controlled select에 씁니다. null이면 select가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: "The chosen option's value, for a controlled select. Left null, the select keeps its own state, starting from defaultValue"
      }
    }),
    from('Select', 'defaultValue', { type: 'T?' }),
    from('Select', 'onValueChange', {
      type: 'ValueChanged<T>?',
      description: {
        ko: '옵션을 고를 때 그 값으로 호출됩니다',
        en: 'Called with the value of the option that was chosen'
      }
    }),
    from('Select', 'placeholder', {
      type: `${WIDGET}?`,
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 흐리게 보이는 내용. 보통 Text입니다',
        en: 'Shown muted in the trigger while nothing is chosen, usually a Text'
      }
    }),
    from('Select', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'select의 이름. 보통 Text이며, 화면 낭독기는 이것을 트리거의 이름으로 읽습니다',
        en: "The select's name, usually a Text. A screen reader hears it as the trigger's name"
      }
    }),
    from('Select', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    from('Select', 'description', { type: `${WIDGET}?` }),
    from('Select', 'error', { type: `${WIDGET}?` }),
    from('Select', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('Select', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '값 앞에 놓이는 아이콘. select가 내려주는 IconTheme으로 글 크기의 1.2배가 되고 흐리게 그려집니다',
        en: 'Before the value, drawn muted at 1.2 times its size through the IconTheme the select hands down'
      }
    }),
    from('Select', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 주지 않으면 가장 긴 옵션, placeholder, 쉬고 있는 float 라벨 중 가장 넓은 것만큼의 너비입니다',
        en: 'Stretches to the width it is given. Otherwise as wide as its widest option, its placeholder or a resting float label'
      }
    }),
    from('Select', 'open', { type: 'bool?' }),
    from('Select', 'defaultOpen', { type: 'bool' }),
    from('Select', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Select', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 바뀌지 않습니다. 옵션을 읽을 수 있도록 목록은 열리지만 아무것도 고를 수 없고, trigger는 focus를 받으며 평평해지고 채도가 빠집니다',
        en: 'Shown but not changeable. The list still opens so the options can be read, and nothing in it can be chosen; the trigger keeps the focus, goes flat and drains the saturation'
      }
    }),
    from('Select', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

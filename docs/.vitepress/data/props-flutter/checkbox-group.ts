import { colorRow, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  CheckboxGroup: [
    sizeRow('CheckboxGroup'),
    colorRow('CheckboxGroup'),
    from('CheckboxGroup', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.vertical'
    }),
    from('CheckboxGroup', 'spacing', {
      type: 'double?',
      description: {
        ko: '체크박스 사이의 간격. 간격 스케일이라 3은 12 논리 픽셀이며, 가로 그룹이 줄바꿈될 때 줄 사이에도 같은 길이가 쓰입니다. 주지 않으면 세로 그룹은 size를 따라 md에서 12이고, 가로 그룹은 같은 줄에서 20, 줄 사이는 세로와 같은 단계입니다. NebaProvider의 spacing은 읽지 않습니다',
        en: "The gap between the checkboxes, on the spacing scale: 3 is 12 logical pixels. A horizontal group that wraps puts its lines the same distance apart. Left out, a column follows size, 12 at md, and a row keeps 20 along it with the column's step between lines. NebaProvider's spacing does not reach it"
      }
    }),
    from('CheckboxGroup', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '체크박스들이 답하는 질문. 보통 Text이며, 화면 낭독기는 이것을 그룹 이름으로 읽습니다',
        en: 'The question the checkboxes answer, usually a Text. A screen reader hears it as the name of the group'
      }
    }),
    from('CheckboxGroup', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨과 체크박스 사이의 보조 설명',
        en: 'Helper text between the label and the checkboxes'
      }
    }),
    from('CheckboxGroup', 'error', { type: `${WIDGET}?` }),
    from('CheckboxGroup', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('CheckboxGroup', 'value', {
      type: 'List<String>?',
      description: {
        ko: '체크된 체크박스들의 value. onValueChange와 함께 controlled 그룹에 씁니다. null이면 그룹이 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'The values of the ticked checkboxes, for a controlled group with onValueChange. Left null, the group keeps its own state, starting from defaultValue'
      }
    }),
    from('CheckboxGroup', 'defaultValue', { type: 'List<String>', default: 'const <String>[]' }),
    from('CheckboxGroup', 'onValueChange', {
      type: 'ValueChanged<List<String>>?',
      description: {
        ko: '체크박스 하나가 체크되거나 풀릴 때 새 리스트와 함께 호출됩니다. 새로 체크된 값은 끝에 붙습니다',
        en: 'Called with the new list when a checkbox is ticked or unticked. A newly ticked value goes on the end'
      }
    }),
    from('CheckboxGroup', 'allValues', { type: 'List<String>?' }),
    from('CheckboxGroup', 'readOnly', { type: 'bool' }),
    from('CheckboxGroup', 'disabled', { type: 'bool' }),
    from('CheckboxGroup', 'children', {
      type: `List<${WIDGET}>`,
      description: {
        ko: 'Checkbox들. 호출하는 쪽의 위젯 안에 더 깊이 둘 수도 있습니다',
        en: "The Checkboxes. One may also sit further down, inside a widget of the caller's"
      }
    }),
    {
      ...semanticLabelRow,
      description: {
        ko: '라벨이 없는 그룹을 화면 낭독기가 부르는 이름. React의 aria-label에 해당합니다',
        en: "What a screen reader calls a group with no label: React's aria-label"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

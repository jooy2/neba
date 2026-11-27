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
  RadioGroup: [
    sizeRow('RadioGroup'),
    colorRow('RadioGroup'),
    from('RadioGroup', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.vertical'
    }),
    from('RadioGroup', 'spacing', {
      type: 'double?',
      description: {
        ko: '옵션 사이의 간격. 간격 스케일이라 3은 12 논리 픽셀이며, 가로 그룹이 줄바꿈될 때 줄 사이에도 같은 길이가 쓰입니다. 주지 않으면 세로 그룹은 size를 따라 md에서 12이고, 가로 그룹은 같은 줄에서 20, 줄 사이는 세로와 같은 단계입니다. NebaProvider의 spacing은 읽지 않습니다',
        en: "The gap between the options, on the spacing scale: 3 is 12 logical pixels. A horizontal group that wraps puts its lines the same distance apart. Left out, a column follows size, 12 at md, and a row keeps 20 along it with the column's step between lines. NebaProvider's spacing does not reach it"
      }
    }),
    from('RadioGroup', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '옵션들이 답하는 질문. 보통 Text이며, 화면 낭독기는 이것을 그룹 이름으로 읽습니다',
        en: 'The question the options answer, usually a Text. A screen reader hears it as the name of the group'
      }
    }),
    from('RadioGroup', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨과 옵션 사이의 보조 설명',
        en: 'Helper text between the label and the options'
      }
    }),
    from('RadioGroup', 'error', { type: `${WIDGET}?` }),
    from('RadioGroup', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('RadioGroup', 'value', {
      type: 'T?',
      description: {
        ko: '선택된 옵션의 값. controlled 그룹에 씁니다. null이면 그룹이 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: "The chosen option's value, for a controlled group. Left null, the group keeps its own state, starting from defaultValue"
      }
    }),
    from('RadioGroup', 'defaultValue', { type: 'T?' }),
    from('RadioGroup', 'onValueChange', { type: 'ValueChanged<T?>?' }),
    from('RadioGroup', 'readOnly', {
      type: 'bool',
      description: {
        ko: '선택은 보이지만 바꿀 수 없음. 채도만 빠지며, 화살표 키는 옵션 사이를 옮겨 다니기만 하고 고르지 않습니다',
        en: 'Shown but not changeable: drains the saturation, and the arrow keys move between the options without choosing'
      }
    }),
    from('RadioGroup', 'disabled', { type: 'bool' }),
    from('RadioGroup', 'children', {
      type: `List<${WIDGET}>`,
      description: {
        ko: 'Radio들. 호출하는 쪽의 위젯 안에 더 깊이 둘 수도 있습니다',
        en: "The Radio options. One may also sit further down, inside a widget of the caller's"
      }
    }),
    {
      ...semanticLabelRow,
      description: {
        ko: '라벨이 없는 그룹을 화면 낭독기가 부르는 이름. React의 aria-label에 해당합니다',
        en: "What a screen reader calls a group with no label: React's aria-label"
      }
    }
  ],

  Radio: [
    from('Radio', 'value', { type: 'T' }),
    from('Radio', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '점 옆의 글. 보통 Text이며, 누르면 이 옵션이 선택되고 화면 낭독기는 이것을 옵션 이름으로 읽습니다',
        en: "The text beside the dot, usually a Text. A press on it chooses the option, and a screen reader hears it as the option's name"
      }
    }),
    from('Radio', 'description', { type: `${WIDGET}?` }),
    from('Radio', 'readOnly', {
      type: 'bool?',
      default: 'false',
      description: {
        ko: '선택 여부는 보이지만 바꿀 수 없음. 주지 않으면 그룹의 값을 따릅니다',
        en: "Shown but not changeable. Left out, it is the group's"
      }
    }),
    from('Radio', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 중립 회색이 되고 focus 순서에서 빠지며 화살표 키도 건너뜁니다. 비활성 그룹 안에서는 이 값과 상관없이 비활성입니다',
        en: 'Unavailable: neutral grey, out of the focus order and passed over by the arrow keys. Inside a disabled group it is disabled whatever this says'
      }
    }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;

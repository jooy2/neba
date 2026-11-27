import {
  densityRow,
  elevationRow,
  from,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  ButtonGroup: [
    variantRow('ButtonGroup', '—'),
    sizeRow('ButtonGroup', '—'),
    from('ButtonGroup', 'color', { type: 'NebaColor?' }),
    densityRow('ButtonGroup', '—'),
    elevationRow('ButtonGroup', '—'),
    from('ButtonGroup', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal',
      description: {
        ko: '버튼이 이어지는 방향. 세로면 위아래 모서리가 깎이고, 그룹은 가장 넓은 버튼만큼 넓어집니다',
        en: 'Which way the buttons run. Vertical squares the top and bottom corners instead, and is as wide as its widest button'
      }
    }),
    from('ButtonGroup', 'disabled', {
      type: 'bool?',
      description: {
        ko: '그룹 안의 버튼을 한 번에 비활성화합니다. disabled를 직접 준 버튼은 그 값을 따릅니다',
        en: 'Disables every button in the group at once, except one that says otherwise itself'
      }
    }),
    from('ButtonGroup', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 넓어지고 버튼이 너비를 고르게 나눠 가집니다. 라벨이 그 몫보다 긴 버튼은 자기 너비를 유지합니다',
        en: 'Stretches to the width it is given and shares it evenly; a button whose label needs more than its share keeps its own width'
      }
    }),
    from('ButtonGroup', 'children', { type: `List<${WIDGET}>` }),
    {
      ...semanticLabelRow,
      description: {
        ko: '화면 낭독기가 그룹을 부르는 이름. React의 aria-label에 해당합니다',
        en: "What a screen reader calls the group: React's aria-label"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

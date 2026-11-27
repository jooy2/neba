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
  ToggleGroup: [
    variantRow('ToggleGroup', '—'),
    sizeRow('ToggleGroup', '—'),
    from('ToggleGroup', 'color', { type: 'NebaColor?' }),
    densityRow('ToggleGroup', '—'),
    elevationRow('ToggleGroup', '—'),
    from('ToggleGroup', 'value', { type: 'List<String>?' }),
    from('ToggleGroup', 'defaultValue', { type: 'List<String>', default: 'const <String>[]' }),
    from('ToggleGroup', 'onValueChange', { type: 'ValueChanged<List<String>>?' }),
    from('ToggleGroup', 'multiple', { type: 'bool' }),
    from('ToggleGroup', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('ToggleGroup', 'disabled', {
      type: 'bool?',
      description: {
        ko: '그룹 안의 토글을 한 번에 비활성화합니다. disabled를 직접 준 토글은 그 값을 따릅니다',
        en: 'Disables every toggle in the set at once, except one that says otherwise itself'
      }
    }),
    from('ToggleGroup', 'loopFocus', { type: 'bool' }),
    from('ToggleGroup', 'fullWidth', { type: 'bool' }),
    from('ToggleGroup', 'children', { type: `List<${WIDGET}>` }),
    {
      ...semanticLabelRow,
      description: {
        ko: '화면 낭독기가 그룹을 부르는 이름. React의 aria-label에 해당합니다',
        en: "What a screen reader calls the set: React's aria-label"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;

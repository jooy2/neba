import { from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Fieldset: [
    from('Fieldset', 'legend', {
      type: `${WIDGET}?`,
      description: {
        ko: '묶음의 이름. 보통 Text이며, 화면 낭독기가 묶음의 이름으로 읽으므로 각 컨트롤 앞에 붙여 읽어도 말이 되는 구절이어야 합니다',
        en: 'What the group is called, usually a Text. A screen reader hears it as the group’s name, so it has to read correctly in front of each control'
      }
    }),
    from('Fieldset', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: 'legend 아래 한 줄. 보통 Text이며, 화면 낭독기는 이름 뒤에 설명으로 읽습니다',
        en: 'A line under the legend, usually a Text. A screen reader hears it after the name, as the description'
      }
    }),
    from('Fieldset', 'disabled', {
      type: 'bool',
      description: {
        ko: '안의 모든 Neba 컨트롤을 한 번에 비활성화합니다. 각 컨트롤은 자기 disabled보다 이것을 먼저 따르고, 비활성으로 그려지며 입력을 받지 않습니다. 비활성 Fieldset 안의 Fieldset도 비활성입니다',
        en: 'Disables every Neba control inside at once. Each one takes it over its own disabled, is drawn disabled and takes no input. A Fieldset inside a disabled one is disabled too'
      }
    }),
    sizeRow('Fieldset'),
    from('Fieldset', 'spacing', {
      type: 'double?',
      description: {
        ko: '컨트롤 사이의 간격. 간격 스케일이라 5는 20 논리 픽셀입니다. size가 고르는 간격 대신 쓰이고 legend의 타입 스케일은 그대로 둡니다. NebaProvider의 spacing으로 모든 Fieldset에 한 번에 정할 수 있습니다',
        en: "The gap between the controls, on the spacing scale: 5 is 20 logical pixels. Takes over from the gap size picks and leaves the legend's type scale alone. NebaProvider's spacing sets it for every Fieldset"
      }
    }),
    semanticLabelRow,
    from('Fieldset', 'children', { type: `List<${WIDGET}>`, default: '[]' })
  ]
} satisfies Record<string, PropRow[]>;

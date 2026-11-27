import {
  colorRow,
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
  Collapsible: [
    variantRow('Collapsible', 'NebaVariant.outline'),
    sizeRow('Collapsible'),
    colorRow('Collapsible'),
    densityRow('Collapsible'),
    elevationRow('Collapsible'),
    from('Collapsible', 'open', {
      type: 'bool?',
      description: {
        ko: '패널이 열려 있는지. 직접 제어할 때 씁니다. null이면 defaultOpen에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the panel is showing, for a controlled Collapsible. Left null, it keeps its own state, starting from defaultOpen'
      }
    }),
    from('Collapsible', 'defaultOpen', { type: 'bool' }),
    from('Collapsible', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Collapsible', 'title', { type: `${WIDGET}?` }),
    from('Collapsible', 'subtitle', { type: `${WIDGET}?` }),
    from('Collapsible', 'lines', { type: 'int?' }),
    from('Collapsible', 'startIcon', { type: `${WIDGET}?` }),
    from('Collapsible', 'action', { type: `${WIDGET}?` }),
    renamed('Collapsible', 'trigger', 'triggerBuilder', {
      type: 'NebaCollapsibleTriggerBuilder?',
      description: {
        ko: '헤더를 직접 만든 컨트롤로 통째로 갈아 끼웁니다. 패널이 열렸는지와 여닫는 콜백을 받아 그리며, 콜백은 disabled일 때 null입니다. 화면 낭독기는 이 컨트롤을 펼쳐짐이나 접힘으로 읽습니다',
        en: 'Replaces the header entirely with a control of your own, built from whether the panel is open and the callback that toggles it, which is null while disabled. A screen reader hears it as expanded or collapsed'
      }
    }),
    from('Collapsible', 'indicator', { type: 'bool' }),
    from('Collapsible', 'padded', { type: 'bool' }),
    from('Collapsible', 'disabled', { type: 'bool' }),
    from('Collapsible', 'keepMounted', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '닫힌 패널의 내용을 빌드된 채로 남겨, 접혔다 펴져도 안의 상태가 그대로입니다. 열려 있을 때만 있으면 되는, 만드는 비용이 큰 패널에는 끄면 됩니다',
        en: 'Keeps what a closed panel holds built, so its state survives being folded away. Turn it off for a panel that is expensive to build and only needs to exist while open'
      }
    }),
    renamed('Collapsible', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;

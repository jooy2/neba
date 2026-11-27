import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  FloatingActionButton: [
    variantRow('FloatingActionButton'),
    sizeRow('FloatingActionButton', 'NebaSize.lg'),
    colorRow('FloatingActionButton'),
    densityRow('FloatingActionButton'),
    elevationRow('FloatingActionButton', '2'),
    from('FloatingActionButton', 'icon', { type: `${WIDGET}?` }),
    from('FloatingActionButton', 'label', { type: 'String' }),
    from('FloatingActionButton', 'extended', { type: 'bool' }),
    from('FloatingActionButton', 'openIcon', { type: `${WIDGET}?` }),
    from('FloatingActionButton', 'position', {
      type: 'NebaFloatingActionButtonPosition',
      default: 'NebaFloatingActionButtonPosition.fixed',
      description: {
        ko: '어디에 앉는지. static이 아니면 버튼이 받은 공간 전체를 차지하고 그 corner에 앉으므로, 떠 있을 화면이나 영역 위의 Stack에 넣습니다. fixed와 sticky는 그 모서리 쪽 시스템 inset을 피하고, absolute는 화면 가장자리에 닿지 않는 영역용이라 inset을 더하지 않습니다',
        en: 'Where it sits. Anything but static takes the whole of the space it is given and sits in its corner, so it goes in a Stack over the screen or the region it floats over. fixed and sticky keep clear of the system insets of that corner; absolute is for a region that is not against the edge of the screen, and adds none'
      }
    }),
    from('FloatingActionButton', 'corner', {
      type: 'NebaCorner',
      default: 'NebaCorner.bottomEnd'
    }),
    from('FloatingActionButton', 'offset', {
      type: 'double',
      description: {
        ko: '모서리의 두 가장자리에서 얼마나 안쪽인지, 논리 픽셀',
        en: 'How far in from both edges of its corner, in logical pixels'
      }
    }),
    from('FloatingActionButton', 'safeArea', {
      type: 'bool',
      description: {
        ko: 'fixed나 sticky일 때 모서리가 닿은 두 가장자리의 시스템 inset을 offset에 더합니다. 아래 모서리는 홈 인디케이터를, 가로로 든 휴대폰에서는 노치도 피합니다',
        en: 'On a fixed or sticky button, adds the system insets of the two edges its corner is against to the offset: a bottom corner clears the home indicator and, on a phone held sideways, the notch'
      }
    }),
    from('FloatingActionButton', 'direction', {
      type: 'NebaFloatingActionButtonDirection?'
    }),
    from('FloatingActionButton', 'open', {
      type: 'bool?',
      description: {
        ko: '다이얼이 열려 있는지. controlled 다이얼에 씁니다. null이면 버튼이 defaultOpen에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the dial is open, for a controlled dial. Left null, the button keeps its own state, starting from defaultOpen'
      }
    }),
    from('FloatingActionButton', 'defaultOpen', { type: 'bool' }),
    from('FloatingActionButton', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('FloatingActionButton', 'openOnHover', { type: 'bool' }),
    from('FloatingActionButton', 'closeOnAction', { type: 'bool' }),
    from('FloatingActionButton', 'showLabels', { type: 'bool' }),
    from('FloatingActionButton', 'disabled', { type: 'bool' }),
    renamed('FloatingActionButton', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '버튼을 눌렀을 때. 액션이 있어도 그대로 호출되며, 그때는 누름이 다이얼도 여닫습니다. onPressed도 액션도 없으면 모든 Flutter 버튼처럼 비활성입니다',
        en: 'Called when the button is pressed. It is still called when the button has actions, where the press also opens and closes the dial. With no onPressed and no actions the button is disabled, as every Flutter button is'
      }
    }),
    from('FloatingActionButton', 'children', {
      type: 'List<NebaFloatingAction>',
      description: {
        ko: '다이얼의 액션들, 있다면',
        en: 'The actions of the dial, if there are any'
      }
    }),
    ...focusRows
  ],

  FloatingAction: [
    from('FloatingAction', 'icon', { type: `${WIDGET}?` }),
    from('FloatingAction', 'label', { type: 'String' }),
    from('FloatingAction', 'disabled', { type: 'bool' }),
    renamed('FloatingAction', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '액션을 눌렀을 때, 다이얼이 닫히기 전에 호출됩니다',
        en: 'Called when the action is pressed, before the dial closes'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
